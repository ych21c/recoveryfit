import '../../data/models/daily_log.dart';
import '../../data/models/workout_plan.dart';

class SessionArgs {
  final List<PlannedExercise> exercises;
  final int exerciseIndex;
  final DailyLog? log;

  const SessionArgs({
    required this.exercises,
    required this.exerciseIndex,
    this.log,
  });
}
