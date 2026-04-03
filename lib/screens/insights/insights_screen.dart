import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/insights_provider.dart';
import 'package:zorvyn/providers/transaction_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Insights')),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['Overview', 'Health', 'Patterns', 'Trends'].asMap().entries.map((entry) {
                final isActive = _tab == entry.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = entry.key),
                    child: Container(
                      margin: EdgeInsets.only(right: entry.key < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isActive
                            ? null
                            : [BoxShadow(color: AppTheme.cardShadowDark.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(2, 2))],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isActive ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                _OverviewTab(),
                _HealthTab(),
                _PatternsTab(),
                _TrendsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(insightsOverviewProvider);

    return overview.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(
        message: friendlyError(e, fallback: 'Could not load insights'),
        onRetry: () => ref.invalidate(insightsOverviewProvider),
      ),
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Income',
                    amount: data.totalIncome,
                    icon: CupertinoIcons.arrow_down_circle,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Expenses',
                    amount: data.totalExpenses,
                    icon: CupertinoIcons.arrow_up_circle,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatCard(
              label: 'Net',
              amount: data.netAmount,
              icon: CupertinoIcons.equal_circle,
              color: data.netAmount >= 0 ? AppTheme.success : AppTheme.accent,
            ),
            const SizedBox(height: 24),

            // Top categories
            if (data.topCategories.isNotEmpty) ...[
              SectionHeader(title: 'Top Expenses'),
              const SizedBox(height: 12),
              ...data.topCategories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClayCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(getCategoryIcon(cat.category), size: 20, color: getCategoryColor(cat.category)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.category[0].toUpperCase() + cat.category.substring(1),
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (cat.percentage / 100).clamp(0.0, 1.0),
                                backgroundColor: AppTheme.divider,
                                color: getCategoryColor(cat.category),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatAmount(cat.amount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
                          Text('${cat.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _HealthTab extends ConsumerWidget {
  const _HealthTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(financialHealthProvider);

    return health.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(
        message: friendlyError(e, fallback: 'Could not load health score'),
        onRetry: () => ref.invalidate(financialHealthProvider),
      ),
      data: (data) {
        final Color scoreColor;
        if (data.score >= 80) {
          scoreColor = AppTheme.success;
        } else if (data.score >= 50) {
          scoreColor = AppTheme.warning;
        } else {
          scoreColor = AppTheme.accent;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Score hero
              ClayCard(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: data.score / 100,
                              strokeWidth: 10,
                              backgroundColor: AppTheme.divider,
                              color: scoreColor,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data.score.toString(),
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: scoreColor),
                              ),
                              Text(data.grade, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.status,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: scoreColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Metrics
              if (data.metrics.isNotEmpty) ...[
                SectionHeader(title: 'Metrics'),
                const SizedBox(height: 12),
                ...data.metrics.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key.replaceAll('_', ' '),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PatternsTab extends ConsumerWidget {
  const _PatternsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patterns = ref.watch(spendingPatternsProvider);

    return patterns.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(
        message: friendlyError(e, fallback: 'Could not load spending patterns'),
        onRetry: () => ref.invalidate(spendingPatternsProvider),
      ),
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.avgDailyExpense > 0) ...[
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Average Daily Spending', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(formatAmount(data.avgDailyExpense), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (data.mostActiveDay.isNotEmpty) ...[
              ClayCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Peak Spending Day', style: TextStyle(color: AppTheme.textSecondary)),
                    Text(data.mostActiveDay, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (data.dayPatterns.isNotEmpty) ...[
              SectionHeader(title: 'By Day of Week'),
              const SizedBox(height: 12),
              ...data.dayPatterns.map((dp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClayCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(dp.day, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: data.dayPatterns.isEmpty ? 0 : (dp.amount / data.dayPatterns.map((p) => p.amount).reduce((a, b) => a > b ? a : b)).clamp(0.0, 1.0),
                            backgroundColor: AppTheme.divider,
                            color: AppTheme.primary,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(formatAmount(dp.amount), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendsTab extends ConsumerWidget {
  const _TrendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trends = ref.watch(expenseTrendsProvider);

    return trends.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(
        message: friendlyError(e, fallback: 'Could not load expense trends'),
        onRetry: () => ref.invalidate(expenseTrendsProvider),
      ),
      data: (data) {
        final monthly = data['monthly'] as List? ?? data['trends'] as List? ?? [];
        final summary = data['summary']?.toString() ?? data['message']?.toString();
        final totalExpenses = data['totalExpenses']?.toString() ?? data['total']?.toString();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (totalExpenses != null) ...[
                ClayCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Total Expenses', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Text(
                        '\$$totalExpenses',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (summary != null && summary.isNotEmpty) ...[
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(summary, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                ),
                const SizedBox(height: 20),
              ],
              if (monthly.isNotEmpty) ...[
                SectionHeader(title: 'Monthly Trends'),
                const SizedBox(height: 10),
                ...monthly.map((item) {
                  final m = item is Map<String, dynamic> ? item : <String, dynamic>{};
                  final month = m['month']?.toString() ?? m['period']?.toString() ?? '';
                  final amount = m['amount'] ?? m['total'] ?? m['expense'] ?? 0;
                  final amountNum = amount is num ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0;
                  final maxAmount = monthly.fold<double>(0, (prev, e) {
                    final a = (e is Map ? (e['amount'] ?? e['total'] ?? e['expense'] ?? 0) : 0);
                    final aNum = a is num ? a.toDouble() : double.tryParse(a.toString()) ?? 0;
                    return aNum > prev ? aNum : prev;
                  });

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClayCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(month, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: maxAmount > 0 ? (amountNum / maxAmount).clamp(0.0, 1.0) : 0,
                                backgroundColor: AppTheme.divider,
                                color: AppTheme.accent,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(formatAmount(amountNum), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              if (totalExpenses == null && monthly.isEmpty && summary == null)
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.entries
                        .where((e) => e.key != 'success')
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                Text(formatAmount(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
