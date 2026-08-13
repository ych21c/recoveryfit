import 'package:hive/hive.dart';

part 'workout_plan.g.dart';

@HiveType(typeId: 1)
class PlannedExercise extends HiveObject {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final String phase; // warmup / rehab / main / cooldown

  @HiveField(2)
  final int sets;

  @HiveField(3)
  final String reps; // "10–12" or "30s" for time-based

  @HiveField(4)
  final int restSeconds;

  @HiveField(5)
  final String intensityNote; // e.g. "RPE 5–6"

  @HiveField(6)
  final String coachNote;

  PlannedExercise({
    required this.exerciseId,
    required this.phase,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.intensityNote = '',
    this.coachNote = '',
  });

  factory PlannedExercise.fromJson(Map<String, dynamic> json) =>
      PlannedExercise(
        exerciseId: json['exercise_id'] as String,
        phase: json['phase'] as String? ?? 'main',
        sets: (json['sets'] as num?)?.toInt() ?? 3,
        reps: json['reps']?.toString() ?? '10',
        restSeconds: (json['rest_seconds'] as num?)?.toInt() ?? 60,
        intensityNote: json['intensity_note'] as String? ?? '',
        coachNote: json['coach_note'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'phase': phase,
        'sets': sets,
        'reps': reps,
        'rest_seconds': restSeconds,
        'intensity_note': intensityNote,
        'coach_note': coachNote,
      };
}

@HiveType(typeId: 2)
class WorkoutDay extends HiveObject {
  @HiveField(0)
  final int dayOfWeek; // 1=Mon … 7=Sun

  @HiveField(1)
  final String focusArea;

  @HiveField(2)
  final int estimatedMinutes;

  @HiveField(3)
  final List<PlannedExercise> exercises;

  WorkoutDay({
    required this.dayOfWeek,
    required this.focusArea,
    required this.estimatedMinutes,
    required this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
        dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 1,
        focusArea: json['focus_area'] as String? ?? '',
        estimatedMinutes:
            (json['estimated_duration_minutes'] as num?)?.toInt() ?? 45,
        exercises: (json['exercises'] as List? ?? [])
            .map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        'focus_area': focusArea,
        'estimated_duration_minutes': estimatedMinutes,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}

@HiveType(typeId: 3)
class WorkoutWeek extends HiveObject {
  @HiveField(0)
  final int weekNumber;

  @HiveField(1)
  final String theme;

  @HiveField(2)
  final List<WorkoutDay> days;

  @HiveField(3)
  final String progressionNote;

  WorkoutWeek({
    required this.weekNumber,
    required this.theme,
    required this.days,
    this.progressionNote = '',
  });

  factory WorkoutWeek.fromJson(Map<String, dynamic> json) => WorkoutWeek(
        weekNumber: (json['week'] as num?)?.toInt() ?? 1,
        theme: json['theme'] as String? ?? '',
        days: (json['days'] as List? ?? [])
            .map((e) => WorkoutDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        progressionNote: json['progression_note'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'week': weekNumber,
        'theme': theme,
        'days': days.map((d) => d.toJson()).toList(),
        'progression_note': progressionNote,
      };
}

@HiveType(typeId: 4)
class WorkoutPlan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userProfileId;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final List<WorkoutWeek> weeks;

  @HiveField(4)
  final String safetyDisclaimer;

  @HiveField(5)
  bool isActive;

  WorkoutPlan({
    required this.id,
    required this.userProfileId,
    required this.createdAt,
    required this.weeks,
    required this.safetyDisclaimer,
    this.isActive = true,
  });

  factory WorkoutPlan.fromJson(
      Map<String, dynamic> json, String userProfileId) {
    return WorkoutPlan(
      id: json['plan_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userProfileId: userProfileId,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      weeks: (json['weeks'] as List? ?? [])
          .map((e) => WorkoutWeek.fromJson(e as Map<String, dynamic>))
          .toList(),
      safetyDisclaimer: json['safety_disclaimer'] as String? ?? '',
      isActive: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan_id': id,
        'created_at': createdAt.toIso8601String(),
        'weeks': weeks.map((w) => w.toJson()).toList(),
        'safety_disclaimer': safetyDisclaimer,
      };

  /// Returns the WorkoutDay for the given absolute date (offset from plan start).
  WorkoutDay? getDayForDate(DateTime date) {
    final daysSinceStart = date.difference(createdAt).inDays;
    if (daysSinceStart < 0) return null;
    final weekIndex = daysSinceStart ~/ 7;
    if (weekIndex >= weeks.length) return null;
    final week = weeks[weekIndex];
    final dow = date.weekday; // 1=Mon … 7=Sun
    return week.days.where((d) => d.dayOfWeek == dow).firstOrNull;
  }
}
