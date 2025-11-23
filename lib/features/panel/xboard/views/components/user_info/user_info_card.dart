// views/user_info_card.dart
import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/user_info_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/user_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/user_info_viewmodel.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userInfoViewModelProvider = ChangeNotifierProvider((ref) {
  return UserInfoViewModel(userService: UserService());
});

class UserInfoCard extends ConsumerStatefulWidget {
  const UserInfoCard({super.key});

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends ConsumerState<UserInfoCard> {
  @override
  void initState() {
    super.initState();
    // 使用 Future 来确保不会在 widget 构建过程中修改状态
    Future(() {
      ref.read(userInfoViewModelProvider).fetchUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(userInfoViewModelProvider);
    final t = ref.watch(translationsProvider);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.userInfo != null) {
      return _buildUserInfoCard(viewModel.userInfo!, t);
    } else {
      return const SizedBox(); // 如果没有数据，则返回空占位
    }
  }

  Widget _buildUserInfoCard(UserInfo userInfo, Translations t) {
    final activeProfile = ref.watch(activeProfileProvider);
    return Center(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/mine_status.png'), fit: BoxFit.cover)),
            width: 116,
            height: 116,
            child: Text(userInfo.banned ? t.userInfo.banned : t.userInfo.active, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(userInfo.email, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('目前是${t.userInfo.plan}${userInfo.planId}', style: const TextStyle(color: Color(0xFF7B7B7C), fontSize: 14)),
          const SizedBox(height: 10),
          switch (activeProfile) {
            AsyncData(value: final profile?) => ProfileSubscriptionInfo((profile as RemoteProfileEntity).subInfo!),
            _ => const SizedBox(),
          }
        ],
      ),
    );
  }
}
