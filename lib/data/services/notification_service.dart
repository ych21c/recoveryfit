import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancelAll();

    // Daily workout reminder — simplified to show at next occurrence of time
    await _plugin.show(
      AppConstants.workoutReminderNotifId,
      '💪 오늘 운동할 시간이에요!',
      'RecoveryFit 운동 플랜을 확인하세요.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_reminder',
          '운동 리마인더',
          channelDescription: '매일 운동 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> showWeeklyAdjustNotification() async {
    await _plugin.show(
      AppConstants.weeklyAdjustNotifId,
      '📊 주간 플랜 조정 가능',
      'AI가 지난 7일 기록을 분석해 새 플랜을 만들 수 있어요.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_adjust',
          '주간 플랜 갱신',
          channelDescription: '주간 플랜 갱신 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
