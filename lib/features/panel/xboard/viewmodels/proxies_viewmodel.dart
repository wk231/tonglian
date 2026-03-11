// viewmodels/proxies_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/proxies_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hiddify/features/proxy/model/proxy_entity.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 创建 ProxiesViewModel
class ProxiesViewModel extends ChangeNotifier {
  final ProxiesService _proxiesService;

  List<ProxyEntity>? _proxiesList;

  List<ProxyEntity>? get proxiesList => _proxiesList;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProxiesViewModel({required ProxiesService proxiesService}) : _proxiesService = proxiesService;

  Future<void> fetchProxiesData() async {
    _isLoading = true;
    notifyListeners();
    print('开始获取代理数据...');
    try {
      final token = await getToken();
      if (token != null) {
        _proxiesList = await _proxiesService.fetchProxiesData(token);
      }
    } catch (e) {
      _proxiesList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// 注册 ViewModel 提供器
final proxiesViewModelProvider = ChangeNotifierProvider((ref) {
  return ProxiesViewModel(proxiesService: ProxiesService());
});

// 提供一个访问代理数据的 FutureProvider，确保与 ViewModel 一致
final proxiesProvider = FutureProvider<List<ProxyEntity>?>((ref) async {
  final proxiesViewModel = ref.read(proxiesViewModelProvider);
  await proxiesViewModel.fetchProxiesData();
  return proxiesViewModel.proxiesList;
});
