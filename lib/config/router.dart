import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/providers/auth_provider.dart';
import 'package:zorvyn/screens/auth/forgot_password_screen.dart';
import 'package:zorvyn/screens/auth/login_screen.dart';
import 'package:zorvyn/screens/auth/register_screen.dart';
import 'package:zorvyn/screens/auth/reset_password_screen.dart';
import 'package:zorvyn/screens/main_shell.dart';
import 'package:zorvyn/screens/home/home_screen.dart';
import 'package:zorvyn/screens/transactions/transactions_screen.dart';
import 'package:zorvyn/screens/transactions/add_transaction_screen.dart';
import 'package:zorvyn/screens/transactions/transaction_detail_screen.dart';
import 'package:zorvyn/screens/goals/goals_screen.dart';
import 'package:zorvyn/screens/goals/add_goal_screen.dart';
import 'package:zorvyn/screens/goals/goal_detail_screen.dart';
import 'package:zorvyn/screens/budgets/budgets_screen.dart';
import 'package:zorvyn/screens/budgets/add_budget_screen.dart';
import 'package:zorvyn/screens/insights/insights_screen.dart';
import 'package:zorvyn/screens/ai/ai_chat_screen.dart';
import 'package:zorvyn/screens/ai/ai_conversations_screen.dart';
import 'package:zorvyn/screens/notifications/notifications_screen.dart';
import 'package:zorvyn/screens/leaderboard/leaderboard_screen.dart';
import 'package:zorvyn/screens/tips/tips_screen.dart';
import 'package:zorvyn/screens/challenges/challenges_screen.dart';
import 'package:zorvyn/screens/settings/settings_screen.dart';
import 'package:zorvyn/screens/settings/profile_screen.dart';
import 'package:zorvyn/screens/splash_screen.dart';
import 'package:zorvyn/screens/onboarding/onboarding_screen.dart';
import 'package:zorvyn/screens/legal/terms_screen.dart';
import 'package:zorvyn/screens/legal/privacy_screen.dart';
import 'package:zorvyn/screens/legal/faq_screen.dart';
import 'package:zorvyn/screens/settings/help_screen.dart';
import 'package:zorvyn/screens/ai/ai_insights_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod [AuthState] changes into a [ChangeNotifier] that
/// GoRouter can listen to via [refreshListenable].
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.token != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-password' ||
          state.matchedLocation == '/onboarding';
      final isSplash = state.matchedLocation == '/';

      // Not logged in → force to login (except auth routes & splash)
      if (!isLoggedIn && !isAuthRoute && !isSplash) return '/login';
      // Logged in → redirect away from auth routes to home
      if (isLoggedIn && (isAuthRoute || isSplash)) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: '/ai-insights',
        builder: (context, state) => const AiInsightsScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransactionsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddTransactionScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AddTransactionScreen(
                  transactionId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => TransactionDetailScreen(
                  transactionId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GoalsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddGoalScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AddGoalScreen(
                  goalId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => GoalDetailScreen(
                  goalId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/budgets',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BudgetsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddBudgetScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AddBudgetScreen(
                  budgetId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InsightsScreen(),
            ),
          ),
          GoRoute(
            path: '/ai-chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiConversationsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AiChatScreen(),
              ),
              GoRoute(
                path: ':conversationId',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AiChatScreen(
                  conversationId: state.pathParameters['conversationId'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: '/leaderboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LeaderboardScreen(),
            ),
          ),
          GoRoute(
            path: '/tips',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TipsScreen(),
            ),
          ),
          GoRoute(
            path: '/challenges',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChallengesScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'profile',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'help',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HelpScreen(),
              ),
              GoRoute(
                path: 'terms',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const TermsScreen(),
              ),
              GoRoute(
                path: 'privacy',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const PrivacyScreen(),
              ),
              GoRoute(
                path: 'faq',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const FaqScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
