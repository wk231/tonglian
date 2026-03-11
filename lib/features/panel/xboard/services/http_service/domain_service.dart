// services/domain_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class DomainService {
  // static const String ossDomain = 'http://tonglian77.com';
  // static const String ossDomain = 'http://tlvpn.net';
  static const String ossDomain = 'http://tlvpn.pro';
  // static const String ossDomain = 'http://154.38.116.210';

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


  

// 从返回的 JSON 中挑选一个可以正常访问的域名
  static Future<String> fetchValidDomain() async {
    try {


      // final response = await http
      //     .get(Uri.parse(ossDomain))
      //     .timeout(const Duration(seconds: 10));
      // if (response.statusCode == 200) {
      //   final List<dynamic> websites =
      //       json.decode(response.body) as List<dynamic>;
      //   for (final website in websites) {
      //     final Map<String, dynamic> websiteMap =
      //         website as Map<String, dynamic>;
      //     final String domain = websiteMap['url'] as String;
      //     print(domain);
      //     if (await _checkDomainAccessibility(domain)) {
      //       if (kDebugMode) {
      //         print('Valid domain found: $domain');
      //       }
      //       return domain;
      //     }
      //   }
      //   throw Exception('No accessible domains found.');
      // } else {
      //   throw Exception(
      //       'Failed to fetch websites.json: $ossDomain ${response.statusCode}');
      // }
      await _checkDomainAccessibility(ossDomain);
      return ossDomain;
    } catch (e) {
      if (kDebugMode) {
        // print('Error fetching valid domain: $ossDomain:  $e');
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
