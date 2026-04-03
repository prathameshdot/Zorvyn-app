import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/budget_model.dart';
import 'package:zorvyn/services/api_service.dart';

class BudgetListState {
  final List<Budget> budgets;
  final bool isLoading;
  final String? error;

  const BudgetListState({this.budgets = const [], this.isLoading = false, this.error});

  BudgetListState copyWith({List<Budget>? budgets, bool? isLoading, String? error}) {
    return BudgetListState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetListState> {
  final ApiService _api;

  BudgetNotifier(this._api) : super(const BudgetListState());

  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/budgets');
      final list = (res['budgets'] ?? res['data'] ?? [])
          .map<Budget>((e) => Budget.fromJson(e))
          .toList();
      state = BudgetListState(budgets: list);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load budgets.');
    }
  }

  Future<String?> createBudget(Map<String, dynamic> data) async {
    try {
      await _api.post('/budgets', data: data);
      await loadBudgets();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to create budget.';
    }
  }

  Future<String?> updateBudget(String id, Map<String, dynamic> data) async {
    try {
      await _api.put('/budgets/$id', data: data);
      await loadBudgets();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to update budget.';
    }
  }

  Future<String?> deleteBudget(String id) async {
    try {
      await _api.delete('/budgets/$id');
      state = state.copyWith(budgets: state.budgets.where((b) => b.id != id).toList());
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to delete budget.';
    }
  }
}

final budgetNotifierProvider = StateNotifierProvider<BudgetNotifier, BudgetListState>((ref) {
  return BudgetNotifier(ref.read(apiServiceProvider));
});

final budgetSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.get('/budgets/summary');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load budget summary.');
  }
});
