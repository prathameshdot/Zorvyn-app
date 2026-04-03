import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/tip_model.dart';
import 'package:zorvyn/services/api_service.dart';

final tipsProvider = FutureProvider.autoDispose<List<Tip>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/tips');
    return (res['tips'] ?? res['data'] ?? [])
        .map<Tip>((e) => Tip.fromJson(e))
        .toList();
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load tips.');
  }
});

final dailyTipsProvider = FutureProvider.autoDispose<List<Tip>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/tips/daily');
    return (res['tips'] ?? res['data'] ?? [])
        .map<Tip>((e) => Tip.fromJson(e))
        .toList();
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load daily tips.');
  }
});

final bookmarkedTipsProvider = FutureProvider.autoDispose<List<Tip>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/tips/bookmarks');
    return (res['bookmarks'] ?? res['tips'] ?? res['data'] ?? [])
        .map<Tip>((e) => Tip.fromJson(e))
        .toList();
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load bookmarks.');
  }
});

final personalizedAdviceProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.get('/tips/advice');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load advice.');
  }
});

Future<String?> bookmarkTip(ApiService api, int tipId) async {
  try {
    await api.post('/tips/bookmark', data: {'tipId': tipId});
    return null;
  } on AppException catch (e) {
    return e.message;
  } catch (_) {
    return 'Failed to bookmark tip.';
  }
}

Future<String?> removeBookmark(ApiService api, String bookmarkId) async {
  try {
    await api.delete('/tips/bookmarks/$bookmarkId');
    return null;
  } on AppException catch (e) {
    return e.message;
  } catch (_) {
    return 'Failed to remove bookmark.';
  }
}
