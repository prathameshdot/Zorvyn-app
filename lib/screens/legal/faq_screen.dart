import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expanded;

  static const _sections = [
    _FaqSection(title: 'Getting Started', items: [
      _FaqItem(
        q: 'What is Zorvyn?',
        a: 'Zorvyn is an AI-powered personal finance companion that helps you track expenses, '
           'set savings goals, create budgets, and get personalized financial insights — all with '
           'a gamified experience to keep you motivated.',
      ),
      _FaqItem(
        q: 'How do I create an account?',
        a: 'Tap "Create Account" on the login screen. Enter your name, email, and a strong password. '
           'You\'ll be logged in immediately and can start tracking your finances right away.',
      ),
      _FaqItem(
        q: 'Is Zorvyn free to use?',
        a: 'Yes! Zorvyn is completely free with all core features including transaction tracking, '
           'budgeting, goals, AI chat, leaderboards, and challenges.',
      ),
    ]),
    _FaqSection(title: 'Transactions', items: [
      _FaqItem(
        q: 'How do I add a transaction?',
        a: 'Go to the Transactions tab and tap the "+" button. Select income or expense, choose a '
           'category, enter the amount and an optional description, then save.',
      ),
      _FaqItem(
        q: 'Can I edit or delete a transaction?',
        a: 'Yes. Tap on any transaction to view its details. From there you can edit all fields '
           'or delete the transaction entirely.',
      ),
      _FaqItem(
        q: 'What categories are available?',
        a: 'Expenses: Food & Dining, Transportation, Shopping, Entertainment, Bills & Utilities, '
           'Health & Fitness, Education, Travel, Housing, Personal Care, Gifts & Donations, '
           'Investments, and Other.\n\n'
           'Income: Salary, Freelance, Business, Investments, Rental, Gifts, Refunds, and Other.',
      ),
    ]),
    _FaqSection(title: 'Budgets & Goals', items: [
      _FaqItem(
        q: 'How do budgets work?',
        a: 'Create a budget by selecting a category, setting a spending limit, and choosing a period '
           '(weekly or monthly). Zorvyn automatically tracks your spending against the budget and '
           'alerts you when you\'re close to the limit.',
      ),
      _FaqItem(
        q: 'How do savings goals work?',
        a: 'Set a goal with a target amount and deadline. You can contribute toward the goal any time. '
           'Zorvyn shows your progress with beautiful charts and sends milestone notifications.',
      ),
      _FaqItem(
        q: 'Can I have multiple budgets and goals?',
        a: 'Absolutely! Create as many budgets and goals as you need to organize your finances.',
      ),
    ]),
    _FaqSection(title: 'AI Features', items: [
      _FaqItem(
        q: 'What can the AI assistant do?',
        a: 'The AI can analyze your spending patterns, predict future expenses, suggest budget '
           'optimizations, answer financial questions, and provide personalized tips based on '
           'your transaction history.',
      ),
      _FaqItem(
        q: 'Is my data safe with the AI?',
        a: 'Yes. Your financial data is processed securely on our servers. We do not share your '
           'individual data with third-party AI providers. See our Privacy Policy for details.',
      ),
    ]),
    _FaqSection(title: 'Gamification', items: [
      _FaqItem(
        q: 'How do challenges work?',
        a: 'Join savings challenges to earn XP. Check in daily to track progress. Complete challenges '
           'to earn bonus XP and climb the leaderboard.',
      ),
      _FaqItem(
        q: 'What is XP and the leaderboard?',
        a: 'XP (experience points) are earned through challenges, check-ins, and savings streaks. '
           'The leaderboard ranks all users by their total XP — compete with others to stay motivated!',
      ),
      _FaqItem(
        q: 'What are savings streaks?',
        a: 'When you consistently save money or check in to challenges, you build a streak. '
           'Longer streaks earn bonus XP.',
      ),
    ]),
    _FaqSection(title: 'Account & Security', items: [
      _FaqItem(
        q: 'How do I reset my password?',
        a: 'On the login screen, tap "Forgot Password" and enter your email. You\'ll receive a '
           'reset token to create a new password.',
      ),
      _FaqItem(
        q: 'Can I delete my account?',
        a: 'Yes. Go to Settings and tap "Delete Account" at the bottom. This action is permanent — '
           'all your data will be deleted within 30 days.',
      ),
      _FaqItem(
        q: 'How is my data protected?',
        a: 'All data is encrypted in transit and at rest. Passwords are bcrypt-hashed. '
           'Authentication uses JWT tokens with automatic expiry.',
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    int globalIdx = 0;

    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(title: const Text('FAQ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryC(context)),
            ),
            const SizedBox(height: 4),
            Text(
              'Find answers to common questions about Zorvyn.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryC(context)),
            ),
            const SizedBox(height: 24),
            ..._sections.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 8),
                  ...section.items.map((item) {
                    final idx = globalIdx++;
                    final isOpen = _expanded == idx;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClayCard(
                        padding: EdgeInsets.zero,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => setState(() => _expanded = isOpen ? null : idx),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.q,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimaryC(context),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isOpen ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                                      size: 16,
                                      color: AppTheme.textHintC(context),
                                    ),
                                  ],
                                ),
                                if (isOpen) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    item.a,
                                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryC(context), height: 1.5),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FaqSection {
  final String title;
  final List<_FaqItem> items;
  const _FaqSection({required this.title, required this.items});
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}
