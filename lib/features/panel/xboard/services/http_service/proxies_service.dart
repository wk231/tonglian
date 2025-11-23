// services/plan_service.dart
import 'package:hiddify/features/panel/xboard/models/plan_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';


class ProxiesService {
  final HttpService _httpService = HttpService();

  Future<List<String>> fetchProxiesData(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/server/fetch",
      headers: {'Authorization': accessToken},
    );
    return (result["data"] as List)
        .cast<Map<String, dynamic>>()
        .map((json) => json['icon'] as String)
        .toList();
  }
}
