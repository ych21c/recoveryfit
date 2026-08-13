enum ExerciseDifficulty { beginner, intermediate, advanced }

enum ExercisePhase { warmup, rehab, main, cooldown }

class Exercise {
  final String id;
  final String name;
  final String nameKo;
  final List<String> muscleGroups;      // primary muscles
  final List<String> secondaryMuscles;
  final List<String> equipment;         // see EquipmentMapping
  final String difficulty;              // ExerciseDifficulty.name
  final String category;                // strength / cardio / mobility / rehab
  final List<String> phaseTags;         // ExercisePhase names (multiple allowed)
  final List<String> safetyTags;        // exclusion tags for injury filter
  final String description;
  final String? imageUrl;
  final String? videoUrl;               // YouTube ID for top-150

  const Exercise({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.muscleGroups,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.difficulty,
    required this.category,
    this.phaseTags = const ['main'],
    this.safetyTags = const [],
    required this.description,
    this.imageUrl,
    this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        nameKo: json['name_ko'] as String? ?? json['name'] as String,
        muscleGroups: List<String>.from(json['muscle_groups'] ?? []),
        secondaryMuscles: List<String>.from(json['secondary_muscles'] ?? []),
        equipment: List<String>.from(json['equipment'] ?? []),
        difficulty: json['difficulty'] as String? ?? 'beginner',
        category: json['category'] as String? ?? 'strength',
        phaseTags: List<String>.from(json['phase_tags'] ?? ['main']),
        safetyTags: List<String>.from(json['safety_tags'] ?? []),
        description: json['description'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        videoUrl: json['video_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_ko': nameKo,
        'muscle_groups': muscleGroups,
        'secondary_muscles': secondaryMuscles,
        'equipment': equipment,
        'difficulty': difficulty,
        'category': category,
        'phase_tags': phaseTags,
        'safety_tags': safetyTags,
        'description': description,
        'image_url': imageUrl,
        'video_url': videoUrl,
      };

  ExerciseDifficulty get difficultyEnum =>
      ExerciseDifficulty.values.byName(difficulty);

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  @override
  String toString() => 'Exercise($id: $nameKo)';
}
