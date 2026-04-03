class AppConstants {
  AppConstants._();

  static const String appName = 'Zorvyn';
  static const String baseUrl = 'https://zorvyn-backend-9536.onrender.com';
  static const String apiBase = '$baseUrl/api/v1';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;

  // Categories
  static const List<String> expenseCategories = [
    'food',
    'transport',
    'shopping',
    'entertainment',
    'bills',
    'health',
    'education',
    'travel',
    'groceries',
    'rent',
    'utilities',
    'subscriptions',
    'other',
  ];

  static const List<String> incomeCategories = [
    'salary',
    'freelance',
    'investment',
    'business',
    'rental',
    'gift',
    'refund',
    'other',
  ];

  static const List<String> goalTypes = [
    'savings',
    'expense_limit',
    'income_target',
    'savings_streak',
  ];

  static const List<String> budgetPeriods = [
    'weekly',
    'monthly',
  ];
}
