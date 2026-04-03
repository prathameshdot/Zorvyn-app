import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/auth_provider.dart';
import 'package:zorvyn/providers/dashboard_provider.dart';
import 'package:zorvyn/providers/transaction_provider.dart';
import 'package:zorvyn/widgets/brand_logo.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionNotifierProvider.notifier).loadTransactions(limit: 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final dashboard = ref.watch(dashboardProvider);
    final txState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            await ref.read(transactionNotifierProvider.notifier).loadTransactions(limit: 5);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandLogo(size: 48),
                        const SizedBox(height: 10),
                        Text(
                          'Hello, ${auth.user?.name ?? 'there'}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your financial overview',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/notifications'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: AppTheme.clayCard(radius: 14),
                            child: const Icon(CupertinoIcons.bell, size: 20, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Balance card
                dashboard.when(
                  data: (data) => _BalanceCard(data: data),
                  loading: () => ClayCard(
                    child: SizedBox(
                      height: 120,
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                  ),
                  error: (e, _) => ClayCard(
                    child: ErrorDisplay(
                      message: 'Could not load dashboard',
                      onRetry: () => ref.invalidate(dashboardProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick actions
                SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuickAction(
                      icon: CupertinoIcons.plus_circle,
                      label: 'Add\nTransaction',
                      color: AppTheme.primary,
                      onTap: () => context.go('/transactions/add'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: CupertinoIcons.flag,
                      label: 'Goals',
                      color: AppTheme.success,
                      onTap: () => context.go('/goals'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: CupertinoIcons.chart_pie,
                      label: 'Budgets',
                      color: AppTheme.warning,
                      onTap: () => context.go('/budgets'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: CupertinoIcons.game_controller,
                      label: 'Challenges',
                      color: AppTheme.secondary,
                      onTap: () => context.go('/challenges'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent transactions
                SectionHeader(
                  title: 'Recent Transactions',
                  actionText: 'See All',
                  onAction: () => context.go('/transactions'),
                ),
                const SizedBox(height: 12),
                if (txState.isLoading)
                  const Center(child: CupertinoActivityIndicator())
                else if (txState.error != null)
                  ErrorDisplay(message: txState.error!)
                else if (txState.transactions.isEmpty)
                  const EmptyState(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    title: 'No transactions yet',
                    subtitle: 'Start tracking your finances',
                  )
                else
                  ...txState.transactions.map((tx) => Padding(
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
                                  tx.category.replaceAll('_', ' ').toUpperCase().substring(0, 1) +
                                      tx.category.replaceAll('_', ' ').substring(1),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
                                ),
                                if (tx.description != null && tx.description!.isNotEmpty)
                                  Text(
                                    tx.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                                  ),
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
                  )),

                const SizedBox(height: 20),

                // Explore section
                SectionHeader(title: 'Explore'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ExploreCard(
                        icon: CupertinoIcons.lightbulb,
                        label: 'Tips',
                        color: AppTheme.warning,
                        onTap: () => context.go('/tips'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ExploreCard(
                        icon: CupertinoIcons.chart_bar_alt_fill,
                        label: 'Leaderboard',
                        color: AppTheme.primary,
                        onTap: () => context.go('/leaderboard'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final dynamic data;
  const _BalanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF8B83FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            formatAmount(data.balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _BalanceStat(label: 'Income', amount: data.monthlyIncome, icon: CupertinoIcons.arrow_down, color: Colors.greenAccent),
              const SizedBox(width: 24),
              _BalanceStat(label: 'Expenses', amount: data.monthlyExpenses, icon: CupertinoIcons.arrow_up, color: Colors.redAccent),
              const SizedBox(width: 24),
              _BalanceStat(label: 'Saved', amount: data.monthlySavings, icon: CupertinoIcons.bookmark, color: Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _BalanceStat({required this.label, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(formatAmount(amount), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClayCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ExploreCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
