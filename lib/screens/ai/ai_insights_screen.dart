import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/ai_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(title: const Text('AI Insights')),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['Analysis', 'Predict', 'Optimize'].asMap().entries.map((entry) {
                final isActive = _tab == entry.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = entry.key),
                    child: Container(
                      margin: EdgeInsets.only(right: entry.key < 2 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : AppTheme.surfaceC(context),
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
                          color: isActive ? Colors.white : AppTheme.textSecondaryC(context),
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
                _AnalysisTab(),
                _PredictTab(),
                _OptimizeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Analysis Tab ──────────────────────────────────────────

class _AnalysisTab extends ConsumerWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(aiAnalyzeProvider);

    return analysis.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(
        message: friendlyError(e, fallback: 'Could not load analysis'),
        onRetry: () => ref.invalidate(aiAnalyzeProvider),
      ),
      data: (data) {
        final summary = data['summary']?.toString() ?? data['analysis']?.toString();
        final insights = data['insights'] as List? ?? [];
        final recommendations = data['recommendations'] as List? ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              ClayCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(CupertinoIcons.chart_bar_fill, size: 24, color: AppTheme.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Spending Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryC(context))),
                          SizedBox(height: 2),
                          Text('AI-powered breakdown of your habits', style: TextStyle(fontSize: 12, color: AppTheme.textHintC(context))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary
              if (summary != null && summary.isNotEmpty) ...[
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(summary, style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryC(context), height: 1.5)),
                ),
                const SizedBox(height: 20),
              ],

              // Insights
              if (insights.isNotEmpty) ...[
                SectionHeader(title: 'Key Insights'),
                const SizedBox(height: 10),
                ...insights.map((item) => _InsightCard(
                  text: item.toString(),
                  icon: CupertinoIcons.lightbulb_fill,
                  color: AppTheme.warning,
                )),
                const SizedBox(height: 16),
              ],

              // Recommendations
              if (recommendations.isNotEmpty) ...[
                SectionHeader(title: 'Recommendations'),
                const SizedBox(height: 10),
                ...recommendations.map((item) => _InsightCard(
                  text: item.toString(),
                  icon: CupertinoIcons.checkmark_seal_fill,
                  color: AppTheme.success,
                )),
              ],

              if (summary == null && insights.isEmpty && recommendations.isEmpty)
                _RawDataCard(data: data),
            ],
          ),
        );
      },
    );
  }
}

// ── Predict Tab ───────────────────────────────────────────

class _PredictTab extends ConsumerWidget {
  const _PredictTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(aiPredictProvider);

    return prediction.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(
        message: friendlyError(e, fallback: 'Could not load predictions'),
        onRetry: () => ref.invalidate(aiPredictProvider),
      ),
      data: (data) {
        final predictedExpense = (data['predictedExpense'] ?? data['predicted_expense'] ?? data['totalPredicted'])?.toString();
        final breakdown = data['breakdown'] as Map<String, dynamic>? ?? data['categories'] as Map<String, dynamic>? ?? {};
        final message = data['message']?.toString() ?? data['prediction']?.toString();
        final confidence = data['confidence']?.toString();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero card
              ClayCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(CupertinoIcons.sparkles, size: 32, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 14),
                    Text('Predicted Next Month', style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryC(context))),
                    const SizedBox(height: 4),
                    if (predictedExpense != null)
                      Text(
                        '\$$predictedExpense',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryC(context)),
                      ),
                    if (confidence != null) ...[
                      const SizedBox(height: 4),
                      Text('Confidence: $confidence', style: TextStyle(fontSize: 12, color: AppTheme.textHintC(context))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Message
              if (message != null && message.isNotEmpty) ...[
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(message, style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryC(context), height: 1.5)),
                ),
                const SizedBox(height: 20),
              ],

              // Breakdown by category
              if (breakdown.isNotEmpty) ...[
                SectionHeader(title: 'Category Breakdown'),
                const SizedBox(height: 10),
                ...breakdown.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(getCategoryIcon(e.key), size: 18, color: getCategoryColor(e.key)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.key.isEmpty ? 'Other' : e.key[0].toUpperCase() + e.key.substring(1),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimaryC(context)),
                          ),
                        ),
                        Text(
                          '\$${e.value}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryC(context)),
                        ),
                      ],
                    ),
                  ),
                )),
              ],

              if (predictedExpense == null && message == null && breakdown.isEmpty)
                _RawDataCard(data: data),
            ],
          ),
        );
      },
    );
  }
}

// ── Optimize Tab ──────────────────────────────────────────

class _OptimizeTab extends ConsumerWidget {
  const _OptimizeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optimize = ref.watch(aiOptimizeBudgetProvider);

    return optimize.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(
        message: friendlyError(e, fallback: 'Could not load optimization tips'),
        onRetry: () => ref.invalidate(aiOptimizeBudgetProvider),
      ),
      data: (data) {
        final suggestions = data['suggestions'] as List? ?? data['optimizations'] as List? ?? [];
        final summary = data['summary']?.toString() ?? data['message']?.toString();
        final potentialSavings = data['potentialSavings']?.toString() ?? data['potential_savings']?.toString();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              ClayCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(CupertinoIcons.wand_stars, size: 24, color: AppTheme.success),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Budget Optimization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryC(context))),
                          const SizedBox(height: 2),
                          if (potentialSavings != null)
                            Text('Potential savings: \$$potentialSavings', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.success))
                          else
                            Text('AI-powered budget recommendations', style: TextStyle(fontSize: 12, color: AppTheme.textHintC(context))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary
              if (summary != null && summary.isNotEmpty) ...[
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(summary, style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryC(context), height: 1.5)),
                ),
                const SizedBox(height: 20),
              ],

              // Suggestions
              if (suggestions.isNotEmpty) ...[
                SectionHeader(title: 'Suggestions'),
                const SizedBox(height: 10),
                ...suggestions.asMap().entries.map((entry) {
                  final item = entry.value;
                  final text = item is Map ? (item['suggestion'] ?? item['description'] ?? item.toString()) : item.toString();
                  return _InsightCard(
                    text: text.toString(),
                    icon: CupertinoIcons.arrow_right_circle_fill,
                    color: AppTheme.primary,
                    index: entry.key + 1,
                  );
                }),
              ],

              if (summary == null && suggestions.isEmpty)
                _RawDataCard(data: data),
            ],
          ),
        );
      },
    );
  }
}

// ── Shared widgets ────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final int? index;
  const _InsightCard({required this.text, required this.icon, required this.color, this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClayCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index != null)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Text('$index', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
              )
            else
              Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryC(context), height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RawDataCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RawDataCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Fallback: display raw key-value pairs if we couldn't parse known fields
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries
            .where((e) => e.key != 'success')
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryC(context), height: 1.4),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
