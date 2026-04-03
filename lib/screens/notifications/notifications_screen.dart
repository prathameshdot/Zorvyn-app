import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/notification_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationNotifierProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            CupertinoButton(
              padding: const EdgeInsets.only(right: 16),
              onPressed: () => ref.read(notificationNotifierProvider.notifier).markAllAsRead(),
              child: const Text('Mark All Read', style: TextStyle(fontSize: 14, color: AppTheme.primary)),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : state.error != null
              ? ErrorDisplay(message: state.error!, onRetry: () => ref.read(notificationNotifierProvider.notifier).loadNotifications())
              : state.notifications.isEmpty
                  ? const EmptyState(
                      icon: CupertinoIcons.bell_slash,
                      title: 'No notifications',
                      subtitle: 'You\'re all caught up!',
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.read(notificationNotifierProvider.notifier).loadNotifications(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = state.notifications[index];
                          return Dismissible(
                            key: Key(notif.id ?? index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(CupertinoIcons.trash, color: AppTheme.accent),
                            ),
                            onDismissed: (_) {
                              if (notif.id != null) {
                                ref.read(notificationNotifierProvider.notifier).deleteNotification(notif.id!);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ClayCard(
                                onTap: () {
                                  if (!notif.read && notif.id != null) {
                                    ref.read(notificationNotifierProvider.notifier).markAsRead(notif.id!);
                                  }
                                },
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: notif.read
                                            ? AppTheme.divider
                                            : AppTheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.bell_fill,
                                        size: 18,
                                        color: notif.read ? AppTheme.textHint : AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notif.title,
                                            style: TextStyle(
                                              fontWeight: notif.read ? FontWeight.w500 : FontWeight.w700,
                                              fontSize: 15,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif.message,
                                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (notif.createdAt != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              notif.createdAt!.split('T').first,
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!notif.read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 6),
                                        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
