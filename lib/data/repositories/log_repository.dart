import 'package:intl/intl.dart';

import '../models/daily_log.dart';
import '../models/workout_plan.dart';
import '../services/storage_service.dart';

class LogRepository {
  LogRepository._();
  static final LogRepository instance = LogRepository._();

  final _storage = StorageService.instance;

  static String dateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  DailyLog? getTodayLog() => _storage.getLog(dateKey(DateTime.now()));

  DailyLog? getLog(DateTime date) => _storage.getLog(dateKey(date));

  Future<void> saveLog(DailyLog log) => _storage.saveLog(log);

  /// Creates or returns existing log for today, pre-populated from plan day.
  Future<DailyLog> getOrCreateTodayLog({
    required WorkoutDay? workoutDay,
    required String planId,
    required int defaultPainLevel,
  }) async {
    final key = dateKey(DateTime.now());
    final existing = _storage.getLog(key);
    if (existing != null) return existing;

    final entries = workoutDay?.exercises
            .map((pe) => ExerciseLogEntry(exerciseId: pe.exerciseId))
            .toList() ??
        [];

    final log = DailyLog(
      dateKey: key,
      planId: planId,
      overallPainLevel: defaultPainLevel,
      entries: entries,
    );
    await _storage.saveLog(log);
    return log;
  }

  Future<void> markExercise({
    required String dateKey,
    required String exerciseId,
    required ExerciseStatus status,
    int? painLevel,
    String? note,
  }) async {
    final log = _storage.getLog(dateKey);
    if (log == null) return;

    final entry = log.entries
        .where((e) => e.exerciseId == exerciseId)
        .firstOrNull;
    if (entry == null) return;

    entry.status = status.name;
    entry.painLevel = painLevel;
    entry.note = note;

    final allDone = log.entries.every(
      (e) =>
          e.status == ExerciseStatus.completed.name ||
          e.status == ExerciseStatus.skipped.name,
    );
    if (allDone) log.sessionCompleted = true;

    await _storage.saveLog(log);
  }

  Future<void> updatePainLevel(String dateKey, int level) async {
    final log = _storage.getLog(dateKey);
    if (log == null) return;
    log.overallPainLevel = level;
    await _storage.saveLog(log);
  }

  List<DailyLog> getLogsInRange(DateTime start, DateTime end) =>
      _storage.getLogsInRange(start, end);

  /// Builds summary for the last 7 days for LLM weekly adjust prompt.
  Map<String, dynamic> buildWeekSummary() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    final logs = getLogsInRange(start, end);

    final totalSessions = logs.length;
    final completedSessions =
        logs.where((l) => l.sessionCompleted).length;
    final avgPain = logs.isEmpty
        ? 0.0
        : logs.map((l) => l.overallPainLevel).reduce((a, b) => a + b) /
            logs.length;
    final avgCompletion = logs.isEmpty
        ? 0.0
        : logs.map((l) => l.completionRate).reduce((a, b) => a + b) /
            logs.length;

    // Count skips per exercise
    final skipCount = <String, int>{};
    for (final log in logs) {
      for (final entry in log.entries) {
        if (entry.status == ExerciseStatus.skipped.name) {
          skipCount[entry.exerciseId] =
              (skipCount[entry.exerciseId] ?? 0) + 1;
        }
      }
    }
    final frequentlySkipped = skipCount.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();

    return {
      'period': '${dateKey(start)} ~ ${dateKey(end)}',
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'avg_pain_level': avgPain.toStringAsFixed(1),
      'avg_completion_rate': '${(avgCompletion * 100).toStringAsFixed(0)}%',
      'frequently_skipped_exercise_ids': frequentlySkipped,
      'pain_trend': _painTrend(logs),
    };
  }

  String _painTrend(List<DailyLog> logs) {
    if (logs.length < 3) return 'insufficient_data';
    final recent =
        logs.sublist(logs.length - 3).map((l) => l.overallPainLevel);
    final early =
        logs.sublist(0, 3).map((l) => l.overallPainLevel);
    final recentAvg = recent.reduce((a, b) => a + b) / 3;
    final earlyAvg = early.reduce((a, b) => a + b) / 3;
    if (recentAvg < earlyAvg - 0.5) return 'improving';
    if (recentAvg > earlyAvg + 0.5) return 'worsening';
    return 'stable';
  }
}
