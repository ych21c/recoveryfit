import 'package:hive/hive.dart';

part 'daily_log.g.dart';

enum ExerciseStatus { completed, skipped, pending }

@HiveType(typeId: 5)
class ExerciseLogEntry extends HiveObject {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  String status; // ExerciseStatus.name

  @HiveField(2)
  int? painLevel; // 1–10, recorded after exercise

  @HiveField(3)
  String? note;

  ExerciseLogEntry({
    required this.exerciseId,
    this.status = 'pending',
    this.painLevel,
    this.note,
  });

  ExerciseStatus get statusEnum => ExerciseStatus.values.byName(status);

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'status': status,
        'pain_level': painLevel,
        'note': note,
      };
}

@HiveType(typeId: 6)
class DailyLog extends HiveObject {
  /// Key format: "YYYY-MM-DD"
  @HiveField(0)
  final String dateKey;

  @HiveField(1)
  final String planId;

  @HiveField(2)
  int overallPainLevel; // morning pain check-in (1–10)

  @HiveField(3)
  final List<ExerciseLogEntry> entries;

  @HiveField(4)
  bool sessionCompleted;

  @HiveField(5)
  String? sessionNote;

  DailyLog({
    required this.dateKey,
    required this.planId,
    required this.overallPainLevel,
    required this.entries,
    this.sessionCompleted = false,
    this.sessionNote,
  });

  int get completedCount =>
      entries.where((e) => e.status == ExerciseStatus.completed.name).length;

  int get skippedCount =>
      entries.where((e) => e.status == ExerciseStatus.skipped.name).length;

  double get completionRate =>
      entries.isEmpty ? 0 : completedCount / entries.length;

  /// Total volume proxy: completed exercises × sets (requires set count).
  /// Actual volume computed in ProgressRepository with exercise data.

  Map<String, dynamic> toJson() => {
        'date_key': dateKey,
        'plan_id': planId,
        'overall_pain_level': overallPainLevel,
        'entries': entries.map((e) => e.toJson()).toList(),
        'session_completed': sessionCompleted,
        'session_note': sessionNote,
      };
}
