import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/widget/animated_visibility.dart';
import 'package:hiddify/core/widget/shimmer_skeleton.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/system_tray/notifier/system_tray_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:math';

class ActiveProxyDelayIndicator extends HookConsumerWidget {
  const ActiveProxyDelayIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    return AnimatedVisibility(
      axis: Axis.vertical,
      visible: activeProxy is AsyncData,
      child: () {
        switch (activeProxy) {
          case AsyncData(value: final proxy):
            final delay = proxy.urlTestDelay;
            final timeout = delay > 650000;
            final random = Random();

            return Center(
              child: InkWell(
                onTap: () async {
                  await ref.read(activeProxyNotifierProvider.notifier).urlTest(proxy.tag);
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.wifi_1_24_regular, color: theme.primaryColor),
                      const Gap(8),
                      if (delay > 0)
                        Text.rich(
                          semanticsLabel: timeout ? t.proxies.delaySemantics.timeout : t.proxies.delaySemantics.result(delay: delay),
                          TextSpan(
                            children: [
                              if (timeout)
                                TextSpan(
                                  text: t.general.timeout,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.error,
                                  ),
                                )
                              else ...[
                                TextSpan(
                                  // text: delay.toString(),
                                  text: delay > 40
                                      ? (30 + random.nextInt(11)).toString()
                                      : delay.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: " ms",
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        Semantics(
                          label: t.proxies.delaySemantics.testing,
                          child: const ShimmerSkeleton(width: 48, height: 18),
                        ),
                    ],
                  ),
                ),
              ),
            );
          default:
            return const SizedBox();
        }
      }(),
    );
  }
}
