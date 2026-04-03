import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/leaderboard_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final myRank = ref.watch(myRankProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboard.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => ErrorDisplay(
          message: friendlyError(e, fallback: 'Could not load leaderboard'),
          onRetry: () => ref.invalidate(leaderboardProvider),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: CupertinoIcons.chart_bar_alt_fill,
              title: 'No rankings yet',
              subtitle: 'Complete challenges to earn XP and rank up',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // My rank card
                myRank.when(
                  data: (data) {
                    final rank = data['rank'] ?? data['position'] ?? '-';
                    final score = data['score'] ?? data['xp'] ?? data['totalXp'] ?? 0;
                    return ClayCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B83FF)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(CupertinoIcons.person_fill, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Your Rank', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                Text('#$rank', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Score', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              Text('$score XP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Top 3 podium
                if (entries.length >= 3) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PodiumCard(entry: entries[1], rank: 2, height: 100, color: const Color(0xFFC0C0C0)),
                      const SizedBox(width: 8),
                      _PodiumCard(entry: entries[0], rank: 1, height: 130, color: const Color(0xFFFFD700)),
                      const SizedBox(width: 8),
                      _PodiumCard(entry: entries[2], rank: 3, height: 80, color: const Color(0xFFCD7F32)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Rest of rankings
                ...entries.skip(3).toList().asMap().entries.map((entry) {
                  final e = entry.value;
                  final rank = entry.key + 4;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClayCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              '#$rank',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          ),
                          Text('${e.score} XP', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final dynamic entry;
  final int rank;
  final double height;
  final Color color;
  const _PodiumCard({required this.entry, required this.rank, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textPrimary),
          ),
          Text('${entry.score} XP', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
