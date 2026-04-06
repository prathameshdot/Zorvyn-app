import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/models/tip_model.dart';
import 'package:zorvyn/providers/tips_provider.dart';
import 'package:zorvyn/services/api_service.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(title: const Text('Financial Tips')),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['Daily', 'All Tips', 'Saved'].asMap().entries.map((entry) {
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
                _DailyTab(),
                _AllTab(),
                _BookmarkedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTab extends ConsumerWidget {
  const _DailyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyTipsProvider);
    return daily.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(message: friendlyError(e, fallback: 'Could not load daily tips'), onRetry: () => ref.invalidate(dailyTipsProvider)),
      data: (tips) => tips.isEmpty
          ? const EmptyState(icon: CupertinoIcons.lightbulb, title: 'No daily tips', subtitle: 'Check back later')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tips.length,
              itemBuilder: (context, index) => _TipCard(tip: tips[index]),
            ),
    );
  }
}

class _AllTab extends ConsumerWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(tipsProvider);
    return tips.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(message: friendlyError(e, fallback: 'Could not load tips'), onRetry: () => ref.invalidate(tipsProvider)),
      data: (list) => list.isEmpty
          ? const EmptyState(icon: CupertinoIcons.lightbulb, title: 'No tips available')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) => _TipCard(tip: list[index]),
            ),
    );
  }
}

class _BookmarkedTab extends ConsumerWidget {
  const _BookmarkedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkedTipsProvider);
    return bookmarks.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => ErrorDisplay(message: friendlyError(e, fallback: 'Could not load bookmarks'), onRetry: () => ref.invalidate(bookmarkedTipsProvider)),
      data: (list) => list.isEmpty
          ? const EmptyState(icon: CupertinoIcons.bookmark, title: 'No bookmarks', subtitle: 'Save tips you find useful')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) => _TipCard(tip: list[index]),
            ),
    );
  }
}

class _TipCard extends ConsumerWidget {
  final Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClayCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(CupertinoIcons.lightbulb_fill, size: 18, color: AppTheme.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.title,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimaryC(context)),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(24),
                  onPressed: () async {
                    final api = ref.read(apiServiceProvider);
                    if (tip.bookmarked) {
                      if (tip.id != null) {
                        final error = await removeBookmark(api, tip.id.toString());
                        if (context.mounted) {
                          if (error != null) {
                            showAppSnackBar(context, error, isError: true);
                          } else {
                            showAppSnackBar(context, 'Bookmark removed');
                            ref.invalidate(bookmarkedTipsProvider);
                          }
                        }
                      }
                    } else {
                      if (tip.id != null) {
                        final error = await bookmarkTip(api, tip.id!);
                        if (context.mounted) {
                          if (error != null) {
                            showAppSnackBar(context, error, isError: true);
                          } else {
                            showAppSnackBar(context, 'Tip bookmarked');
                            ref.invalidate(bookmarkedTipsProvider);
                          }
                        }
                      }
                    }
                  },
                  child: Icon(
                    tip.bookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                    size: 20,
                    color: tip.bookmarked ? AppTheme.primary : AppTheme.textHintC(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(tip.content, style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryC(context), height: 1.4)),
            if (tip.category != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tip.category!,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
