import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/home/widget/empty_profiles_home_body.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/user_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/proxies_viewmodel.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/user_info_viewmodel.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/utils/placeholders.dart';
import 'package:hiddify/utils/uri_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

final userInfoViewModelProvider = ChangeNotifierProvider((ref) {
  return UserInfoViewModel(userService: UserService());
});

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final connectionStatusValue = connectionStatus.valueOrNull;
    final isSwitchingConnection = connectionStatusValue?.isSwitching ?? false;
    final canChooseProxy = switch (connectionStatus) {
      AsyncData(value: final status) => switch (status) {
          Connected() || Disconnected() => true,
          _ => false,
        },
      AsyncError() => true,
      _ => false,
    };
    // 使用useState来存储选中的代理名称
    final selectedProxyName = useState<String>('请选择线路');

    // 在首页加载时获取代理数据
    useEffect(() {
      Future.microtask(() {
        ref.read(proxiesViewModelProvider).fetchProxiesData();
        ref.read(userInfoViewModelProvider).fetchUserInfo();
      });
      return null;
    }, []); // 空依赖数组表示只在首次渲染时执行一次
    final viewModel = ref.watch(userInfoViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomScrollView(
            slivers: [
              NestedAppBar(
                title: Text(
                  t.general.appTitle,
                  style: const TextStyle(color: Colors.black),
                ),
                // actions: [
                //   // 仅保留快速设置按钮，移除添加配置文件的按钮
                //   IconButton(
                //     onPressed: () => const QuickSettingsRoute().push(context),
                //     icon: const Icon(FluentIcons.options_24_filled),
                //     tooltip: t.config.quickSettings,
                //   ),
                // ],
              ),
              switch (activeProfile) {
                // 如果有活跃的配置文件，显示相应的内容
                AsyncData(value: _) => MultiSliver(
                    children: [
                      // ProfileTile(profile: profile, isMain: true),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Image.asset('assets/images/home_background.png', width: double.infinity, height: 650),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 100),
                                      const ConnectionButton(),
                                      const ActiveProxyDelayIndicator(),
                                      const SizedBox(height: 40),
                                      Visibility(
                                        visible: viewModel.userInfo?.planId == 0,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            const PurchaseRoute().push(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: const Text(
                                            '暂无订阅，跳转至套餐页面购买',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Visibility(
                                        visible: canChooseProxy,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          child: ElevatedButton(
                                            onPressed: isSwitchingConnection
                                                ? null
                                                : () async {
                                                    final result = await context.push('/Proxies');
                                                    if (result != null && result is String) {
                                                      selectedProxyName.value = result;
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.location_on, color: Colors.black),
                                                const SizedBox(width: 4),
                                                Text(
                                                  selectedProxyName.value,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.black),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                                // if (MediaQuery.sizeOf(context).width < 840)
                                //   const ActiveProxyFooter(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                // 处理加载状态
                AsyncLoading() => const SliverToBoxAdapter(),
                // 处理错误状态
                AsyncError(:final error) => SliverErrorBodyPlaceholder(t.presentShortError(error)),
                // 处理空状态
                _ => switch (hasAnyProfile) {
                    AsyncData(value: true) => const EmptyActiveProfileHomeBody(),
                    _ => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t.home.noSubscriptionMsg,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // 导航到套餐购买页面
                                  const PurchaseRoute().push(context);
                                },
                                child: Text(t.home.goToPurchasePage),
                              ),
                            ],
                          ),
                        ),
                      ),
                  }
              },
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => UriUtils.tryLaunch(Uri.parse('https://kf.slkj.fun/')),
          child: Image.asset('assets/images/customer_service.png', width: 46, height: 46),
        ),
      ),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.about.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 1,
        ),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
