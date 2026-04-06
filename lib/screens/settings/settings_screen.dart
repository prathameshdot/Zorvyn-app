import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/auth_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _oldPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();

  @override
  void dispose() {
    _oldPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  void _showChangePassword() {
    _oldPwCtrl.clear();
    _newPwCtrl.clear();
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Change Password'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              CupertinoTextField(
                controller: _oldPwCtrl,
                placeholder: 'Current Password',
                obscureText: true,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _newPwCtrl,
                placeholder: 'New Password',
                obscureText: true,
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            child: const Text('Update'),
            onPressed: () async {
              final old = _oldPwCtrl.text.trim();
              final pw = _newPwCtrl.text.trim();
              if (old.isEmpty || pw.isEmpty) return;
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).changePassword(old, pw);
              if (mounted) {
                final err = ref.read(authStateProvider).error;
                if (err != null) {
                  showAppSnackBar(context, err, isError: true);
                } else {
                  showAppSnackBar(context, 'Password updated');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(title: const Text('More')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User card
            ClayCard(
              onTap: () => context.go('/settings/profile'),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B83FF)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ((auth.user?.name ?? '').isEmpty ? 'U' : auth.user!.name[0]).toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.user?.name ?? 'User', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.textPrimaryC(context))),
                        Text(auth.user?.email ?? '', style: TextStyle(fontSize: 13, color: AppTheme.textHintC(context))),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right, color: AppTheme.textHintC(context), size: 18),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu items
            _Section(items: [
              _MenuItem(icon: CupertinoIcons.person, title: 'Profile', onTap: () => context.go('/settings/profile')),
              _MenuItem(icon: CupertinoIcons.bell, title: 'Notifications', onTap: () => context.go('/notifications')),
              _MenuItem(
                icon: CupertinoIcons.moon,
                title: 'Dark Mode',
                trailing: CupertinoSwitch(
                  value: ref.watch(themeModeProvider) == ThemeMode.dark,
                  activeTrackColor: AppTheme.primary,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                ),
                onTap: () => ref.read(themeModeProvider.notifier).toggle(),
              ),
            ]),
            const SizedBox(height: 12),
            _Section(items: [
              _MenuItem(icon: CupertinoIcons.chart_bar, title: 'Leaderboard', onTap: () => context.go('/leaderboard')),
              _MenuItem(icon: CupertinoIcons.lightbulb, title: 'Tips & Advice', onTap: () => context.go('/tips')),
              _MenuItem(icon: CupertinoIcons.game_controller, title: 'Challenges', onTap: () => context.go('/challenges')),
            ]),
            const SizedBox(height: 12),
            _Section(items: [
              _MenuItem(icon: CupertinoIcons.lock, title: 'Change Password', onTap: _showChangePassword),
              _MenuItem(icon: CupertinoIcons.question_circle, title: 'Help & Support', onTap: () => context.push('/settings/help')),
            ]),
            const SizedBox(height: 12),
            _Section(items: [
              _MenuItem(icon: CupertinoIcons.doc_text, title: 'Terms & Conditions', onTap: () => context.push('/settings/terms')),
              _MenuItem(icon: CupertinoIcons.shield, title: 'Privacy Policy', onTap: () => context.push('/settings/privacy')),
              _MenuItem(icon: CupertinoIcons.chat_bubble_2, title: 'FAQ', onTap: () => context.push('/settings/faq')),
            ]),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: 'Logout',
                    message: 'Are you sure you want to log out?',
                    confirmText: 'Logout',
                    isDestructive: true,
                  );
                  if (!confirmed) return;
                  await ref.read(authNotifierProvider.notifier).logout();
                },
                child: const Text('Logout', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),

            // Delete account
            CupertinoButton(
              onPressed: () async {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Delete Account',
                  message: 'This action is permanent. All your data will be lost.',
                  confirmText: 'Delete',
                  isDestructive: true,
                );
                if (!confirmed) return;
                await ref.read(authNotifierProvider.notifier).deleteAccount();
              },
              child: Text(
                'Delete Account',
                style: TextStyle(color: AppTheme.textHintC(context), fontSize: 13, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<_MenuItem> items;
  const _Section({required this.items});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onPressed: item.onTap,
                child: Row(
                  children: [
                    Icon(item.icon, size: 20, color: AppTheme.primary),
                    const SizedBox(width: 14),
                    Expanded(child: Text(item.title, style: TextStyle(fontSize: 15, color: AppTheme.textPrimaryC(context)))),
                    item.trailing ?? Icon(CupertinoIcons.chevron_right, color: AppTheme.textHintC(context), size: 16),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 0, indent: 50, color: AppTheme.dividerC(context)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  const _MenuItem({required this.icon, required this.title, required this.onTap, this.trailing});
}
