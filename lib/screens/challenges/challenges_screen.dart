import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/challenge_provider.dart';
import 'package:zorvyn/services/api_service.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Challenges')),
      body: Column(
        children: [
          // XP and streak summary
          _XpHeader(),
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['Available', 'My Challenges'].asMap().entries.map((entry) {
                final isActive = _tab == entry.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = entry.key),
                    child: Container(
                      margin: EdgeInsets.only(right: entry.key == 0 ? 8 : 0),
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
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isActive ? Colors.white : AppTheme.textSecondary),
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
              children: const [_AvailableTab(), _MyTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _XpHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(userXpProvider);
    final streak = ref.watch(savingsStreakProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: xp.when(
              data: (data) => ClayCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(CupertinoIcons.star_fill, size: 18, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${data.level}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
                        Text('${data.xp} XP · ${data.tier}', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 52),
              error: (_, _) => const SizedBox(height: 52),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: streak.when(
              data: (data) => ClayCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(CupertinoIcons.flame_fill, size: 18, color: AppTheme.warning),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data.currentStreak} days', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
                        Text('Best: ${data.longestStreak}', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 52),
              error: (_, _) => const SizedBox(height: 52),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableTab extends ConsumerWidget {
  const _AvailableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider);

    return challenges.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(message: friendlyError(e, fallback: 'Could not load challenges'), onRetry: () => ref.invalidate(challengesProvider)),
      data: (list) => list.isEmpty
          ? const EmptyState(icon: CupertinoIcons.game_controller, title: 'No challenges', subtitle: 'Check back later')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final c = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClayCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(CupertinoIcons.game_controller_solid, size: 20, color: AppTheme.secondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
                                  Text('${c.duration} days · ${c.xpReward} XP', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(c.description, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3)),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onPressed: () async {
                              final api = ref.read(apiServiceProvider);
                              final error = await joinChallenge(api, c.id!);
                              if (context.mounted) {
                                if (error != null) {
                                  showAppSnackBar(context, error, isError: true);
                                } else {
                                  showAppSnackBar(context, 'Joined challenge!');
                                  ref.invalidate(myChallengesProvider);
                                  ref.invalidate(challengesProvider);
                                }
                              }
                            },
                            child: const Text('Join Challenge', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _MyTab extends ConsumerWidget {
  const _MyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final my = ref.watch(myChallengesProvider);

    return my.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(message: friendlyError(e, fallback: 'Could not load your challenges'), onRetry: () => ref.invalidate(myChallengesProvider)),
      data: (list) => list.isEmpty
          ? const EmptyState(icon: CupertinoIcons.game_controller, title: 'No active challenges', subtitle: 'Join a challenge to get started')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final uc = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClayCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(uc.name ?? 'Challenge', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
                                  if (uc.description != null && uc.description!.isNotEmpty)
                                    Text(uc.description!, style: const TextStyle(fontSize: 12, color: AppTheme.textHint), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: uc.status == 'completed'
                                    ? AppTheme.success.withValues(alpha: 0.12)
                                    : uc.status == 'abandoned'
                                        ? AppTheme.accent.withValues(alpha: 0.12)
                                        : AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                uc.status[0].toUpperCase() + uc.status.substring(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: uc.status == 'completed' ? AppTheme.success : uc.status == 'abandoned' ? AppTheme.accent : AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Progress
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: uc.progressPercent,
                            backgroundColor: AppTheme.divider,
                            color: uc.progressPercent >= 1.0 ? AppTheme.success : AppTheme.primary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${uc.progress} / ${uc.target} days (${(uc.progressPercent * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        if (uc.status == 'active') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  color: AppTheme.success,
                                  borderRadius: BorderRadius.circular(10),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  onPressed: () async {
                                    final api = ref.read(apiServiceProvider);
                                    final error = await checkinChallenge(api, uc.id!);
                                    if (context.mounted) {
                                      if (error != null) {
                                        showAppSnackBar(context, error, isError: true);
                                      } else {
                                        showAppSnackBar(context, 'Checked in!');
                                        ref.invalidate(myChallengesProvider);
                                        ref.invalidate(userXpProvider);
                                        ref.invalidate(savingsStreakProvider);
                                      }
                                    }
                                  },
                                  child: const Text('Check In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                onPressed: () async {
                                  final confirmed = await showConfirmDialog(
                                    context,
                                    title: 'Abandon Challenge',
                                    message: 'You will lose your progress.',
                                    confirmText: 'Abandon',
                                    isDestructive: true,
                                  );
                                  if (!confirmed) return;
                                  final api = ref.read(apiServiceProvider);
                                  final error = await abandonChallenge(api, uc.id!);
                                  if (context.mounted) {
                                    if (error != null) {
                                      showAppSnackBar(context, error, isError: true);
                                    } else {
                                      showAppSnackBar(context, 'Challenge abandoned');
                                      ref.invalidate(myChallengesProvider);
                                    }
                                  }
                                },
                                child: const Text('Abandon', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
