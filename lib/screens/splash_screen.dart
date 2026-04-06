import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/auth_provider.dart';
import 'package:zorvyn/services/local_storage_service.dart';
import 'package:zorvyn/services/push_notification_service.dart';
import 'package:zorvyn/widgets/brand_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String? _nextRoute;
  bool _isLoading = true;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareLaunch());
  }

  Future<void> _prepareLaunch() async {
    await ref.read(authNotifierProvider.notifier).checkAuth();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.isAuthenticated) {
      _nextRoute = '/home';
    } else {
      final onboarded = LocalStorageService.getOnboardingDone();
      _nextRoute = onboarded ? '/login' : '/onboarding';
    }

    setState(() {
      _isLoading = false;
    });

    if (LocalStorageService.getNotificationPrompted()) {
      _continueToNextScreen();
    }
  }

  Future<void> _requestNotifications() async {
    if (_isRequestingPermission) return;

    setState(() {
      _isRequestingPermission = true;
    });

    try {
      await PushNotificationService.requestPermission();
    } catch (_) {
      // Permission flow should never block app launch.
    } finally {
      await LocalStorageService.setNotificationPrompted();
    }

    if (!mounted) return;
    _continueToNextScreen();
  }

  Future<void> _skipNotifications() async {
    await LocalStorageService.setNotificationPrompted();
    _continueToNextScreen();
  }

  void _continueToNextScreen() {
    final nextRoute = _nextRoute;
    if (!mounted || nextRoute == null) return;
    context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgC(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.clayCard(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceC(context),
                  radius: 28,
                  isDark: isDark,
                ),
                child: const BrandLogo(size: 132),
              ),
              const SizedBox(height: 24),
              Text(
                'Zorvyn',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track money, goals, budgets, and insights with a cleaner start experience.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              if (_isLoading)
                const CupertinoActivityIndicator(radius: 14)
              else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.clayCard(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceC(context),
                    radius: 22,
                    isDark: isDark,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.bell_circle,
                        size: 34,
                        color: isDark
                            ? AppTheme.primaryLight
                            : AppTheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Allow notifications on startup',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This lets Zorvyn remind you about budgets, savings goals, and important updates.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isRequestingPermission
                              ? null
                              : _requestNotifications,
                          child: _isRequestingPermission
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Allow and continue'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _isRequestingPermission
                            ? null
                            : _skipNotifications,
                        child: const Text('Skip for now'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
