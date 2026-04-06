import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/goal_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(goalNotifierProvider.notifier).loadGoals());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: () => context.go('/goals/add'),
            child: const Icon(CupertinoIcons.plus_circle_fill, color: AppTheme.primary, size: 28),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : state.error != null
              ? ErrorDisplay(message: state.error!, onRetry: () => ref.read(goalNotifierProvider.notifier).loadGoals())
              : state.goals.isEmpty
                  ? EmptyState(
                      icon: CupertinoIcons.flag,
                      title: 'No goals yet',
                      subtitle: 'Set your first financial goal',
                      buttonText: 'Add Goal',
                      onButtonPressed: () => context.go('/goals/add'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.read(goalNotifierProvider.notifier).loadGoals(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.goals.length,
                        itemBuilder: (context, index) {
                          final goal = state.goals[index];
                          final progress = goal.progress;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ClayCard(
                              onTap: () => context.go('/goals/${goal.id}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(CupertinoIcons.flag_fill, size: 20, color: AppTheme.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(goal.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimaryC(context))),
                                            const SizedBox(height: 2),
                                            Text(
                                              goal.goalType.replaceAll('_', ' '),
                                              style: TextStyle(fontSize: 12, color: AppTheme.textHintC(context)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: goal.status == 'completed'
                                              ? AppTheme.success.withValues(alpha: 0.12)
                                              : AppTheme.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          goal.status.isEmpty ? 'Unknown' : goal.status[0].toUpperCase() + goal.status.substring(1),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: goal.status == 'completed' ? AppTheme.success : AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      backgroundColor: AppTheme.dividerC(context),
                                      color: progress >= 1.0 ? AppTheme.success : AppTheme.primary,
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${formatAmount(goal.currentAmount)} / ${formatAmount(goal.targetAmount)}',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondaryC(context)),
                                      ),
                                      Text(
                                        '${(progress * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: progress >= 1.0 ? AppTheme.success : AppTheme.primary,
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
