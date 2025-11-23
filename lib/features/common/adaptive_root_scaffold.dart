import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';

import 'package:hiddify/features/panel/xboard/utils/logout_dialog.dart';
import 'package:hiddify/features/stats/widget/side_bar_stats_overview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract interface class RootScaffold {
  static final stateKey = GlobalKey<ScaffoldState>();

  static bool canShowDrawer(BuildContext context) => Breakpoints.small.isActive(context);
}

class AdaptiveRootScaffold extends HookConsumerWidget {
  const AdaptiveRootScaffold(this.navigator, {super.key});

  final Widget navigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final selectedIndex = getCurrentIndex(context);

    final destinations = [
      NavigationDestination(
        icon: const Icon(FluentIcons.home_20_filled),
        label: t.home.pageTitle,
      ),
      NavigationDestination(
        icon: const Icon(FluentIcons.filter_20_filled),
        label: t.proxies.pageTitle,
      ),
      NavigationDestination(
        icon: const Icon(FluentIcons.money_24_filled),
        label: t.purchase.pageTitle,
      ),
      NavigationDestination(
        icon: const Icon(FluentIcons.person_20_filled),
        label: t.userInfo.pageTitle,
      ),
      NavigationDestination(
        icon: const Icon(FluentIcons.box_edit_20_filled),
        label: t.config.pageTitle,
      ),
      // NavigationDestination(
      //   icon: const Icon(FluentIcons.settings_20_filled),
      //   label: t.settings.pageTitle,
      // ),
      // NavigationDestination(
      //   icon: const Icon(FluentIcons.document_text_20_filled),
      //   label: t.logs.pageTitle,
      // ),
      // NavigationDestination(
      //   icon: const Icon(FluentIcons.info_20_filled),
      //   label: t.about.pageTitle,
      // ),
      NavigationDestination(
        icon: const Icon(FluentIcons.sign_out_20_filled),
        label: t.logout.buttonText,
      ),
    ];

    return _CustomAdaptiveScaffold(
      selectedIndex: selectedIndex,
      onSelectedIndexChange: (index) {
        if (index == destinations.length - 1) {
          // 显示登出对话框
          showDialog(
            context: context,
            builder: (context) => const LogoutDialog(), // 使用 LogoutDialog 组件
          );
        } else {
          RootScaffold.stateKey.currentState?.closeDrawer();
          switchTab(index, context);
        }
      },
      destinations: destinations,
      drawerDestinationRange: useMobileRouter ? (4, null) : (0, null),
      bottomDestinationRange: (0, 4),
      useBottomSheet: useMobileRouter,
      sidebarTrailing: const Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SideBarStatsOverview(),
        ),
      ),
      body: navigator,
    );
  }
}

class _CustomAdaptiveScaffold extends HookConsumerWidget {
  const _CustomAdaptiveScaffold({
    required this.selectedIndex,
    required this.onSelectedIndexChange,
    required this.destinations,
    required this.drawerDestinationRange,
    required this.bottomDestinationRange,
    this.useBottomSheet = false,
    this.sidebarTrailing,
    required this.body,
  });

  final int selectedIndex;
  final Function(int) onSelectedIndexChange;
  final List<NavigationDestination> destinations;
  final (int, int?) drawerDestinationRange;
  final (int, int?) bottomDestinationRange;
  final bool useBottomSheet;
  final Widget? sidebarTrailing;
  final Widget body;

  List<NavigationDestination> destinationsSlice((int, int?) range) => destinations.sublist(range.$1, range.$2);

  int? selectedWithOffset((int, int?) range) {
    final index = selectedIndex - range.$1;
    return index < 0 || (range.$2 != null && index > (range.$2! - 1)) ? null : index;
  }

  void selectWithOffset(int index, (int, int?) range) => onSelectedIndexChange(index + range.$1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 检查是否需要隐藏底部tab
    bool hideBottomTab = false;
    
    // 方法1: 通过路由路径自动检测需要隐藏tab的页面
    final routeState = GoRouterState.of(context);
    if (routeState != null) {
      // 自动隐藏特定路径的底部tab
      final hiddenRoutes = ['/order', '/Proxies'];
      if (hiddenRoutes.contains(routeState.uri.path)) {
        hideBottomTab = true;
      }
    }
    
    // 方法2: 通过extra参数手动控制（备用）
    if (!hideBottomTab) {
      final extra = routeState?.extra;
      if (extra is Map && extra.containsKey('hideBottomTab') && extra['hideBottomTab'] == true) {
        hideBottomTab = true;
      }
    }

    final railDestinations = destinations
        .map((dest) => AdaptiveScaffold.toRailDestination(dest))
        .toList();

    return Scaffold(
      key: RootScaffold.stateKey,
      drawer: Breakpoints.small.isActive(context)
          ? Drawer(
              width: (MediaQuery.sizeOf(context).width * 0.88).clamp(1, 304),
              child: NavigationRail(
                extended: true,
                selectedIndex: selectedWithOffset(drawerDestinationRange),
                destinations: destinationsSlice(drawerDestinationRange).map((dest) => AdaptiveScaffold.toRailDestination(dest)).toList(),
                onDestinationSelected: (index) => selectWithOffset(index, drawerDestinationRange),
              ),
            )
          : null,
      body: AdaptiveLayout(
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            if (useMobileRouter)
              Breakpoints.medium: SlotLayout.from(
                key: const Key('primaryNavigationMedium'),
                builder: (_) => AdaptiveScaffold.standardNavigationRail(
                  selectedIndex: selectedIndex,
                  destinations: railDestinations,
                  onDestinationSelected: onSelectedIndexChange,
                ),
              ),
            if (useMobileRouter)
              Breakpoints.large: SlotLayout.from(
                key: const Key('primaryNavigationLarge'),
                builder: (_) => AdaptiveScaffold.standardNavigationRail(
                  extended: true,
                  selectedIndex: selectedIndex,
                  destinations: railDestinations,
                  onDestinationSelected: onSelectedIndexChange,
                  trailing: sidebarTrailing,
                ),
              ),
          },
        ),
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('body'),
              inAnimation: AdaptiveScaffold.fadeIn,
              outAnimation: AdaptiveScaffold.fadeOut,
              builder: (context) => body,
            ),
          },
        ),
      ),
      // AdaptiveLayout bottom sheet has accessibility issues
      // bottomNavigationBar: useBottomSheet && Breakpoints.small.isActive(context)
      //     ? NavigationBar(
      //         selectedIndex: selectedWithOffset(bottomDestinationRange) ?? 0,
      //         destinations: destinationsSlice(bottomDestinationRange),
      //         onDestinationSelected: (index) =>
      //             selectWithOffset(index, bottomDestinationRange),
      //       )
      //     : null,
      bottomNavigationBar: hideBottomTab ? null : Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFECECF0))),
        ),
        height: 56,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            bottomItem(context, 0, 'home', '主页'),
            bottomItem(context, 1, 'combo', '套餐'),
            bottomItem(context, 2, 'mine', '我的'),
          ],
        ),
      ),
    );
  }

  Widget bottomItem(BuildContext context, int index, String icon, String text) {
    return Expanded(
      child: InkWell(
        onTap: () => selectWithOffset(index, bottomDestinationRange),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/main_${icon}_${selectedWithOffset(bottomDestinationRange) == index ? 's' : 'n'}.png', width: 16, height: 16),
              const SizedBox(height: 4),
              Text(text, style: TextStyle(color: selectedWithOffset(bottomDestinationRange) == index ? Theme.of(context).primaryColor : const Color(0xFF7B7B7C), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
