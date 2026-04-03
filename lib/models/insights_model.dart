class DashboardData {
  final double balance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double monthlySavings;

  DashboardData({
    this.balance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpenses = 0,
    this.monthlySavings = 0,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['dashboard'] ?? json;
    return DashboardData(
      balance: (data['balance'] ?? data['currentBalance'] ?? 0).toDouble(),
      monthlyIncome: (data['monthlyIncome'] ?? data['monthly_income'] ?? data['income'] ?? 0).toDouble(),
      monthlyExpenses: (data['monthlyExpenses'] ?? data['monthly_expenses'] ?? data['expenses'] ?? 0).toDouble(),
      monthlySavings: (data['monthlySavings'] ?? data['monthly_savings'] ?? data['savings'] ?? 0).toDouble(),
    );
  }
}

class InsightsOverview {
  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final List<CategoryBreakdown> topCategories;
  final List<CategoryBreakdown> allCategories;

  InsightsOverview({
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.netAmount = 0,
    this.topCategories = const [],
    this.allCategories = const [],
  });

  factory InsightsOverview.fromJson(Map<String, dynamic> json) {
    final data = json['overview'] ?? json;
    return InsightsOverview(
      totalIncome: (data['totalIncome'] ?? data['total_income'] ?? 0).toDouble(),
      totalExpenses: (data['totalExpenses'] ?? data['total_expenses'] ?? 0).toDouble(),
      netAmount: (data['netAmount'] ?? data['net_amount'] ?? data['net'] ?? 0).toDouble(),
      topCategories: (data['topExpenses'] ?? data['top_categories'] ?? [])
          .map<CategoryBreakdown>((e) => CategoryBreakdown.fromJson(e))
          .toList(),
      allCategories: (data['categoryBreakdown'] ?? data['categories'] ?? [])
          .map<CategoryBreakdown>((e) => CategoryBreakdown.fromJson(e))
          .toList(),
    );
  }
}

class CategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final int count;

  CategoryBreakdown({
    required this.category,
    this.amount = 0,
    this.percentage = 0,
    this.count = 0,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] ?? json['name'] ?? 'other',
      amount: (json['amount'] ?? json['total'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? json['percent'] ?? 0).toDouble(),
      count: (json['count'] ?? json['transactions'] ?? 0).toInt(),
    );
  }
}

class FinancialHealth {
  final int score;
  final String grade;
  final String status;
  final Map<String, dynamic> metrics;

  FinancialHealth({
    this.score = 0,
    this.grade = 'N/A',
    this.status = 'Unknown',
    this.metrics = const {},
  });

  factory FinancialHealth.fromJson(Map<String, dynamic> json) {
    final data = json['health'] ?? json;
    return FinancialHealth(
      score: (data['score'] ?? 0).toInt(),
      grade: data['grade']?.toString() ?? 'N/A',
      status: data['status']?.toString() ?? 'Unknown',
      metrics: Map<String, dynamic>.from(data['metrics'] ?? {}),
    );
  }
}

class SpendingPattern {
  final double avgDailyExpense;
  final double avgDailyIncome;
  final String mostActiveDay;
  final String mostActiveCategory;
  final List<DayPattern> dayPatterns;

  SpendingPattern({
    this.avgDailyExpense = 0,
    this.avgDailyIncome = 0,
    this.mostActiveDay = '',
    this.mostActiveCategory = '',
    this.dayPatterns = const [],
  });

  factory SpendingPattern.fromJson(Map<String, dynamic> json) {
    final data = json['patterns'] ?? json;
    return SpendingPattern(
      avgDailyExpense: (data['avgDailyExpense'] ?? data['avg_daily_expense'] ?? 0).toDouble(),
      avgDailyIncome: (data['avgDailyIncome'] ?? data['avg_daily_income'] ?? 0).toDouble(),
      mostActiveDay: data['mostActiveDay'] ?? data['most_active_day'] ?? '',
      mostActiveCategory: data['mostActiveCategory'] ?? data['most_active_category'] ?? '',
      dayPatterns: (data['dayOfWeekPatterns'] ?? data['day_patterns'] ?? [])
          .map<DayPattern>((e) => DayPattern.fromJson(e))
          .toList(),
    );
  }
}

class DayPattern {
  final String day;
  final double amount;
  final int count;

  DayPattern({required this.day, this.amount = 0, this.count = 0});

  factory DayPattern.fromJson(Map<String, dynamic> json) {
    return DayPattern(
      day: json['day'] ?? json['dayOfWeek'] ?? '',
      amount: (json['amount'] ?? json['total'] ?? 0).toDouble(),
      count: (json['count'] ?? 0).toInt(),
    );
  }
}
