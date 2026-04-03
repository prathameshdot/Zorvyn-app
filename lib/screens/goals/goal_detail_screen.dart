import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/goal_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  final _progressCtrl = TextEditingController();

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  Future<void> _addProgress() async {
    final amount = double.tryParse(_progressCtrl.text.trim());
    if (amount == null || amount <= 0) {
      showAppSnackBar(context, 'Enter a valid amount', isError: true);
      return;
    }
    final error = await ref.read(goalNotifierProvider.notifier).addProgress(widget.goalId, amount);
    if (!mounted) return;
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      showAppSnackBar(context, 'Progress added!');
      _progressCtrl.clear();
      ref.invalidate(goalDetailProvider(widget.goalId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(goalDetailProvider(widget.goalId));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 8),
            onPressed: () => context.go('/goals/edit/${widget.goalId}'),
            child: const Icon(CupertinoIcons.pencil, color: AppTheme.primary),
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Delete Goal',
                message: 'Are you sure?',
                confirmText: 'Delete',
                isDestructive: true,
              );
              if (!confirmed || !context.mounted) return;
              final error = await ref.read(goalNotifierProvider.notifier).deleteGoal(widget.goalId);
              if (!context.mounted) return;
              if (error != null) {
                showAppSnackBar(context, error, isError: true);
              } else {
                showAppSnackBar(context, 'Goal deleted');
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
          message: friendlyError(e, fallback: 'Could not load goal details'),
          onRetry: () => ref.invalidate(goalDetailProvider(widget.goalId)),
        ),
        data: (goal) {
          final progress = goal.progress;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hero card
                ClayCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(CupertinoIcons.flag_fill, size: 36, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(goal.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        '${formatAmount(goal.currentAmount)} of ${formatAmount(goal.targetAmount)}',
                        style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: AppTheme.divider,
                          color: progress >= 1.0 ? AppTheme.success : AppTheme.primary,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: progress >= 1.0 ? AppTheme.success : AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details card
                ClayCard(
                  child: Column(
                    children: [
                      _Row(label: 'Type', value: goal.goalType.replaceAll('_', ' ')),
                      if (goal.priority != null) ...[
                        const Divider(height: 24, color: AppTheme.divider),
                        _Row(label: 'Priority', value: goal.priority!),
                      ],
                      const Divider(height: 24, color: AppTheme.divider),
                      _Row(label: 'Status', value: goal.status),
                      if (goal.deadline != null) ...[
                        const Divider(height: 24, color: AppTheme.divider),
                        _Row(label: 'Deadline', value: goal.deadline!.split('T').first),
                      ],
                      if (goal.description != null && goal.description!.isNotEmpty) ...[
                        const Divider(height: 24, color: AppTheme.divider),
                        _Row(label: 'Description', value: goal.description!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Add progress
                if (goal.status != 'completed') ...[
                  SectionHeader(title: 'Add Progress'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClayTextField(
                          controller: _progressCtrl,
                          hintText: 'Amount',
                          prefixIcon: CupertinoIcons.money_dollar,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 54,
                        child: CupertinoButton(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          onPressed: _addProgress,
                          child: const Icon(CupertinoIcons.plus, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Flexible(
          child: Text(
            value[0].toUpperCase() + value.substring(1),
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
