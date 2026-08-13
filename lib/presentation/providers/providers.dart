import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/daily_log.dart';
import '../../data/models/exercise.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/workout_plan.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/log_repository.dart';
import '../../data/repositories/plan_repository.dart';
import '../../data/services/storage_service.dart';
import '../../domain/usecases/adjust_plan_usecase.dart';
import '../../domain/usecases/generate_plan_usecase.dart';

// ── Singleton service providers ──────────────────────────────────────────────

final storageServiceProvider = Provider<StorageService>(
  (_) => StorageService.instance,
);

final exerciseRepoProvider = Provider<ExerciseRepository>(
  (_) => ExerciseRepository.instance,
);

final planRepoProvider = Provider<PlanRepository>(
  (_) => PlanRepository.instance,
);

final logRepoProvider = Provider<LogRepository>(
  (_) => LogRepository.instance,
);

// ── User Profile ─────────────────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final StorageService _storage;

  ProfileNotifier(this._storage) : super(_storage.currentProfile);

  Future<void> save(UserProfile profile) async {
    await _storage.saveProfile(profile);
    state = profile;
  }

  void refresh() => state = _storage.currentProfile;
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier(ref.read(storageServiceProvider));
});

// ── Active Plan ───────────────────────────────────────────────────────────────

class PlanNotifier extends StateNotifier<WorkoutPlan?> {
  final StorageService _storage;
  final GeneratePlanUseCase _generateUseCase;
  final AdjustPlanUseCase _adjustUseCase;

  bool isLoading = false;
  String? errorMessage;

  PlanNotifier(this._storage, this._generateUseCase, this._adjustUseCase)
      : super(_storage.activePlan);

  Future<void> generatePlan(UserProfile profile) async {
    isLoading = true;
    errorMessage = null;
    state = state; // trigger rebuild
    try {
      final plan = await _generateUseCase(profile);
      state = plan;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<void> adjustPlan(UserProfile profile) async {
    final current = state;
    if (current == null) return;
    isLoading = true;
    errorMessage = null;
    try {
      final newPlan =
          await _adjustUseCase(profile: profile, currentPlan: current);
      state = newPlan;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  void refresh() => state = _storage.activePlan;
}

final planProvider = StateNotifierProvider<PlanNotifier, WorkoutPlan?>((ref) {
  final storage = ref.read(storageServiceProvider);
  final gen = GeneratePlanUseCase();
  final adj = AdjustPlanUseCase();
  return PlanNotifier(storage, gen, adj);
});

// ── Today's Checklist ─────────────────────────────────────────────────────────

class ChecklistNotifier extends StateNotifier<DailyLog?> {
  final LogRepository _logRepo;
  final PlanRepository _planRepo;

  ChecklistNotifier(this._logRepo, this._planRepo) : super(null);

  Future<void> loadToday(UserProfile profile, WorkoutPlan plan) async {
    final todayDay = _planRepo.getTodayWorkout();
    final log = await _logRepo.getOrCreateTodayLog(
      workoutDay: todayDay,
      planId: plan.id,
      defaultPainLevel: profile.painLevel,
    );
    state = log;
  }

  Future<void> markExercise(
    String exerciseId,
    ExerciseStatus status, {
    int? painLevel,
    String? note,
  }) async {
    final log = state;
    if (log == null) return;
    await _logRepo.markExercise(
      dateKey: log.dateKey,
      exerciseId: exerciseId,
      status: status,
      painLevel: painLevel,
      note: note,
    );
    state = _logRepo.getLog(DateTime.now());
  }

  Future<void> updateOverallPain(int level) async {
    final log = state;
    if (log == null) return;
    await _logRepo.updatePainLevel(log.dateKey, level);
    state = _logRepo.getLog(DateTime.now());
  }

  /// Mark all pending exercises as completed (batch complete).
  Future<void> batchComplete() async {
    final log = state;
    if (log == null) return;
    for (final entry in log.entries) {
      if (entry.statusEnum == ExerciseStatus.pending) {
        await _logRepo.markExercise(
          dateKey: log.dateKey,
          exerciseId: entry.exerciseId,
          status: ExerciseStatus.completed,
        );
      }
    }
    state = _logRepo.getLog(DateTime.now());
  }

  void refresh() => state = _logRepo.getTodayLog();
}

final checklistProvider =
    StateNotifierProvider<ChecklistNotifier, DailyLog?>((ref) {
  return ChecklistNotifier(
    ref.read(logRepoProvider),
    ref.read(planRepoProvider),
  );
});

// ── Exercise Index ────────────────────────────────────────────────────────────

final exerciseIndexProvider =
    FutureProvider<Map<String, Exercise>>((ref) async {
  return ref.read(exerciseRepoProvider).buildIndex();
});

// ── Progress Data ─────────────────────────────────────────────────────────────

class ProgressData {
  final List<MapEntry<DateTime, int>> painTrend; // date → pain level
  final List<MapEntry<DateTime, double>> completionRate; // date → 0..1
  final List<MapEntry<DateTime, int>> weeklyVolume; // week start → exercise count

  const ProgressData({
    required this.painTrend,
    required this.completionRate,
    required this.weeklyVolume,
  });
}

final progressProvider = FutureProvider<ProgressData>((ref) async {
  final logRepo = ref.read(logRepoProvider);
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 28));
  final logs = logRepo.getLogsInRange(start, end);

  final painTrend = logs
      .map((l) => MapEntry(DateTime.parse(l.dateKey), l.overallPainLevel))
      .toList();

  final completionRate = logs
      .map((l) => MapEntry(DateTime.parse(l.dateKey), l.completionRate))
      .toList();

  // Weekly volume: group by week start (Monday)
  final weeklyMap = <DateTime, int>{};
  for (final log in logs) {
    final d = DateTime.parse(log.dateKey);
    final weekStart = d.subtract(Duration(days: d.weekday - 1));
    final normalised =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    weeklyMap[normalised] =
        (weeklyMap[normalised] ?? 0) + log.completedCount;
  }

  final weeklyVolume = weeklyMap.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return ProgressData(
    painTrend: painTrend,
    completionRate: completionRate,
    weeklyVolume: weeklyVolume,
  );
});

// ── Subscription ──────────────────────────────────────────────────────────────

class SubscriptionNotifier extends StateNotifier<bool> {
  final StorageService _storage;

  SubscriptionNotifier(this._storage) : super(_storage.subscriptionActive);

  Future<void> activate(DateTime expiry) async {
    await _storage.setSubscriptionActive(true);
    await _storage.setSubscriptionExpiry(expiry);
    state = true;
  }

  Future<void> deactivate() async {
    await _storage.setSubscriptionActive(false);
    state = false;
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, bool>((ref) {
  return SubscriptionNotifier(ref.read(storageServiceProvider));
});

// ── LLM call remaining ───────────────────────────────────────────────────────

final llmCallsRemainingProvider = Provider<int>((ref) {
  final storage = ref.read(storageServiceProvider);
  return (5 - storage.llmCallsThisMonth).clamp(0, 5);
});
