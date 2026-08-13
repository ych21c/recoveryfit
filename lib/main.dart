import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/user_profile.dart';
import 'data/models/workout_plan.dart';
import 'data/models/daily_log.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();

  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(WorkoutPlanAdapter());
  Hive.registerAdapter(PlannedExerciseAdapter());
  Hive.registerAdapter(WorkoutDayAdapter());
  Hive.registerAdapter(WorkoutWeekAdapter());
  Hive.registerAdapter(DailyLogAdapter());
  Hive.registerAdapter(ExerciseLogEntryAdapter());

  await Hive.openBox<UserProfile>('user_profile');
  await Hive.openBox<WorkoutPlan>('workout_plans');
  await Hive.openBox<DailyLog>('daily_logs');
  await Hive.openBox('settings');

  await NotificationService.instance.init();

  runApp(const ProviderScope(child: RecoveryFitApp()));
}
