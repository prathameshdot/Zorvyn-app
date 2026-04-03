import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/insights_model.dart';
import 'package:zorvyn/services/api_service.dart';

final insightsOverviewProvider =
    FutureProvider.autoDispose<InsightsOverview>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/insights/overview');
    return InsightsOverview.fromJson(res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load insights.');
  }
});

final insightsComparisonProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.get('/insights/comparison');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load comparison.');
  }
});

final spendingPatternsProvider =
    FutureProvider.autoDispose<SpendingPattern>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/insights/patterns');
    return SpendingPattern.fromJson(res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load patterns.');
  }
});

final financialHealthProvider =
    FutureProvider.autoDispose<FinancialHealth>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/insights/health');
    return FinancialHealth.fromJson(res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load financial health.');
  }
});
