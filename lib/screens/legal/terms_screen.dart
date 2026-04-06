import 'package:flutter/material.dart';
import 'package:zorvyn/config/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Heading('Terms of Service'),
            _Body('Last updated: June 2025'),
            SizedBox(height: 16),
            _Body(
              'Welcome to Zorvyn ("the App"). By downloading, installing, or using Zorvyn, '
              'you agree to be bound by these Terms & Conditions. If you do not agree, '
              'please do not use the App.',
            ),
            SizedBox(height: 20),
            _SectionTitle('1. Acceptance of Terms'),
            _Body(
              'By creating an account or using Zorvyn, you confirm that you are at least 13 years of age '
              'and that you accept these terms in full. We may update these terms from time to time, '
              'and continued use of the App constitutes acceptance of any changes.',
            ),
            SizedBox(height: 16),
            _SectionTitle('2. Account Registration'),
            _Body(
              'You must provide accurate, complete information when creating an account. '
              'You are responsible for maintaining the confidentiality of your login credentials '
              'and for all activities that occur under your account. Notify us immediately if you '
              'suspect unauthorized use.',
            ),
            SizedBox(height: 16),
            _SectionTitle('3. Use of the Service'),
            _Body(
              'Zorvyn provides personal finance tracking, budgeting, goal-setting, AI-powered insights, '
              'and gamified savings features. The App is intended for personal, non-commercial use only. '
              'You agree not to:\n\n'
              '• Reverse-engineer, decompile, or disassemble any part of the App\n'
              '• Use the App to engage in fraudulent or illegal activities\n'
              '• Transmit viruses, malware, or any harmful code\n'
              '• Attempt to gain unauthorized access to other users\' accounts\n'
              '• Use automated scripts to access the service',
            ),
            SizedBox(height: 16),
            _SectionTitle('4. Financial Information Disclaimer'),
            _Body(
              'Zorvyn is a personal finance management tool and does NOT provide professional financial, '
              'investment, or tax advice. The AI-powered insights, predictions, and recommendations are '
              'generated algorithmically and should not be considered as professional financial guidance. '
              'Always consult a qualified financial advisor before making significant financial decisions.',
            ),
            SizedBox(height: 16),
            _SectionTitle('5. Data & Privacy'),
            _Body(
              'Your use of Zorvyn is also governed by our Privacy Policy. We encrypt all sensitive data '
              'in transit and at rest. We do not sell your personal financial data to third parties.',
            ),
            SizedBox(height: 16),
            _SectionTitle('6. Intellectual Property'),
            _Body(
              'All content, design, code, and branding in Zorvyn are owned by the Zorvyn team. '
              'You may not copy, modify, distribute, or create derivative works without written permission.',
            ),
            SizedBox(height: 16),
            _SectionTitle('7. Termination'),
            _Body(
              'We reserve the right to suspend or terminate your account at any time if you violate '
              'these terms. You may delete your account at any time through the Settings screen. '
              'Upon deletion, your data will be permanently removed within 30 days.',
            ),
            SizedBox(height: 16),
            _SectionTitle('8. Limitation of Liability'),
            _Body(
              'To the maximum extent permitted by law, Zorvyn shall not be liable for any indirect, '
              'incidental, special, consequential, or punitive damages arising from your use of the App. '
              'Our total liability shall not exceed the amount you paid for the App in the past 12 months.',
            ),
            SizedBox(height: 16),
            _SectionTitle('9. Changes to Terms'),
            _Body(
              'We may modify these terms at any time. Significant changes will be communicated '
              'via in-app notification or email. Your continued use after changes constitutes acceptance.',
            ),
            SizedBox(height: 16),
            _SectionTitle('10. Contact'),
            _Body(
              'For questions about these terms, contact us at:\n\n'
              'Email: legal@zorvyn.app\n'
              'Support: help@zorvyn.app',
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryC(context))),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryC(context))),
  );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryC(context), height: 1.6),
  );
}
