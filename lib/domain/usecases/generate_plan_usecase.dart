import '../../core/constants/injury_rules.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/workout_plan.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/services/llm_service.dart';
import '../../data/services/storage_service.dart';

class GeneratePlanUseCase {
  final ExerciseRepository _exerciseRepo;
  final LlmService _llm;
  final StorageService _storage;

  GeneratePlanUseCase({
    ExerciseRepository? exerciseRepo,
    LlmService? llm,
    StorageService? storage,
  })  : _exerciseRepo = exerciseRepo ?? ExerciseRepository.instance,
        _llm = llm ?? LlmService.instance,
        _storage = storage ?? StorageService.instance;

  Future<WorkoutPlan> call(UserProfile profile) async {
    final apiKey = _storage.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('API 키가 설정되지 않았습니다. 설정에서 Anthropic API 키를 입력하세요.');
    }

    if (!_storage.canMakeLlmCall) throw LlmCallLimitException();

    // 1) Environment + injury filter
    final allowedExercises = await _exerciseRepo.getFilteredExercises(profile);

    // 2) Collect exclusion tags for LLM prompt enforcement
    final exclusionTags =
        InjuryRules.getExclusionTags(profile.detectedBodyParts);

    // 3) Call LLM (Sonnet for initial plan)
    final plan = await _llm.generateInitialPlan(
      apiKey: apiKey,
      profile: profile,
      allowedExercises: allowedExercises,
      exclusionTags: exclusionTags,
    );

    // 4) Server-side safety re-validation
    final allExerciseIds = plan.weeks
        .expand((w) => w.days)
        .expand((d) => d.exercises)
        .map((pe) => pe.exerciseId)
        .toList();

    final unsafeIds = await _exerciseRepo.findUnsafeExercises(
      allExerciseIds,
      profile.detectedBodyParts,
    );

    if (unsafeIds.isNotEmpty) {
      // Remove unsafe exercises from the plan (graceful degradation)
      _removeUnsafeExercises(plan, unsafeIds.toSet());
    }

    // 5) Increment LLM call counter
    await _storage.incrementLlmCalls();

    // 6) Persist
    await _storage.savePlan(plan);

    return plan;
  }

  void _removeUnsafeExercises(WorkoutPlan plan, Set<String> unsafeIds) {
    for (final week in plan.weeks) {
      for (final day in week.days) {
        day.exercises.removeWhere((pe) => unsafeIds.contains(pe.exerciseId));
      }
    }
  }
}
