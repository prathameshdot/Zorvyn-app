import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/transaction_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionNotifierProvider.notifier).loadTransactions();
    });
  }

  void _reload() {
    final type = _filterType == 'all' ? null : _filterType;
    ref.read(transactionNotifierProvider.notifier).loadTransactions(type: type);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: () => context.go('/transactions/add'),
            child: const Icon(CupertinoIcons.plus_circle_fill, color: AppTheme.primary, size: 28),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['all', 'income', 'expense'].map((type) {
                final isActive = _filterType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _filterType = type);
                      _reload();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isActive
                            ? null
                            : [BoxShadow(color: AppTheme.cardShadowDark.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(2, 2))],
                      ),
                      child: Text(
                        type[0].toUpperCase() + type.substring(1),
                        style: TextStyle(
                          color: isActive ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // List
          Expanded(
            child: state.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : state.error != null
                    ? ErrorDisplay(message: state.error!, onRetry: _reload)
                    : state.transactions.isEmpty
                        ? EmptyState(
                            icon: CupertinoIcons.arrow_right_arrow_left,
                            title: 'No transactions',
                            subtitle: 'Add your first transaction',
                            buttonText: 'Add Transaction',
                            onButtonPressed: () => context.go('/transactions/add'),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _reload(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: state.transactions.length,
                              itemBuilder: (context, index) {
                                final tx = state.transactions[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ClayCard(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    onTap: () => context.go('/transactions/${tx.id}'),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: getCategoryColor(tx.category).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(getCategoryIcon(tx.category), size: 20, color: getCategoryColor(tx.category)),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.category[0].toUpperCase() + tx.category.substring(1).replaceAll('_', ' '),
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
                                              ),
                                              if (tx.description != null && tx.description!.isNotEmpty)
                                                Text(tx.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                              if (tx.date != null)
                                                Text(tx.date!.split('T').first, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${tx.isIncome ? '+' : '-'}${formatAmount(tx.amount)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: tx.isIncome ? AppTheme.success : AppTheme.accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
