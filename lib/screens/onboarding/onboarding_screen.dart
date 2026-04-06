import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/services/local_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: CupertinoIcons.chart_pie_fill,
      title: 'Track Every Penny',
      subtitle:
          'Effortlessly log income and expenses with smart categorization. '
          'See where your money goes with beautiful charts and insights.',
      color: AppTheme.primary,
    ),
    _OnboardingPage(
      icon: CupertinoIcons.flag_fill,
      title: 'Set & Crush Goals',
      subtitle:
          'Create savings goals, track your progress in real-time, and '
          'celebrate milestones as you build your financial future.',
      color: AppTheme.success,
    ),
    _OnboardingPage(
      icon: CupertinoIcons.sparkles,
      title: 'AI-Powered Advice',
      subtitle:
          'Get personalized financial insights, spending predictions, and '
          'budget optimization powered by intelligent analysis.',
      color: AppTheme.secondary,
    ),
    _OnboardingPage(
      icon: CupertinoIcons.game_controller_solid,
      title: 'Gamify Your Finances',
      subtitle:
          'Join challenges, earn XP, climb the leaderboard, and build '
          'savings streaks. Finance has never been this fun.',
      color: AppTheme.warning,
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await LocalStorageService.setOnboardingDone();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                onPressed: _finish,
                child: Text('Skip', style: TextStyle(color: AppTheme.textHintC(context), fontSize: 15)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Icon(p.icon, size: 56, color: p.color),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryC(context)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: AppTheme.textSecondaryC(context), height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == _page ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _page ? AppTheme.primary : AppTheme.dividerC(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: _next,
                  child: Text(
                    _page == _pages.length - 1 ? 'Get Started' : 'Continue',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _OnboardingPage({required this.icon, required this.title, required this.subtitle, required this.color});
}
