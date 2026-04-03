class Budget {
  final String? id;
  final String? userId;
  final String category;
  final double limitAmount;
  final double spentAmount;
  final String period; // weekly | monthly
  final String? startDate;
  final String? status;
  final String? createdAt;

  Budget({
    this.id,
    this.userId,
    required this.category,
    required this.limitAmount,
    this.spentAmount = 0,
    this.period = 'monthly',
    this.startDate,
    this.status,
    this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      category: json['category'] ?? 'other',
      limitAmount: (json['limit_amount'] ?? json['limitAmount'] ?? json['limit'] ?? 0).toDouble(),
      spentAmount: (json['spent_amount'] ?? json['spentAmount'] ?? json['spent'] ?? 0).toDouble(),
      period: json['period'] ?? 'monthly',
      startDate: json['start_date']?.toString() ?? json['startDate']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'category': category,
      'limit_amount': limitAmount,
      'period': period,
    };
    if (startDate != null) map['start_date'] = startDate;
    return map;
  }

  double get usage => limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.5) : 0.0;
  double get remaining => (limitAmount - spentAmount).clamp(0, double.infinity);
  bool get isOverBudget => spentAmount > limitAmount;
}
