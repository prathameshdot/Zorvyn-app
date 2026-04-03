import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.clayCard(color: AppTheme.primary.withValues(alpha: 0.08)),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(CupertinoIcons.question_circle_fill, size: 36, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find answers or reach out to our support team.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick links
            const Text(
              'Quick Links',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            _HelpTile(
              icon: CupertinoIcons.question_circle,
              title: 'FAQ',
              subtitle: 'Answers to common questions',
              onTap: () => context.push('/settings/faq'),
            ),
            const SizedBox(height: 8),
            _HelpTile(
              icon: CupertinoIcons.doc_text,
              title: 'Terms & Conditions',
              subtitle: 'Read our terms of service',
              onTap: () => context.push('/settings/terms'),
            ),
            const SizedBox(height: 8),
            _HelpTile(
              icon: CupertinoIcons.shield,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => context.push('/settings/privacy'),
            ),
            const SizedBox(height: 24),

            // Contact
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            ClayCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ContactRow(
                    icon: CupertinoIcons.mail,
                    label: 'Email Support',
                    value: 'help@zorvyn.app',
                  ),
                  const Divider(height: 24, color: AppTheme.divider),
                  _ContactRow(
                    icon: CupertinoIcons.clock,
                    label: 'Response Time',
                    value: 'Within 24 hours',
                  ),
                  const Divider(height: 24, color: AppTheme.divider),
                  _ContactRow(
                    icon: CupertinoIcons.globe,
                    label: 'Website',
                    value: 'zorvyn.app',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tips
            const Text(
              'Quick Tips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            ClayCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TipRow(text: 'Swipe left on notifications to dismiss them'),
                  SizedBox(height: 10),
                  _TipRow(text: 'Tap any chart for detailed breakdowns'),
                  SizedBox(height: 10),
                  _TipRow(text: 'Ask the AI assistant anything about your finances'),
                  SizedBox(height: 10),
                  _TipRow(text: 'Join challenges to earn XP and climb the leaderboard'),
                  SizedBox(height: 10),
                  _TipRow(text: 'Set budgets per category to control spending'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App info
            Center(
              child: Column(
                children: const [
                  Text('Zorvyn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  SizedBox(height: 4),
                  Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                  SizedBox(height: 2),
                  Text('Personal Finance Companion', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _HelpTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right, size: 16, color: AppTheme.textHint),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(CupertinoIcons.lightbulb, size: 16, color: AppTheme.warning),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4))),
      ],
    );
  }
}
