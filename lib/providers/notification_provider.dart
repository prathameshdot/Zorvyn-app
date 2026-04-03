import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/notification_model.dart';
import 'package:zorvyn/services/api_service.dart';

class NotificationListState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationListState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationListState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get unreadCount => notifications.where((n) => !n.read).length;
}

class NotificationNotifier extends StateNotifier<NotificationListState> {
  final ApiService _api;

  NotificationNotifier(this._api) : super(const NotificationListState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/notifications');
      final list = (res['notifications'] ?? res['data'] ?? [])
          .map<AppNotification>((e) => AppNotification.fromJson(e))
          .toList();
      state = NotificationListState(notifications: list);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load notifications.');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.put('/notifications/$id/read');
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          if (n.id == id) {
            return AppNotification(
              id: n.id,
              userId: n.userId,
              title: n.title,
              message: n.message,
              dialog: n.dialog,
              read: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.put('/notifications/read-all');
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          return AppNotification(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            dialog: n.dialog,
            read: true,
            createdAt: n.createdAt,
          );
        }).toList(),
      );
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _api.delete('/notifications/$id');
      state = state.copyWith(
        notifications: state.notifications.where((n) => n.id != id).toList(),
      );
    } catch (_) {}
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationListState>((ref) {
  return NotificationNotifier(ref.read(apiServiceProvider));
});
