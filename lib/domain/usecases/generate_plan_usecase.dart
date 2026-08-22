import '../../core/constants/injury_rules.dart';
import '../../data/models/exercise.dart';
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

    // 1) Environment + injury filter
    final allowedExercises = await _exerciseRepo.getFilteredExercises(profile);

    // 2) Collect exclusion tags for LLM prompt enforcement
    final exclusionTags =
        InjuryRules.getExclusionTags(profile.detectedBodyParts);

    late final WorkoutPlan plan;
    if (apiKey == null || apiKey.isEmpty) {
      // Anthropic API 키를 아직 설정하지 않은 사용자(최초 실행/QA·데모 환경 등)도
      // 온보딩 직후 홈 화면까지는 막힘 없이 도달할 수 있어야 한다 — 실기기 로보
      // 테스트가 키 미설정 상태로 "AI 플랜 생성하기"를 누르면 이전엔 여기서 바로
      // StateError를 던져 온보딩 이후 화면(홈 대시보드 등)을 전혀 검증할 수
      // 없었다. 키가 있으면 기존 LLM 개인화 플랜을, 없으면 로컬 규칙 기반의
      // 기본 플랜을 생성해 항상 정상적인 홈 화면으로 진입시킨다.
      plan = _buildLocalPlan(profile: profile, allowedExercises: allowedExercises);
    } else {
      if (!_storage.canMakeLlmCall) throw LlmCallLimitException();

      // 3) Call LLM (Sonnet for initial plan)
      plan = await _llm.generateInitialPlan(
        apiKey: apiKey,
        profile: profile,
        allowedExercises: allowedExercises,
        exclusionTags: exclusionTags,
      );

      // LLM 호출 횟수는 실제로 호출했을 때만 차감
      await _storage.incrementLlmCalls();
    }

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

    // 5) Persist
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

  static const _weekThemes = ['안정화 및 활성화', '가동성 확장', '근지구력 강화', '기능 회복 마무리'];

  // day_of_week(1=월~7=일) 후보 — weeklyFrequency에 맞게 앞에서부터 균등하게 뽑는다.
  static const List<Map<int, List<int>>> _dowByFrequency = [
    {2: [1, 4]},
    {3: [1, 3, 5]},
    {4: [1, 2, 4, 6]},
    {5: [1, 2, 3, 5, 6]},
    {6: [1, 2, 3, 4, 5, 6]},
    {7: [1, 2, 3, 4, 5, 6, 7]},
  ];

  List<int> _daysOfWeek(int frequency) {
    for (final entry in _dowByFrequency) {
      final dow = entry[frequency];
      if (dow != null) return dow;
    }
    if (frequency <= 1) return const [1];
    // frequency 범위를 벗어나면 1주 시작부터 균등 분산
    return List.generate(frequency.clamp(1, 7), (i) => i + 1);
  }

  List<Exercise> _byPhase(List<Exercise> pool, String phase) =>
      pool.where((e) => e.phaseTags.contains(phase)).toList();

  Exercise _pick(List<Exercise> phasePool, List<Exercise> fallbackPool, int index) {
    final pool = phasePool.isNotEmpty ? phasePool : fallbackPool;
    return pool[index % pool.length];
  }

  /// API 키 없이도 온보딩 이후 화면을 항상 정상적으로 보여주기 위한 규칙 기반
  /// 기본 플랜 — LLM과 동일하게 exercise_repository가 이미 걸러준
  /// allowedExercises(환경/부상 안전 필터 통과)만 사용하고, 통증 수준이 높을수록
  /// 세트 수를 보수적으로 줄인다.
  WorkoutPlan _buildLocalPlan({
    required UserProfile profile,
    required List<Exercise> allowedExercises,
  }) {
    if (allowedExercises.isEmpty) {
      throw StateError('현재 조건에 맞는 운동 데이터를 찾지 못했습니다.');
    }
    final warmup = _byPhase(allowedExercises, 'warmup');
    final rehab = _byPhase(allowedExercises, 'rehab');
    final main = _byPhase(allowedExercises, 'main');
    final cooldown = _byPhase(allowedExercises, 'cooldown');
    final dow = _daysOfWeek(profile.weeklyFrequency);
    final baseSets = profile.painLevel >= 7 ? 2 : (profile.painLevel >= 4 ? 3 : 4);

    final weeks = <WorkoutWeek>[];
    var slot = 0;
    for (var w = 1; w <= 4; w++) {
      final days = <WorkoutDay>[];
      for (final d in dow) {
        final exercises = <PlannedExercise>[
          PlannedExercise(
            exerciseId: _pick(warmup, allowedExercises, slot).id,
            phase: 'warmup',
            sets: 1,
            reps: '30s',
            restSeconds: 20,
            coachNote: '가볍게 몸을 풀어주세요',
          ),
          PlannedExercise(
            exerciseId: _pick(rehab.isNotEmpty ? rehab : main, allowedExercises, slot).id,
            phase: 'rehab',
            sets: baseSets,
            reps: '10-12',
            restSeconds: 60,
            intensityNote: 'RPE 4-5',
          ),
          PlannedExercise(
            exerciseId: _pick(main, allowedExercises, slot + 1).id,
            phase: 'main',
            sets: baseSets,
            reps: '10-12',
            restSeconds: 60,
            intensityNote: 'RPE 5-${5 + w.clamp(0, 3)}',
          ),
          PlannedExercise(
            exerciseId: _pick(cooldown, allowedExercises, slot).id,
            phase: 'cooldown',
            sets: 1,
            reps: '30s',
            restSeconds: 15,
            coachNote: '천천히 스트레칭하며 마무리하세요',
          ),
        ];
        days.add(WorkoutDay(
          dayOfWeek: d,
          focusArea: profile.detectedBodyParts.isNotEmpty
              ? profile.detectedBodyParts.first
              : '전신',
          estimatedMinutes: 35 + baseSets * 3,
          exercises: exercises,
        ));
        slot++;
      }
      weeks.add(WorkoutWeek(
        weekNumber: w,
        theme: _weekThemes[(w - 1).clamp(0, _weekThemes.length - 1)],
        days: days,
        progressionNote: w == 1 ? '통증 반응을 보며 강도를 조절하세요' : '이전 주 완료율에 맞춰 점진적으로 강도를 높였습니다',
      ));
    }

    return WorkoutPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userProfileId: profile.id,
      createdAt: DateTime.now(),
      weeks: weeks,
      safetyDisclaimer: '⚠️ 의료기기가 아님. 전문의 상담 권장.',
    );
  }
}
