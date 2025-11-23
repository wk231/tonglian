import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/future_provider.dart';
import 'package:hiddify/features/panel/xboard/utils/logout_dialog.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/invite_code_section.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/reset_subscription_button.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/user_info_card.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/user_invite_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时自动刷新数据
    _refreshData();
  }

  void _refreshData() {
    // 刷新用户信息和邀请码列表
    // ignore: unused_result
    ref.refresh(userTokenInfoProvider);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(t.userInfo.pageTitle, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: _refreshData, // 手动刷新按钮
        //     tooltip: t.general.addToClipboard,
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Image.asset('assets/images/mine_background.png', width: double.infinity, height: 353),
          FutureBuilder(
            // 等待所有需要的数据加载完毕再渲染视图
            future: Future.wait([
              ref.watch(userTokenInfoProvider.future),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 显示加载指示器
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                // 显示错误信息
                return Center(
                  child: Text(
                    '${t.userInfo.fetchUserInfoError} ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                );
              }
              // 如果数据加载成功，显示整个视图
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const UserInfoCard(),
                    const SizedBox(height: 16),
                    const UserInviteCard(),
                    const SizedBox(height: 16),
                    const InviteCodeSection(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => const LogoutDialog(), // 使用 LogoutDialog 组件
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/mine_logout.png', width: 17, height: 17),
                          const SizedBox(width: 6),
                          const Text(
                            '退出登录',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ResetSubscriptionButton(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
