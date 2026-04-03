import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/goal_model.dart';
import 'package:zorvyn/services/api_service.dart';

class GoalListState {
  final List<Goal> goals;
  final bool isLoading;
  final String? error;

  const GoalListState({this.goals = const [], this.isLoading = false, this.error});

  GoalListState copyWith({List<Goal>? goals, bool? isLoading, String? error}) {
    return GoalListState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GoalNotifier extends StateNotifier<GoalListState> {
  final ApiService _api;

  GoalNotifier(this._api) : super(const GoalListState());

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/goals');
      final list = (res['goals'] ?? res['data'] ?? [])
          .map<Goal>((e) => Goal.fromJson(e))
          .toList();
      state = GoalListState(goals: list);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load goals.');
    }
  }

  Future<String?> createGoal(Map<String, dynamic> data) async {
    try {
      await _api.post('/goals', data: data);
      await loadGoals();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to create goal.';
    }
  }

  Future<String?> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      await _api.put('/goals/$id', data: data);
      await loadGoals();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to update goal.';
    }
  }

  Future<String?> deleteGoal(String id) async {
    try {
      await _api.delete('/goals/$id');
      state = state.copyWith(goals: state.goals.where((g) => g.id != id).toList());
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to delete goal.';
    }
  }

  Future<String?> addProgress(String id, double amount) async {
    try {
      await _api.post('/goals/$id/progress', data: {'amount': amount});
      await loadGoals();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to add progress.';
    }
  }
}

final goalNotifierProvider = StateNotifierProvider<GoalNotifier, GoalListState>((ref) {
  return GoalNotifier(ref.read(apiServiceProvider));
});

final goalDetailProvider =
    FutureProvider.autoDispose.family<Goal, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/goals/$id');
    return Goal.fromJson(res['goal'] ?? res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load goal.');
  }
});

final goalStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.get('/goals/stats');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load goal stats.');
  }
});
