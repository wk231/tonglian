// services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';

class AuthService {
  final HttpService _httpService = HttpService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _httpService.postLognRequest(
      "/api/v1/passport/auth/login",
      {"email": email, "password": password},
    );
  }

  Future<Map<String, dynamic>> register(String email, String password,
      String device_id, String captcha_key, String captcha_code,
      {String? inviteCode}) async {
    final Map<String, dynamic> body = {
      "email": email,
      "password": password,
      "device_id": device_id,
      "captcha_key": captcha_key,
      "captchaInput": captcha_code,
    };
    if (inviteCode != null) {
      body["invite_code"] = inviteCode;
    }
    return await _httpService.postRequest(
      "/api/v1/passport/auth/register",
      body,
    );
  }

  // 获取验证码
  Future<Map<String, dynamic>> getCaptcha() async {
    return await _httpService.getRequest(
      "/api/v1/passport/auth/getcaptcha",
    );
  }

  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    return await _httpService.postRequest(
      "/api/v1/passport/comm/sendEmailVerify",
      {'email': email},
    );
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String password, String emailCode) async {
    return await _httpService.postRequest(
      "/api/v1/passport/auth/forget",
      {
        "email": email,
        "password": password,
        "email_code": emailCode,
      },
    );
  }
}
