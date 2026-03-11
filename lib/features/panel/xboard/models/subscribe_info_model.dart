class SubscribeInfo {
  final Plan? plan;
  final int? planId;

  SubscribeInfo({
    required this.plan,
    required this.planId,

  });

  factory SubscribeInfo.fromJson(Map<String, dynamic> json) {
    return SubscribeInfo(
        plan:json['plan'] != null
            ? Plan.fromJson(json['plan'] as Map<String, dynamic>)
            : null,
      planId: json['plan_id'] as int? ?? 0
    );
  }
}

class Plan {
  final int? id;
  final String? name;

  Plan({
    required this.id,
    required this.name,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id']as int? ?? 0,
      name: json['name']as String? ?? "",
    );
  }
}
