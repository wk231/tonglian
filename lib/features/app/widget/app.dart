import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hiddify/core/localization/locale_preferences.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/connection/widget/connection_wrapper.dart';
import 'package:hiddify/features/profile/notifier/profiles_update_notifier.dart';
import 'package:hiddify/features/shortcut/shortcut_wrapper.dart';
import 'package:hiddify/features/system_tray/widget/system_tray_wrapper.dart';
import 'package:hiddify/features/window/widget/window_wrapper.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

bool _debugAccessibility = false;

class App extends HookConsumerWidget with PresLogger {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localePreferencesProvider);
    // final upgrader = ref.watch(upgraderProvider);
    ref.listen(foregroundProfilesUpdateNotifierProvider, (_, __) {});
    return WindowWrapper(
      TrayWrapper(
        ShortcutWrapper(
          ConnectionWrapper(
            DynamicColorBuilder(
              builder: (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
                return MaterialApp.router(
                  routerConfig: router,
                  locale: locale.flutterLocale,
                  supportedLocales: AppLocaleUtils.supportedLocales,
                  localizationsDelegates: GlobalMaterialLocalizations.delegates,
                  debugShowCheckedModeBanner: false,
                  themeMode: ThemeMode.light,
                  theme: ThemeData(useMaterial3: false, primaryColor: const Color(0xFF3B7FFE), highlightColor: Colors.transparent, splashColor: Colors.transparent),
                  title: Constants.appName,
                  // 合并的builder函数：配置允许加载HTTP图片并保留原有功能
                  // builder: (context, child) {
                  //   // 允许加载HTTP图片
                  //   final imageCache = PaintingBinding.instance.imageCache;
                  //   imageCache.clear();
                    
                    // 处理应用更新和无障碍工具
                    // child = UpgradeAlert(
                    //   upgrader: upgrader,
                    //   navigatorKey: router.routerDelegate.navigatorKey,
                    //   child: child ?? const SizedBox(),
                    // );
                    // if (kDebugMode && _debugAccessibility) {
                    //   return AccessibilityTools(
                    //     checkFontOverflows: true,
                    //     child: child,
                    //   );
                    // }
                    // return child;
                  // },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
