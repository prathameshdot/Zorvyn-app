import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/transaction_model.dart';
import 'package:zorvyn/services/api_service.dart';

class TransactionListState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionListState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionListState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionListState> {
  final ApiService _api;

  TransactionNotifier(this._api) : super(const TransactionListState());

  Future<void> loadTransactions({String? type, String? category, int limit = 20, int offset = 0}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final params = <String, dynamic>{'limit': limit, 'offset': offset};
      if (type != null) params['type'] = type;
      if (category != null) params['category'] = category;

      final res = await _api.get('/transactions', queryParams: params);
      final list = (res['transactions'] ?? res['data'] ?? [])
          .map<Transaction>((e) => Transaction.fromJson(e))
          .toList();
      state = TransactionListState(transactions: list);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load transactions.');
    }
  }

  Future<String?> createTransaction(Map<String, dynamic> data) async {
    try {
      await _api.post('/transactions', data: data);
      await loadTransactions();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to create transaction.';
    }
  }

  Future<String?> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      await _api.put('/transactions/$id', data: data);
      await loadTransactions();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to update transaction.';
    }
  }

  Future<String?> deleteTransaction(String id) async {
    try {
      await _api.delete('/transactions/$id');
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.id != id).toList(),
      );
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Failed to delete transaction.';
    }
  }
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionListState>((ref) {
  return TransactionNotifier(ref.read(apiServiceProvider));
});

final transactionDetailProvider =
    FutureProvider.autoDispose.family<Transaction, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/transactions/$id');
    return Transaction.fromJson(res['transaction'] ?? res);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load transaction details.');
  }
});

final transactionSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.get('/transactions/summary');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load summary.');
  }
});

final categoryBreakdownProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/transactions/breakdown/category');
    return List<Map<String, dynamic>>.from(res['breakdown'] ?? res['data'] ?? []);
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load breakdown.');
  }
});

final expenseTrendsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.get('/transactions/trends/expenses');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load expense trends.');
  }
});
