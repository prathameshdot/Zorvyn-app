import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/leaderboard_model.dart';
import 'package:zorvyn/services/api_service.dart';

final leaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/leaderboard');
    return (res['leaderboard'] ?? res['rankings'] ?? res['data'] ?? [])
        .map<LeaderboardEntry>((e) => LeaderboardEntry.fromJson(e))
        .toList();
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load leaderboard.');
  }
});

final myRankProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.get('/leaderboard/me');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load your rank.');
  }
});
