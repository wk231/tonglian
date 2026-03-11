import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/future_provider.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/user_service.dart';
import 'package:hiddify/features/panel/xboard/services/subscription.dart';
import 'package:hiddify/features/panel/xboard/utils/logout_dialog.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
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
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 页面加载时自动刷新数据（首失败则在1秒后重试一次）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    Future<void> refreshOnce() async {
      await Future.wait([
        ref.refresh(userTokenInfoProvider.future),
        ref.refresh(inviteCodesProvider.future),
      ]);
    }

    try {
      await refreshOnce();
    } catch (_) {
      try {
        Timer(Duration(seconds: 1), () async {
          await refreshOnce();
        });
      } catch (e2) {}
    }
  }

  Future<void> validateExchangeCode(BuildContext context, WidgetRef ref) async {
    final accessToken = await getToken();
    if (accessToken == null) {
      return;
    }
    final result =
        await UserService().exchangeCode(accessToken, controller.text.trim());
    if (result['status'] == 'success') {
      ref.refresh(userTokenInfoProvider);
      Subscription.resetSubscription(context, ref);
    }
    final snackBar = SnackBar(
      content: Text(result['message'].toString()),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(t.userInfo.pageTitle,
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset('assets/images/mine_background.png',
              width: double.infinity, height: 353),
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
                    '${t.userInfo.pageError}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
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
                    Card(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 26, horizontal: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '兑换码',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: '兑换码',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '兑换码不能为空';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      validateExchangeCode(context, ref),
                                  label: Text('兑换'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            const LogoutDialog(), // 使用 LogoutDialog 组件
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
                          Image.asset('assets/images/mine_logout.png',
                              width: 17, height: 17),
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
