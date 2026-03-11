import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hiddify/features/panel/xboard/services/auth_provider.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

bool _debugMobileRouter = false;

final useMobileRouter = !PlatformUtils.isDesktop || (kDebugMode && _debugMobileRouter);
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// TODO: test and improve handling of deep link
@riverpod
GoRouter router(RouterRef ref) {
  final notifier = ref.watch(routerListenableProvider.notifier);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      if (useMobileRouter) $mobileWrapperRoute else $desktopWrapperRoute,
      $splashRoute,
      $loginRoute,
      $registerRoute,
      $forgetPasswordRoute,
    ],
    refreshListenable: notifier,
    // 简化重定向逻辑，避免路由冲突
    redirect: (context, state) {
      // 基本路由检查
      final currentPath = state.uri.path;
      
      // 允许splash、login、register和forget-password路由直接访问
      if (currentPath == '/splash' || 
          currentPath == '/login' || 
          currentPath == '/register' || 
          currentPath == '/forget-password') {
        return null;
      }
      
      // 检查是否已登录
      final isLoggedIn = ref.read(authProvider);
      if (!isLoggedIn) {
        return '/login';
      }
      
      // 已登录用户可以访问其他路由
      return null;
    },
  );
}

final tabLocations = [
  const HomeRoute().location,
  // const ProxiesRoute().location,
  const PurchaseRoute().location,
  const UserInfoRoute().location,

  const SettingsRoute().location,
  const ConfigOptionsRoute().location,
  const LogsOverviewRoute().location,
  const AboutRoute().location,
];

int getCurrentIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.path;
  if (location == const HomeRoute().location) return 0;
  var index = 0;
  for (final tab in tabLocations.sublist(1)) {
    index++;
    if (location.startsWith(tab)) return index;
  }
  return 0;
}

void switchTab(int index, BuildContext context) {
  assert(index >= 0 && index < tabLocations.length);
  final location = tabLocations[index];
  return context.go(location);
}

@riverpod
class RouterListenable extends _$RouterListenable with AppLogger implements Listenable {
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    // 监听状态变化以触发路由刷新
    ref.watch(authProvider);

    ref.listenSelf((_, __) {
      if (state.isLoading) return;
      loggy.debug("triggering listener");
      _routerListener?.call();
    });
  }

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _routerListener = null;
  }
}
