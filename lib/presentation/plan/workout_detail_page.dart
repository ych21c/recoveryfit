import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/workout_plan.dart';
import '../../widgets/exercise_card.dart';
import '../providers/providers.dart';

class WorkoutDetailPage extends ConsumerWidget {
  final int weekIndex;
  final int dayIndex;
  final WorkoutPlan? plan;

  const WorkoutDetailPage({
    super.key,
    required this.weekIndex,
    required this.dayIndex,
    this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = plan ?? ref.watch(planProvider);
    if (activePlan == null) {
      return const Scaffold(body: Center(child: Text('플랜 없음')));
    }

    if (weekIndex >= activePlan.weeks.length) {
      return const Scaffold(body: Center(child: Text('잘못된 주차')));
    }

    final week = activePlan.weeks[weekIndex];
    if (dayIndex >= week.days.length) {
      return const Scaffold(body: Center(child: Text('잘못된 운동일')));
    }

    final day = week.days[dayIndex];
    final exerciseIndex = ref.watch(exerciseIndexProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(day.focusArea),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${weekIndex + 1}주차 · ${day.exercises.length}개 운동 · 약 ${day.estimatedMinutes}분',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
      body: exerciseIndex.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (index) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: day.exercises.length,
          itemBuilder: (context, i) {
            final planned = day.exercises[i];
            final exercise = index[planned.exerciseId];
            if (exercise == null) return const SizedBox.shrink();
            return ExerciseCard(
              exercise: exercise,
              planned: planned,
            );
          },
        ),
      ),
    );
  }
}
