import '../models/workout_plan.dart';
import '../services/storage_service.dart';

class PlanRepository {
  PlanRepository._();
  static final PlanRepository instance = PlanRepository._();

  final _storage = StorageService.instance;

  WorkoutPlan? get activePlan => _storage.activePlan;

  Future<void> savePlan(WorkoutPlan plan) => _storage.savePlan(plan);

  List<WorkoutPlan> get allPlans => _storage.allPlans;

  /// Returns today's workout day from the active plan, or null on rest days.
  WorkoutDay? getTodayWorkout() {
    final plan = activePlan;
    if (plan == null) return null;
    return plan.getDayForDate(DateTime.now());
  }

  /// Returns the workout for a specific date.
  WorkoutDay? getWorkoutForDate(DateTime date) {
    final plan = activePlan;
    if (plan == null) return null;
    return plan.getDayForDate(date);
  }
}
