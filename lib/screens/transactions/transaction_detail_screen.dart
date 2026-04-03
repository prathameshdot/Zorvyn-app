import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/transaction_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 8),
            onPressed: () => context.go('/transactions/edit/$transactionId'),
            child: const Icon(CupertinoIcons.pencil, color: AppTheme.primary),
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Delete Transaction',
                message: 'This action cannot be undone.',
                confirmText: 'Delete',
                isDestructive: true,
              );
              if (!confirmed || !context.mounted) return;
              final error = await ref.read(transactionNotifierProvider.notifier).deleteTransaction(transactionId);
              if (!context.mounted) return;
              if (error != null) {
                showAppSnackBar(context, error, isError: true);
              } else {
                showAppSnackBar(context, 'Transaction deleted');
                context.pop();
              }
            },
            child: const Icon(CupertinoIcons.trash, color: AppTheme.accent),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => ErrorDisplay(
          message: friendlyError(e, fallback: 'Could not load transaction'),
          onRetry: () => ref.invalidate(transactionDetailProvider(transactionId)),
        ),
        data: (tx) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Amount hero
              ClayCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: getCategoryColor(tx.category).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(getCategoryIcon(tx.category), size: 36, color: getCategoryColor(tx.category)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${tx.isIncome ? '+' : '-'}${formatAmount(tx.amount)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: tx.isIncome ? AppTheme.success : AppTheme.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: tx.isIncome ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tx.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tx.isIncome ? AppTheme.success : AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details
              ClayCard(
                child: Column(
                  children: [
                    _DetailRow(label: 'Category', value: tx.category[0].toUpperCase() + tx.category.substring(1)),
                    const Divider(height: 24, color: AppTheme.divider),
                    _DetailRow(label: 'Description', value: tx.description ?? 'No description'),
                    if (tx.date != null) ...[
                      const Divider(height: 24, color: AppTheme.divider),
                      _DetailRow(label: 'Date', value: tx.date!.split('T').first),
                    ],
                    if (tx.createdAt != null) ...[
                      const Divider(height: 24, color: AppTheme.divider),
                      _DetailRow(label: 'Created', value: tx.createdAt!.split('T').first),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Flexible(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
