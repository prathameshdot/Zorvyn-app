import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/challenge_model.dart';
import 'package:zorvyn/services/api_service.dart';

final challengesProvider = FutureProvider.autoDispose<List<Challenge>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/challenges');
    return (res['challenges'] ?? res['data'] ?? [])
        .map<Challenge>((e) => Challenge.fromJson(e))
        .toList();
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load challenges.');
  }
});

final myChallengesProvider = FutureProvider.autoDispose<List<UserChallenge>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/challenges/me');
    return (res['challenges'] ?? res['data'] ?? [])
        .map<UserChallenge>((e) => UserChallenge.fromJson(e))
        .toList();
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load your challenges.');
  }
});

final userXpProvider = FutureProvider.autoDispose<UserXp>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/challenges/xp');
    return UserXp.fromJson(res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load XP.');
  }
});

final savingsStreakProvider = FutureProvider.autoDispose<SavingsStreak>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/challenges/streak');
    return SavingsStreak.fromJson(res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load streak.');
  }
});

Future<String?> joinChallenge(ApiService api, String challengeId) async {
  try {
    await api.post('/challenges/join', data: {'challengeId': challengeId});
    return null;
  } on AppException catch (e) {
    return e.message;
  } catch (_) {
    return 'Failed to join challenge.';
  }
}

Future<String?> checkinChallenge(ApiService api, String id) async {
  try {
    await api.post('/challenges/$id/checkin');
    return null;
  } on AppException catch (e) {
    return e.message;
  } catch (_) {
    return 'Failed to check in.';
  }
}

Future<String?> abandonChallenge(ApiService api, String id) async {
  try {
    await api.post('/challenges/$id/abandon');
    return null;
  } on AppException catch (e) {
    return e.message;
  } catch (_) {
    return 'Failed to abandon challenge.';
  }
}
