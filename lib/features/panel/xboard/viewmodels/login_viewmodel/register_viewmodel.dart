// viewmodels/register_viewmodel.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  // 添加 FormKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isCountingDown = false;

  bool get isCountingDown => _isCountingDown;

  int _countdownTime = 60;

  int get countdownTime => _countdownTime;

  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;
  bool _obscureConfirmPassword = true;

  bool get obscureConfirmPassword => _obscureConfirmPassword;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();

  RegisterViewModel({required AuthService authService}) : _authService = authService {}

  Future<void> sendVerificationCode(BuildContext context) async {
    final email = emailController.text.trim();
    _isCountingDown = true;
    _countdownTime = 60;
    notifyListeners();

    try {
      final response = await _authService.sendVerificationCode(email);

      if (response["status"] == "success") {
        _showSnackbar(context, "Verification code sent to $email");
      } else {
        _showSnackbar(context, response["message"].toString());
      }
    } catch (e) {
      _showSnackbar(context, "Error: $e");
    }

    // 倒计时逻辑
    while (_countdownTime > 0) {
      await Future.delayed(const Duration(seconds: 1));
      _countdownTime--;
      notifyListeners();
    }

    _isCountingDown = false;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();
    final inviteCode = inviteCodeController.text.trim();

    if (password != passwordConfirm) {
      _showSnackbar(context, '两次输入密码不一致');
      _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      final result = await _authService.register(email, password, inviteCode: inviteCode.isEmpty ? null : inviteCode);
      if (result["status"] == "success") {
        _showSnackbar(context, "注册成功");
        if (context.mounted) {
          context.go('/login');
        }
      } else {
        _showSnackbar(context, result["message"].toString());

      }
    } catch (e) {
      _showSnackbar(context, "Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void togglePasswordConfirmVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }
}
