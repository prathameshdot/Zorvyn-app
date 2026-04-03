class Goal {
  final String? id;
  final String? userId;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final String? category;
  final String status; // active | completed | paused
  final String? deadline;
  final String? priority; // low | medium | high
  final String goalType; // savings | expense_limit | savings_streak | income_target
  final String? createdAt;

  Goal({
    this.id,
    this.userId,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    this.category,
    this.status = 'active',
    this.deadline,
    this.priority,
    required this.goalType,
    this.createdAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      name: json['name'] ?? '',
      description: json['description']?.toString(),
      targetAmount: (json['target_amount'] ?? json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['current_amount'] ?? json['currentAmount'] ?? 0).toDouble(),
      category: json['category']?.toString(),
      status: json['status'] ?? 'active',
      deadline: json['deadline']?.toString(),
      priority: json['priority']?.toString(),
      goalType: json['goal_type'] ?? json['goalType'] ?? 'savings',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'target_amount': targetAmount,
      'goal_type': goalType,
    };
    if (description != null && description!.isNotEmpty) map['description'] = description;
    if (category != null) map['category'] = category;
    if (deadline != null) map['deadline'] = deadline;
    if (priority != null) map['priority'] = priority;
    if (status != 'active') map['status'] = status;
    return map;
  }

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
}
