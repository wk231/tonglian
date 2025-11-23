import 'package:flutter/material.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 2秒后根据用户状态决定跳转到哪个页面
    Future.delayed(const Duration(seconds: 2), () {
      // 使用routerProvider来导航，避免在initState中直接使用context
      if (mounted) {
        final router = ref.read(routerProvider);
        final hasSeenIntro = ref.read(Preferences.introCompleted);
        
        // 根据用户是否已看过intro页面决定跳转目标
        // 如果已看过intro，直接跳转到LoginPage
        // 否则跳转到IntroPage
        final targetRoute = hasSeenIntro 
          ? const LoginRoute().location 
          : const IntroRoute().location;
          
        router.pushReplacement(targetRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splash_bg.png',
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
