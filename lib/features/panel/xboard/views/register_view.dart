// views/register_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/login_viewmodel/register_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final registerViewModelProvider = ChangeNotifierProvider((ref) {
  return RegisterViewModel(authService: AuthService());
});

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: Padding(
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
                    icon: Icon(registerViewModel.obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,),
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
                    icon: Icon(registerViewModel.obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,),
                    onPressed: registerViewModel.togglePasswordConfirmVisibility,
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
    );
  }
}
