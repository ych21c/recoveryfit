import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/daily_log.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/workout_plan.dart';
import '../../presentation/onboarding/disclaimer_page.dart';
import '../../presentation/onboarding/onboarding_page.dart';
import '../../presentation/plan/generating_page.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/session/session_args.dart';
import '../../presentation/session/session_page.dart';
import '../../presentation/session/session_complete_page.dart';
import '../../presentation/analytics/analytics_page.dart';
import '../../presentation/weekly_report/weekly_report_page.dart';
import '../../presentation/settings/settings_page.dart';
import '../../presentation/settings/subscription_page.dart';
import '../../presentation/providers/providers.dart';

// ── Routes ────────────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();
  static const disclaimer = '/disclaimer';
  static const onboarding = '/onboarding';
  static const generating = '/generating';
  static const home = '/home';
  static const session = '/session';
  static const sessionComplete = '/session-complete';
  static const analytics = '/analytics';
  static const weeklyReport = '/weekly-report';
  static const settings = '/settings';
  static const subscription = '/settings/subscription';
}

// ── Static navigation helpers ─────────────────────────────────────────────────

class AppRouter {
  AppRouter._();

  static void goSession(
    BuildContext context, {
    required List<PlannedExercise> exercises,
    required int exerciseIndex,
    DailyLog? log,
  }) {
    context.push(
      AppRoutes.session,
      extra: SessionArgs(
        exercises: exercises,
        exerciseIndex: exerciseIndex,
        log: log,
      ),
    );
  }
}

// ── Router Provider ───────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.read(storageServiceProvider);

  return GoRouter(
    initialLocation:
        storage.onboardingDone ? AppRoutes.home : AppRoutes.disclaimer,
    routes: [
      // ── Standalone screens (no nav bar) ─────────────────────────────────
      GoRoute(
        path: AppRoutes.disclaimer,
        builder: (_, __) => const DisclaimerPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.generating,
        builder: (context, state) {
          final profile = state.extra as UserProfile;
          return GeneratingPage(profile: profile);
        },
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) {
          final args = state.extra as SessionArgs;
          return SessionPage(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.sessionComplete,
        builder: (context, state) {
          final map = state.extra as Map<String, dynamic>;
          return SessionCompletePage(args: SessionCompleteArgs.fromMap(map));
        },
      ),
      GoRoute(
        path: AppRoutes.weeklyReport,
        builder: (_, __) => const WeeklyReportPage(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (_, __) => const SubscriptionPage(),
      ),

      // ── Shell (with bottom nav bar) ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            _MainShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            builder: (_, __) => const AnalyticsPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

// ── Shell Scaffold ────────────────────────────────────────────────────────────

class _MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const _MainShell({required this.child, required this.location});

  int _currentIndex() {
    if (location.startsWith(AppRoutes.analytics)) return 1;
    if (location.startsWith(AppRoutes.settings)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8EEEC))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex(),
          elevation: 0,
          backgroundColor: Colors.transparent,
          onTap: (i) {
            switch (i) {
              case 0:
                context.go(AppRoutes.home);
              case 1:
                context.go(AppRoutes.analytics);
              case 2:
                context.go(AppRoutes.settings);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: '통계',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
