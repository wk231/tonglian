import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/proxies_viewmodel.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:hiddify/features/proxy/widget/proxy_tile.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class ProxiesOverviewPage extends HookConsumerWidget with PresLogger {
  const ProxiesOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 代理数据已在首页获取，此处不再重复获取
    
    final t = ref.watch(translationsProvider);

    final asyncProxies = ref.watch(proxiesOverviewNotifierProvider);
    final notifier = ref.watch(proxiesOverviewNotifierProvider.notifier);
    final sortBy = ref.watch(proxiesSortNotifierProvider);

    final selectActiveProxyMutation = useMutation(
      initialOnFailure: (error) => CustomToast.error(t.presentShortError(error)).show(context),
    );

    final viewModel = ref.watch(proxiesViewModelProvider);

    final serviceMode = ref.watch(ConfigOptions.serviceMode);
    final isGlobalMode = serviceMode == ServiceMode.tun || serviceMode == ServiceMode.tunService;
    final isUpdatingGlobalMode = useState(false);
    final lastNonGlobalMode = useState<ServiceMode?>(isGlobalMode ? null : serviceMode);

    useEffect(() {
      if (!isGlobalMode) {
        lastNonGlobalMode.value = serviceMode;
      }
      return null;
    }, [serviceMode, isGlobalMode]);

    ServiceMode fallbackNonGlobalMode() {
      final stored = lastNonGlobalMode.value;
      if (stored != null && stored != ServiceMode.tun && stored != ServiceMode.tunService) {
        return stored;
      }
      final available = ServiceMode.choices;
      if (available.contains(ServiceMode.systemProxy)) {
        return ServiceMode.systemProxy;
      }
      return ServiceMode.proxy;
    }
    
    // 页面标题固定为'请选择线路'，不再动态更改

    final appBar = AppBar(
        title: const Text('请选择线路'),
        leading: Navigator.canPop(context) ? const BackButton() : null,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isGlobalMode,
              onChanged: isUpdatingGlobalMode.value
                  ? null
                  : (value) async {
                      isUpdatingGlobalMode.value = true;
                      final notifier = ref.read(ConfigOptions.serviceMode.notifier);
                      try {
                        if (value) {
                          lastNonGlobalMode.value = serviceMode;
                          await notifier.update(ServiceMode.tun);
                        } else {
                          final targetMode = fallbackNonGlobalMode();
                          await notifier.update(targetMode);
                        }
                      } catch (error, stackTrace) {
                        CustomToast.error(t.presentShortError(error)).show(context);
                        loggy.warning("failed to toggle global mode", error, stackTrace);
                      } finally {
                        isUpdatingGlobalMode.value = false;
                      }
                    },
              activeColor: Colors.white,
            ),
            Text('全局模式'),
          ],
        ),
        SizedBox(width: 20),
        PopupMenuButton<ProxiesSort>(
          initialValue: sortBy,
          onSelected: ref.read(proxiesSortNotifierProvider.notifier).update,
          icon: const Icon(FluentIcons.arrow_sort_24_regular),
            tooltip: t.proxies.sortTooltip,
            itemBuilder: (context) {
              return [
                ...ProxiesSort.values.map(
                (e) => PopupMenuItem(
                  value: e,
                  child: Text(e.present(t)),
                ),
              ),
            ];
          },
        ),
      ],
    );

    switch (asyncProxies) {
      case AsyncData(value: final groups):
        // 移除动态更新标题的逻辑
        
        if (groups.isEmpty) {
          return Scaffold(
            appBar: appBar,
            body: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.proxies.emptyProxiesMsg),
        ],
                  ),
                ),
              ],
            ),
          );
        }

        final group = groups.first;
        // 代理列表已在首页获取
        return Scaffold(
          appBar: appBar,
          body: CustomScrollView(
            slivers: [
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  if (!PlatformUtils.isDesktop && width < 648) {
                    return SliverPadding(
                      padding: const EdgeInsets.only(bottom: 86),
                      sliver: SliverList.builder(
                        itemBuilder: (_, index) {
                          final proxy = group.items[index];
                          return ProxyTile(
                            proxy,
                            index == 0 ? '' : viewModel.proxiesList?[index - 1] ?? '',
                            selected: group.selected == proxy.tag,
                            onSelect: () async {
                              if (selectActiveProxyMutation.state.isInProgress) {
                                return;
                              }
                              // 在异步操作前保存Navigator状态
                              final navigator = Navigator.of(context);
                              // 先调用setFuture，然后在then中将选中的代理名称返回上一页
                              final future = notifier.changeProxy(group.tag, proxy.tag);
                              selectActiveProxyMutation.setFuture(future);
                              future.then((_) {
                                if (navigator.canPop()) {
                                  // 返回选中的代理名称到前一页
                                  navigator.pop(proxy.name);
                                }
                              });
                            },
                          );
                        },
                        itemCount: group.items.length,
                      ),
                    );
                  }

                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (width / 268).floor(),
                      mainAxisExtent: 68,
                    ),
                    itemBuilder: (context, index) {
                      final proxy = group.items[index];
                      return ProxyTile(
                        proxy,
                        index == 0 ? '' : viewModel.proxiesList?[index - 1] ?? '',
                        selected: group.selected == proxy.tag,
                        onSelect: () async {
                          if (selectActiveProxyMutation.state.isInProgress) {
                            return;
                          }
                          // 在异步操作前保存Navigator状态
                          final navigator = Navigator.of(context);
                          // 先调用setFuture，然后在then中将选中的代理名称返回上一页
                          final future = notifier.changeProxy(
                            group.tag,
                            proxy.tag,
                          );
                          selectActiveProxyMutation.setFuture(future);
                          future.then((_) {
                            if (navigator.canPop()) {
                              // 返回选中的代理名称到前一页
                              navigator.pop(proxy.name);
                            }
                          });
                        },
                      );
                    },
                    itemCount: group.items.length,
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async => notifier.urlTest(group.tag),
            tooltip: t.proxies.delayTestTooltip,
            child: const Icon(FluentIcons.flash_24_filled),
          ),
        );

      case AsyncError(:final error):
        return Scaffold(
          appBar: appBar,
          body: CustomScrollView(
            slivers: [
              SliverErrorBodyPlaceholder(
                t.presentShortError(error),
                icon: null,
              ),
            ],
          ),
        );

      case AsyncLoading():
        return Scaffold(
          appBar: appBar,
          body: const CustomScrollView(
            slivers: [
              SliverLoadingBodyPlaceholder(),
            ],
          ),
        );

      // TODO: remove
      default:
        return const Scaffold();
    }
  }
}
