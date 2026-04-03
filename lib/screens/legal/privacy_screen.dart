import 'package:flutter/material.dart';
import 'package:zorvyn/config/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Heading('Privacy Policy'),
            _Body('Effective date: June 2025'),
            SizedBox(height: 16),
            _Body(
              'At Zorvyn, your privacy is of utmost importance. This Privacy Policy explains '
              'what data we collect, how we use it, and the choices you have regarding your information.',
            ),
            SizedBox(height: 20),
            _SectionTitle('1. Information We Collect'),
            _Body(
              'Account Information: When you register, we collect your name, email address, and '
              'encrypted password.\n\n'
              'Financial Data: Transactions, budgets, goals, and savings data you enter into the App. '
              'This data is stored securely and is associated only with your account.\n\n'
              'Usage Data: App interactions such as feature usage, screen views, and session durations '
              'to improve the user experience.\n\n'
              'Device Information: Device type, OS version, and app version for compatibility and '
              'debugging purposes.',
            ),
            SizedBox(height: 16),
            _SectionTitle('2. How We Use Your Information'),
            _Body(
              '• Provide and maintain the App\'s features (tracking, budgeting, AI insights)\n'
              '• Generate personalized financial insights and predictions\n'
              '• Send notifications about your goals, budgets, and challenges\n'
              '• Improve the App through aggregated, anonymized analytics\n'
              '• Respond to your support requests',
            ),
            SizedBox(height: 16),
            _SectionTitle('3. AI & Data Processing'),
            _Body(
              'Zorvyn uses AI models to provide spending analysis, predictions, and budget optimization. '
              'Your financial data is processed to generate these insights. We do NOT share your individual '
              'financial data with third-party AI providers. AI processing occurs on our secure servers.',
            ),
            SizedBox(height: 16),
            _SectionTitle('4. Data Storage & Security'),
            _Body(
              '• All data is encrypted in transit (TLS 1.2+) and at rest (AES-256)\n'
              '• Passwords are hashed using bcrypt with salt rounds\n'
              '• Authentication uses JWT tokens with automatic expiry\n'
              '• Our infrastructure is hosted on secure cloud providers with SOC 2 compliance\n'
              '• Regular security audits are conducted',
            ),
            SizedBox(height: 16),
            _SectionTitle('5. Data Sharing'),
            _Body(
              'We do NOT sell, rent, or trade your personal or financial data to any third party. '
              'We may share data only in these circumstances:\n\n'
              '• With your explicit consent\n'
              '• To comply with legal obligations or valid legal processes\n'
              '• To protect the rights and safety of our users\n'
              '• With service providers who assist in operating the App (under strict confidentiality agreements)',
            ),
            SizedBox(height: 16),
            _SectionTitle('6. Your Rights'),
            _Body(
              'You have the right to:\n\n'
              '• Access: View all data associated with your account\n'
              '• Correction: Update your personal information at any time\n'
              '• Deletion: Delete your account and all associated data\n'
              '• Portability: Request a copy of your data in a standard format\n'
              '• Opt-out: Disable non-essential notifications',
            ),
            SizedBox(height: 16),
            _SectionTitle('7. Data Retention'),
            _Body(
              'We retain your data for as long as your account is active. When you delete your account, '
              'all personal and financial data is permanently deleted within 30 days. Anonymized, '
              'aggregated data may be retained for analytical purposes.',
            ),
            SizedBox(height: 16),
            _SectionTitle('8. Children\'s Privacy'),
            _Body(
              'Zorvyn is not intended for children under 13. We do not knowingly collect personal '
              'information from children under 13. If we discover such data has been collected, '
              'it will be deleted immediately.',
            ),
            SizedBox(height: 16),
            _SectionTitle('9. Changes to This Policy'),
            _Body(
              'We may update this Privacy Policy periodically. Significant changes will be communicated '
              'through in-app notifications. Continued use after changes constitutes acceptance.',
            ),
            SizedBox(height: 16),
            _SectionTitle('10. Contact Us'),
            _Body(
              'If you have questions about this Privacy Policy or your data, contact us at:\n\n'
              'Email: privacy@zorvyn.app\n'
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
    child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
  );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
  );
}
