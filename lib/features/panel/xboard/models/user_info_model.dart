class UserInfo {
  final String email;
  final double transferEnable;
  final int? lastLoginAt; // 允许为 null
  final int createdAt;
  final bool banned; // 账户状态, true: 被封禁, false: 正常
  final bool remindExpire;
  final bool remindTraffic;
  final int? expiredAt; // 允许为 null
  final double balance; // 消费余额
  final double commissionBalance; // 剩余佣金余额
  final int planId;
  final double? discount; // 允许为 null
  final double? commissionRate; // 允许为 null
  final String? telegramId; // 允许为 null
  final String uuid;
  final String avatarUrl;
  final int? inviteNums; // 邀请注册人数
  final int? inviteType; // 邀请类型（1:返流量   2:返时长）
  final int? inviteFlow; // 白嫖总流量（邀请类型等于1时显示）
  final int? inviteHour; // 白嫖总时长（邀请类型等于2时显示）
  final int? inviteDaiNums; // 代确认人数
  final String? stopInvite; // 如果这个字段等于0就显示邀请与流量统计如果是1就不显示
  final String? setIntiveFlow; // 每人奖励流量（邀请类型等于1时显示），
  final String? setIntiveHour; // 每人奖励时长（邀请类型等于2时显示）

  UserInfo({
    required this.email,
    required this.transferEnable,
    this.lastLoginAt,
    required this.createdAt,
    required this.banned,
    required this.remindExpire,
    required this.remindTraffic,
    this.expiredAt,
    required this.balance,
    required this.commissionBalance,
    required this.planId,
    this.discount,
    this.commissionRate,
    this.telegramId,
    required this.uuid,
    required this.avatarUrl,
    this.inviteNums,
    this.inviteType,
    this.inviteFlow,
    this.inviteHour,
    this.inviteDaiNums,
    this.stopInvite,
    this.setIntiveFlow,
    this.setIntiveHour,
  });

  // 从 JSON 创建 UserInfo 实例
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      // 字符串字段，如果为 null，返回空字符串
      email: json['email'] as String? ?? '',

      // 转换为 double，如果为 null，返回 0.0
      transferEnable: (json['transfer_enable'] as num?)?.toDouble() ?? 0.0,

      // 时间字段可以为 null
      lastLoginAt: json['last_login_at'] as int?,

      // 确保 createdAt 为 int，并提供默认值
      createdAt: json['created_at'] as int? ?? 0,

      // 处理布尔值
      // banned: (json['banned'] as int? ?? 0) == 1,
      // remindExpire: (json['remind_expire'] as int? ?? 0) == 1,
      // remindTraffic: (json['remind_traffic'] as int? ?? 0) == 1,

      banned: json["banned"] as bool,
      remindExpire: json['remind_expire'] as bool,
      remindTraffic: json['remind_traffic'] as bool,

      // 允许 expiredAt 为 null
      expiredAt: json['expired_at'] as int?,

      // 转换 balance 为 double，并处理 null
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,

      // 转换 commissionBalance 为 double，并处理 null
      commissionBalance:
          (json['commission_balance'] as num?)?.toDouble() ?? 0.0,

      // 保证 planId 是 int，提供默认值 0
      planId: json['plan_id'] as int? ?? 0,

      // 允许 discount 和 commissionRate 为 null
      discount: (json['discount'] as num?)?.toDouble(),
      commissionRate: (json['commission_rate'] as num?)?.toDouble(),

      // 允许 telegramId 为 null
      telegramId: json['telegram_id'] as String?,

      // uuid 和 avatarUrl，如果为 null 返回空字符串
      uuid: json['uuid'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      inviteNums: json['invite_nums'] as int? ?? 0,
      inviteType: json['invite_type'] as int? ?? 0,
      inviteFlow: json['invite_flow'] as int?,
      inviteHour: json['invite_hour'] as int?,
      inviteDaiNums: json['invite_dai_nums'] as int?,
      stopInvite: json['stop_invite'] as String?,
      setIntiveFlow: json['set_intive_flow'] as String?,
      setIntiveHour: json['set_intive_hour'] as String?,
    );
  }
}
