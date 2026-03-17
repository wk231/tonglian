// services/domain_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class DomainService {
  /// 主、备域名列表（按优先级从高到低）
  static const List<String> _domains = [
    'http://web.tlvpn.online:886',         // 主域名
    // 'http://38.47.204.246:868',  // 备用 1
    // 'http://tlvpn.online:886',   // 备用 2
  ];

  /// 最近一次访问成功的域名下标（进程内记忆）
  static int _lastSuccessIndex = 0;

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

  /// 依次尝试主域名和备用域名，找出一个可用的。
  /// - 如果上一次有成功的域名，下次优先从那个域名开始尝试（提高命中率）。
  /// - 所有域名都不可用时抛出异常。
  static Future<String> fetchValidDomain() async {
    try {
      final total = _domains.length;

      // 从上一次成功的域名开始，按顺序轮询所有域名
      for (var i = 0; i < total; i++) {
        final index = (_lastSuccessIndex + i) % total;
        final domain = _domains[index];

        if (await _checkDomainAccessibility(domain)) {
          _lastSuccessIndex = index;
          if (kDebugMode) {
            print('Valid domain found: $domain');
          }
          return domain;
        }
      }

      throw Exception('No accessible domains found.');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching valid domain: $e');
      }
      rethrow;
    }
  }

  static Future<bool> _checkDomainAccessibility(String domain) async {
    try {
      final response = await http
          .get(Uri.parse('$domain/api/v1/guest/comm/config'))
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
