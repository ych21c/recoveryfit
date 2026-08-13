import '../models/exercise.dart';
import '../models/user_profile.dart';
import '../services/exercise_service.dart';
import '../../core/constants/equipment_mapping.dart';
import '../../core/constants/injury_rules.dart';

class ExerciseRepository {
  ExerciseRepository._();
  static final ExerciseRepository instance = ExerciseRepository._();

  final _service = ExerciseService.instance;

  Future<List<Exercise>> getAllExercises() => _service.loadAll();

  Future<Map<String, Exercise>> buildIndex() => _service.buildIndex();

  /// Sync lookup using cached data (null if not yet loaded).
  Exercise? getById(String id) => _service.getCachedById(id);

  /// Filter pipeline:
  ///   1. Environment filter (home / gym / both)
  ///   2. Injury safety filter (exclusion tags)
  Future<List<Exercise>> getFilteredExercises(UserProfile profile) async {
    final all = await getAllExercises();

    final envFiltered = _applyEnvironmentFilter(all, profile);
    final safeFiltered =
        _applyInjuryFilter(envFiltered, profile.detectedBodyParts);
    return safeFiltered;
  }

  List<Exercise> _applyEnvironmentFilter(
      List<Exercise> exercises, UserProfile profile) {
    final env = profile.environmentEnum;
    final userEquipment = profile.equipment.toSet();

    return exercises.where((ex) {
      final exEquipment = ex.equipment;
      switch (env) {
        case WorkoutEnvironment.home:
          return exEquipment.any(
            (eq) =>
                EquipmentMapping.isHomeCompatible(eq) ||
                userEquipment.contains(eq),
          );
        case WorkoutEnvironment.gym:
          return exEquipment.any(
            (eq) =>
                EquipmentMapping.isGymCompatible(eq) ||
                EquipmentMapping.isHomeCompatible(eq),
          );
        case WorkoutEnvironment.both:
          return true; // no filter for both
      }
    }).toList();
  }

  /// Server-side injury re-validation (mirrors LLM prompt constraint).
  List<Exercise> _applyInjuryFilter(
      List<Exercise> exercises, List<String> detectedBodyParts) {
    final exclusionTags =
        InjuryRules.getExclusionTags(detectedBodyParts);
    if (exclusionTags.isEmpty) return exercises;

    return exercises.where((ex) {
      return ex.safetyTags.every((tag) => !exclusionTags.contains(tag));
    }).toList();
  }

  /// Re-validates a plan's exercises after LLM generation.
  /// Returns the list of exercise IDs that violate safety rules.
  Future<List<String>> findUnsafeExercises(
    List<String> exerciseIds,
    List<String> detectedBodyParts,
  ) async {
    final exclusionTags = InjuryRules.getExclusionTags(detectedBodyParts);
    if (exclusionTags.isEmpty) return [];

    final index = await buildIndex();
    return exerciseIds.where((id) {
      final ex = index[id];
      if (ex == null) return false;
      return ex.safetyTags.any((tag) => exclusionTags.contains(tag));
    }).toList();
  }
}
