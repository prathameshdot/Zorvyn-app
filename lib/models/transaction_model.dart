class Transaction {
  final String? id;
  final String? userId;
  final double amount;
  final String type; // income | expense
  final String category;
  final String? description;
  final String? date;
  final String? createdAt;

  Transaction({
    this.id,
    this.userId,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    this.date,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'expense',
      category: json['category'] ?? 'other',
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'type': type,
      'category': category,
    };
    if (description != null && description!.isNotEmpty) map['description'] = description;
    if (date != null) map['date'] = date;
    return map;
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
