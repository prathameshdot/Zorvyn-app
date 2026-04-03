import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/budget_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(budgetNotifierProvider.notifier).loadBudgets());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: () => context.go('/budgets/add'),
            child: const Icon(CupertinoIcons.plus_circle_fill, color: AppTheme.primary, size: 28),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : state.error != null
              ? ErrorDisplay(message: state.error!, onRetry: () => ref.read(budgetNotifierProvider.notifier).loadBudgets())
              : state.budgets.isEmpty
                  ? EmptyState(
                      icon: CupertinoIcons.chart_pie,
                      title: 'No budgets yet',
                      subtitle: 'Create budgets to track spending by category',
                      buttonText: 'Add Budget',
                      onButtonPressed: () => context.go('/budgets/add'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.read(budgetNotifierProvider.notifier).loadBudgets(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.budgets.length,
                        itemBuilder: (context, index) {
                          final budget = state.budgets[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ClayCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: getCategoryColor(budget.category).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(getCategoryIcon(budget.category), size: 20, color: getCategoryColor(budget.category)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              budget.category[0].toUpperCase() + budget.category.substring(1),
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                                            ),
                                            Text(budget.period, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                          ],
                                        ),
                                      ),
                                      // Edit and delete
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size.square(24),
                                        onPressed: () => context.go('/budgets/edit/${budget.id}'),
                                        child: const Icon(CupertinoIcons.pencil, size: 18, color: AppTheme.textHint),
                                      ),
                                      const SizedBox(width: 4),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size.square(24),
                                        onPressed: () async {
                                          final confirmed = await showConfirmDialog(
                                            context,
                                            title: 'Delete Budget',
                                            message: 'Remove this budget?',
                                            confirmText: 'Delete',
                                            isDestructive: true,
                                          );
                                          if (!confirmed) return;
                                          final error = await ref.read(budgetNotifierProvider.notifier).deleteBudget(budget.id!);
                                          if (context.mounted && error != null) {
                                            showAppSnackBar(context, error, isError: true);
                                          }
                                        },
                                        child: const Icon(CupertinoIcons.trash, size: 18, color: AppTheme.accent),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  // Usage bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: budget.usage.clamp(0.0, 1.0),
                                      backgroundColor: AppTheme.divider,
                                      color: budget.isOverBudget ? AppTheme.accent : AppTheme.success,
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${formatAmount(budget.spentAmount)} / ${formatAmount(budget.limitAmount)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        budget.isOverBudget ? 'Over budget!' : '${formatAmount(budget.remaining)} left',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: budget.isOverBudget ? AppTheme.accent : AppTheme.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
