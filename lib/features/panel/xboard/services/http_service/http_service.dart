// services/http_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/domain_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class HttpService {
  static String baseUrl = ''; // 替换为你的实际基础 URL

  /// 面板 API 始终直连，不走系统/本地代理，避免关闭 VPN 后请求仍发往已关闭的 127.0.0.1:port 导致 20s 超时、页面不加载
  static http.Client? _directClient;
  static http.Client get _client {
    _directClient ??= () {
      final hc = HttpClient();
      hc.findProxy = (_) => 'DIRECT';
      hc.connectionTimeout = const Duration(seconds: 25);
      return IOClient(hc);
    }();
    return _directClient!;
  }

  // 初始化服务并设置动态域名
  static Future<void> initialize() async {
    baseUrl = await DomainService.fetchValidDomain();
  }

  // 统一的 GET 请求方法
  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 20)); // 设置超时时间

      if (kDebugMode) {
        print("GET $baseUrl$endpoint response: ${response.body}");
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  // 统一的 POST 请求方法

  // 统一的 POST 请求方法，增加 requiresHeaders 开关
  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool requiresHeaders = true, // 新增开关参数，默认需要 headers
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client
          .post(
            url,
            headers: requiresHeaders ? (headers ?? {'Content-Type': 'application/x-www-form-urlencoded'}) : null,
            body: body,
          )
          .timeout(const Duration(seconds: 20)); // 设置超时时间

      if (kDebugMode) {
        print("POST $baseUrl$endpoint response: ${response.body}");
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error during POST request to $baseUrl$endpoint: $e');
      }
      rethrow;
    }
  }

  // 统一的 POST 请求方法，增加 requiresHeaders 开关
  Future<Map<String, dynamic>> postLognRequest(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool requiresHeaders = true, // 新增开关参数，默认需要 headers
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .post(
            url,
            // headers: requiresHeaders ? (headers ?? {'Content-Type': 'application/x-www-form-urlencoded'}) : null,
            body: body,
          )
          .timeout(const Duration(seconds: 20)); // 设置超时时间
      if (kDebugMode) {
        print("系统异常");
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('系统异常');
      }
      rethrow;
    }
  }

  // POST 请求方法，不包含 headers
  Future<Map<String, dynamic>> postRequestWithoutHeaders(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client
          .post(
            url,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20)); // 设置超时时间

      if (kDebugMode) {
        print("系统异常");
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('系统异常');
      }
      rethrow;
    }
  }
}
