import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/user_info_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/user_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/user_info_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userInfoViewModelProvider = ChangeNotifierProvider((ref) {
  return UserInfoViewModel(userService: UserService());
});

class UserInviteCard extends ConsumerStatefulWidget {
  const UserInviteCard({super.key});

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends ConsumerState<UserInviteCard> {
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
    return userInfo.stopInvite == '1'
        ? const SizedBox()
        : Center(
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('邀请与流量统计', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const Text('邀请注册人数', style: TextStyle(color: Colors.black, fontSize: 14)),
                        const Spacer(),
                        Text('${userInfo.inviteNums}人', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('待确认', style: TextStyle(color: Colors.black, fontSize: 14)),
                        const Spacer(),
                        Text('${userInfo.inviteDaiNums}人', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (userInfo.inviteType == 1)
                      Column(
                        children: [
                          Row(
                            children: [
                              const Text('每人奖励', style: TextStyle(color: Colors.black, fontSize: 14)),
                              const Spacer(),
                              Text('${userInfo.setIntiveFlow}G', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text('白嫖总流量', style: TextStyle(color: Colors.black, fontSize: 14)),
                              const Spacer(),
                              Text('${userInfo.inviteFlow ?? 0}G', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              const Text('每人奖励', style: TextStyle(color: Colors.black, fontSize: 14)),
                              const Spacer(),
                              Text('${userInfo.setIntiveHour}h', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text('白嫖总时长', style: TextStyle(color: Colors.black, fontSize: 14)),
                              const Spacer(),
                              Text('${userInfo.inviteHour ?? 0}h', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
  }
}
