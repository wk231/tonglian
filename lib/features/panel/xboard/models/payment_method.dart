class PaymentMethod {
  final int? id;
  final String? name;
  final String? payment;
  final String? icon;
  final int? handlingFeeFixed;
  final String? handlingFeePercent;

  PaymentMethod({
    this.id,
    this.name,
    this.payment,
    this.icon,
    this.handlingFeeFixed,
    this.handlingFeePercent,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int?,
      name: json['name'] as String?,
      payment: json['payment'] as String?,
      icon: json['icon'] as String?,
      handlingFeeFixed: json['handling_fee_fixed'] as int?,
      handlingFeePercent: json['handling_fee_percent'] as String?,
    );
  }
}
