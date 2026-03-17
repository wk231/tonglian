// views/register_view.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/login_viewmodel/register_viewmodel.dart';
import 'package:hiddify/features/panel/xboard/views/components/widget/captcha_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final registerViewModelProvider = ChangeNotifierProvider((ref) {
  return RegisterViewModel(authService: AuthService());
});

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  static Future<String?> _getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  @override
  void initState() {
    super.initState();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    final androidId = await _getAndroidId();
    if (!mounted) return;
    ref.read(registerViewModelProvider).setDeviceId(androidId);
    ref.read(registerViewModelProvider).refreshCaptcha(context);
  }

  @override
  Widget build(BuildContext context) {
    final registerViewModel = ref.watch(registerViewModelProvider);
    final t = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.register.pageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        child: 
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: registerViewModel.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: registerViewModel.emailController,
                    decoration: InputDecoration(
                      labelText: t.register.email,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.register.emailEmptyError;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: registerViewModel.passwordController,
                    obscureText: registerViewModel.obscurePassword,
                    decoration: InputDecoration(
                      labelText: t.register.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          registerViewModel.obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: registerViewModel.togglePasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.register.passwordEmptyError;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: registerViewModel.passwordConfirmController,
                    obscureText: registerViewModel.obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: '确认密码',
                      suffixIcon: IconButton(
                        icon: Icon(
                          registerViewModel.obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            registerViewModel.togglePasswordConfirmVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.register.passwordEmptyError;
                      }
                      return null;
                    },
                  ),
                  // 验证码：左输入框 + 右图形验证码
                  Row(
                    children: [
                      // 左侧验证码输入框
                      Expanded(
                        child: TextFormField(
                          controller: registerViewModel
                              .captchaController, // 需要在 ViewModel 里加一个 TextEditingController
                          decoration: const InputDecoration(
                            labelText: '验证码',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入验证码';
                            }
                            // 这里可以和当前验证码字符串比对
                            // if (value.toLowerCase() != registerViewModel.currentCaptcha.toLowerCase()) return '验证码错误';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 右侧图形验证码
                      CaptchaWidget(
                        text: registerViewModel
                            .currentCaptcha ?? "", // ViewModel 中维护当前验证码字符串
                        onTap: () => registerViewModel.refreshCaptcha(context), // 点击刷新验证码
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: registerViewModel.inviteCodeController,
                    decoration: InputDecoration(
                      labelText: '邀请码（可选）',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: registerViewModel.isLoading
                        ? null
                        : () => registerViewModel.register(context),
                    child: registerViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : Text(t.register.register),
                  ),
                ],
              ),
            ),
          ),
        
      ),
    );
  }
}
