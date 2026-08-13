import 'package:hive/hive.dart';

part 'user_profile.g.dart';

enum WorkoutGoal { muscleGain, recovery, weightLoss }

enum WorkoutEnvironment { home, gym, both }

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String injuryDescription;

  @HiveField(2)
  final int painLevel; // 1–10

  @HiveField(3)
  final String goal; // WorkoutGoal.name

  @HiveField(4)
  final int weeklyFrequency; // days per week

  @HiveField(5)
  final String environment; // WorkoutEnvironment.name

  @HiveField(6)
  final List<String> equipment;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final List<String> detectedBodyParts; // derived from injuryDescription

  UserProfile({
    required this.id,
    required this.injuryDescription,
    required this.painLevel,
    required this.goal,
    required this.weeklyFrequency,
    required this.environment,
    required this.equipment,
    required this.createdAt,
    required this.detectedBodyParts,
  });

  WorkoutGoal get goalEnum => WorkoutGoal.values.byName(goal);
  WorkoutEnvironment get environmentEnum =>
      WorkoutEnvironment.values.byName(environment);

  UserProfile copyWith({
    String? injuryDescription,
    int? painLevel,
    String? goal,
    int? weeklyFrequency,
    String? environment,
    List<String>? equipment,
    List<String>? detectedBodyParts,
  }) =>
      UserProfile(
        id: id,
        injuryDescription: injuryDescription ?? this.injuryDescription,
        painLevel: painLevel ?? this.painLevel,
        goal: goal ?? this.goal,
        weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
        environment: environment ?? this.environment,
        equipment: equipment ?? this.equipment,
        createdAt: createdAt,
        detectedBodyParts: detectedBodyParts ?? this.detectedBodyParts,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'injury_description': injuryDescription,
        'pain_level': painLevel,
        'goal': goal,
        'weekly_frequency': weeklyFrequency,
        'environment': environment,
        'equipment': equipment,
        'detected_body_parts': detectedBodyParts,
      };
}
