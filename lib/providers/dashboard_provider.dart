import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/insights_model.dart';
import 'package:zorvyn/services/api_service.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/auth/dashboard');
    return DashboardData.fromJson(res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load dashboard.');
  }
});
