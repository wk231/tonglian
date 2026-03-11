import 'package:hiddify/features/panel/xboard/models/user_info_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';
import 'package:hiddify/features/panel/xboard/models/subscribe_info_model.dart';

class UserService {
  final HttpService _httpService = HttpService();

  Future<UserInfo?> fetchUserInfo(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/info",
      headers: {'Authorization': accessToken},
    );
    return UserInfo.fromJson(result["data"] as Map<String, dynamic>);
  }

  Future<bool> validateToken(String token) async {
    try {
      final response = await _httpService.getRequest(
        "/api/v1/user/getSubscribe",
        headers: {'Authorization': token},
      );
      return response['status'] == 'success';
    } catch (_) {
      return false;
    }
  }

  Future<SubscribeInfo?> getSubscriptionListt(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/getSubscribe",
      headers: {'Authorization': accessToken},
    );
    return SubscribeInfo.fromJson(result["data"] as Map<String, dynamic>);
  }

  Future<String?> getSubscriptionLink(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/getSubscribe",
      headers: {'Authorization': accessToken},
    );
    // ignore: avoid_dynamic_calls
    return result["data"]["subscribe_url"] as String?;
  }

  Future<String?> resetSubscriptionLink(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/resetSecurity",
      headers: {'Authorization': accessToken},
    );
    return result["data"] as String?;
  }

  Future<Map<String, dynamic>> exchangeCode(String accessToken, String code) async {
    final result = await _httpService.postRequest(
      "/api/v1/user/gift-card/redeem",
      {'code': code},
      headers: {'Authorization': accessToken},
    );
    return result;
  }
}
