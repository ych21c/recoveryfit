import '../../core/constants/injury_rules.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/workout_plan.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/log_repository.dart';
import '../../data/services/llm_service.dart';
import '../../data/services/storage_service.dart';

class AdjustPlanUseCase {
  final ExerciseRepository _exerciseRepo;
  final LlmService _llm;
  final StorageService _storage;
  final LogRepository _logRepo;

  AdjustPlanUseCase({
    ExerciseRepository? exerciseRepo,
    LlmService? llm,
    StorageService? storage,
    LogRepository? logRepo,
  })  : _exerciseRepo = exerciseRepo ?? ExerciseRepository.instance,
        _llm = llm ?? LlmService.instance,
        _storage = storage ?? StorageService.instance,
        _logRepo = logRepo ?? LogRepository.instance;

  Future<WorkoutPlan> call({
    required UserProfile profile,
    required WorkoutPlan currentPlan,
  }) async {
    final apiKey = _storage.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('API 키가 설정되지 않았습니다.');
    }

    if (!_storage.canMakeLlmCall) throw LlmCallLimitException();

    if (!_storage.canAdjustWeekly) {
      throw StateError('주간 조정은 7일에 한 번만 가능합니다.');
    }

    // 1) Build week summary from logs
    final weekSummary = _logRepo.buildWeekSummary();

    // 2) Filter exercises
    final allowedExercises = await _exerciseRepo.getFilteredExercises(profile);
    final exclusionTags =
        InjuryRules.getExclusionTags(profile.detectedBodyParts);

    // 3) Call LLM (Haiku for weekly adjust)
    final newPlan = await _llm.adjustWeeklyPlan(
      apiKey: apiKey,
      profile: profile,
      currentPlan: currentPlan,
      allowedExercises: allowedExercises,
      exclusionTags: exclusionTags,
      weekSummary: weekSummary,
    );

    // 4) Server-side re-validation
    final allExerciseIds = newPlan.weeks
        .expand((w) => w.days)
        .expand((d) => d.exercises)
        .map((pe) => pe.exerciseId)
        .toList();

    final unsafeIds = await _exerciseRepo.findUnsafeExercises(
      allExerciseIds,
      profile.detectedBodyParts,
    );

    if (unsafeIds.isNotEmpty) {
      _removeUnsafeExercises(newPlan, unsafeIds.toSet());
    }

    // 5) Update counters & persist
    await _storage.incrementLlmCalls();
    await _storage.setLastWeeklyAdjust(DateTime.now());
    await _storage.savePlan(newPlan);

    return newPlan;
  }

  void _removeUnsafeExercises(WorkoutPlan plan, Set<String> unsafeIds) {
    for (final week in plan.weeks) {
      for (final day in week.days) {
        day.exercises.removeWhere((pe) => unsafeIds.contains(pe.exerciseId));
      }
    }
  }
}
