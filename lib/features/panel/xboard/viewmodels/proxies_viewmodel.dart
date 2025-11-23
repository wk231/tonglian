// viewmodels/proxies_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/proxies_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 创建 ProxiesViewModel
class ProxiesViewModel extends ChangeNotifier {
  final ProxiesService _proxiesService;

  List<String>? _proxiesList;
  List<String>? get proxiesList => _proxiesList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProxiesViewModel({required ProxiesService proxiesService})
      : _proxiesService = proxiesService;

  Future<void> fetchProxiesData() async {
    _isLoading = true;
    notifyListeners();
    print('开始获取代理数据...');

    try {
      final token = await getToken();
      if (token != null) {
        if (kDebugMode) {
          print('Token: $token');
        }
        
        // 尝试初始化HttpService
        try {
          // 检查baseUrl是否已初始化，如果没有则尝试初始化
          if (HttpService.baseUrl.isEmpty) {
            await HttpService.initialize();
          }
        } catch (initError) {
          if (kDebugMode) {
            print('初始化HttpService失败: $initError');
          }
          // 设置默认备用URL
          HttpService.baseUrl = 'http://as001.slkj.fun';
        }
        
        // 尝试获取代理数据，如果失败则使用模拟数据
        try {
          _proxiesList = await _proxiesService.fetchProxiesData(token);
          if (kDebugMode) {
            print('代理数据已获取: $_proxiesList');
          }
        } catch (fetchError) {
          if (kDebugMode) {
            print('获取代理数据失败，使用模拟数据: $fetchError');
          }
        }
      } else {
        if (kDebugMode) {
          print('未找到Token');
        }
      }
    } catch (e) {
      _proxiesList = null;
      if (kDebugMode) {
        print('获取代理数据失败: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('代理数据加载状态: $_isLoading');
      }
    }
  }
}

// 注册 ViewModel 提供器
final proxiesViewModelProvider = ChangeNotifierProvider((ref) {
  return ProxiesViewModel(proxiesService: ProxiesService());
});

// 提供一个访问代理数据的 FutureProvider，确保与 ViewModel 一致
final proxiesProvider = FutureProvider<List<String>?>((ref) async {
  final proxiesViewModel = ref.read(proxiesViewModelProvider);
  await proxiesViewModel.fetchProxiesData();
  return proxiesViewModel.proxiesList;
});