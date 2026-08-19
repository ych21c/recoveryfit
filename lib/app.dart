import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/models/daily_log.dart';
import 'data/models/user_profile.dart';
import 'data/models/workout_plan.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';

/// Top-level entry widget. Self-contained: includes ProviderScope and all
/// async platform initialization so it can be pumped directly in tests.
class RecoveryFitApp extends StatelessWidget {
  const RecoveryFitApp({super.key});

  // Memoized so re-entrant calls from multiple tests return the same Future.
  static Future<void>? _initFuture;
  static Future<void> _initApp() => _initFuture ??= _doInitApp();

  static Future<void> _doInitApp() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(UserProfileAdapter().typeId)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutPlanAdapter().typeId)) {
      Hive.registerAdapter(WorkoutPlanAdapter());
    }
    if (!Hive.isAdapterRegistered(PlannedExerciseAdapter().typeId)) {
      Hive.registerAdapter(PlannedExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutDayAdapter().typeId)) {
      Hive.registerAdapter(WorkoutDayAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutWeekAdapter().typeId)) {
      Hive.registerAdapter(WorkoutWeekAdapter());
    }
    if (!Hive.isAdapterRegistered(DailyLogAdapter().typeId)) {
      Hive.registerAdapter(DailyLogAdapter());
    }
    if (!Hive.isAdapterRegistered(ExerciseLogEntryAdapter().typeId)) {
      Hive.registerAdapter(ExerciseLogEntryAdapter());
    }

    if (!Hive.isBoxOpen('user_profile')) {
      await Hive.openBox<UserProfile>('user_profile');
    }
    if (!Hive.isBoxOpen('workout_plans')) {
      await Hive.openBox<WorkoutPlan>('workout_plans');
    }
    if (!Hive.isBoxOpen('daily_logs')) {
      await Hive.openBox<DailyLog>('daily_logs');
    }
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }

    await StorageService.instance.init();

    // Best-effort: notification plugin may be unavailable in test environments.
    try {
      await NotificationService.instance.init();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: FutureBuilder(
        future: _initApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const MaterialApp(
              home: Scaffold(
                backgroundColor: Color(0xFF0D1B2A),
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return const _AppRouter();
        },
      ),
    );
  }
}

class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'RecoveryFit',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
