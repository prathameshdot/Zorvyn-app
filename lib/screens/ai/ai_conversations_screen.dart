import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/ai_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class AiConversationsScreen extends ConsumerWidget {
  const AiConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(aiConversationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 8),
            onPressed: () => context.push('/ai-insights'),
            child: const Icon(CupertinoIcons.sparkles, color: AppTheme.primary, size: 24),
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: () => context.go('/ai-chat/new'),
            child: const Icon(CupertinoIcons.plus_circle_fill, color: AppTheme.primary, size: 28),
          ),
        ],
      ),
      body: conversations.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => ErrorDisplay(
          message: friendlyError(e, fallback: 'Could not load conversations'),
          onRetry: () => ref.invalidate(aiConversationsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: CupertinoIcons.chat_bubble_2,
              title: 'No conversations yet',
              subtitle: 'Start chatting with your AI financial advisor',
              buttonText: 'New Chat',
              onButtonPressed: () => context.go('/ai-chat/new'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(aiConversationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final conv = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: Key(conv.conversationId ?? index.toString()),
                    direction: conv.conversationId != null ? DismissDirection.endToStart : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(CupertinoIcons.trash, color: AppTheme.accent),
                    ),
                    confirmDismiss: (_) async {
                      return await showConfirmDialog(
                        context,
                        title: 'Delete Conversation',
                        message: 'This conversation will be permanently deleted.',
                        confirmText: 'Delete',
                        isDestructive: true,
                      );
                    },
                    onDismissed: (_) async {
                      final cid = conv.conversationId;
                      if (cid == null) return;
                      final err = await deleteAiConversation(ref, cid);
                      if (err != null && context.mounted) {
                        showAppSnackBar(context, err, isError: true);
                      }
                    },
                    child: ClayCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () => context.go('/ai-chat/${conv.conversationId}'),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(CupertinoIcons.chat_bubble_fill, size: 20, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conv.preview,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
                                ),
                                Text(
                                  '${conv.messages.length} messages',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                                ),
                              ],
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_right, size: 16, color: AppTheme.textHint),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
