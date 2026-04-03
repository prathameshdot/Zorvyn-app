import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/services/connectivity_service.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    '/home',
    '/transactions',
    '/insights',
    '/ai-chat',
    '/settings',
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _currentIndex(context);
    final isOnline = ref.watch(isOnlineProvider);
    return Scaffold(
      body: Column(
        children: [
          if (!isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.warning,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: const [
                    Icon(CupertinoIcons.wifi_slash, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'re offline. Showing cached data.',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(color: AppTheme.cardShadowLight, offset: Offset(0, -2), blurRadius: 12),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: CupertinoIcons.house,
                  activeIcon: CupertinoIcons.house_fill,
                  label: 'Home',
                  isActive: index == 0,
                  onTap: () => context.go(_tabs[0]),
                ),
                _NavItem(
                  icon: CupertinoIcons.arrow_right_arrow_left,
                  activeIcon: CupertinoIcons.arrow_right_arrow_left_circle_fill,
                  label: 'Transactions',
                  isActive: index == 1,
                  onTap: () => context.go(_tabs[1]),
                ),
                _NavItem(
                  icon: CupertinoIcons.chart_pie,
                  activeIcon: CupertinoIcons.chart_pie_fill,
                  label: 'Insights',
                  isActive: index == 2,
                  onTap: () => context.go(_tabs[2]),
                ),
                _NavItem(
                  icon: CupertinoIcons.chat_bubble,
                  activeIcon: CupertinoIcons.chat_bubble_fill,
                  label: 'AI Chat',
                  isActive: index == 3,
                  onTap: () => context.go(_tabs[3]),
                ),
                _NavItem(
                  icon: CupertinoIcons.gear,
                  activeIcon: CupertinoIcons.gear_solid,
                  label: 'More',
                  isActive: index == 4,
                  onTap: () => context.go(_tabs[4]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppTheme.primary : AppTheme.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.primary : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
