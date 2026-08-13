import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/daily_log.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_plan.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/pain_level_slider.dart';
import '../providers/providers.dart';

class ChecklistPage extends ConsumerStatefulWidget {
  const ChecklistPage({super.key});

  @override
  ConsumerState<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends ConsumerState<ChecklistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLog());
  }

  Future<void> _loadLog() async {
    final profile = ref.read(profileProvider);
    final plan = ref.read(planProvider);
    if (profile == null || plan == null) return;
    await ref
        .read(checklistProvider.notifier)
        .loadToday(profile, plan);
  }

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(checklistProvider);
    final exerciseIndex = ref.watch(exerciseIndexProvider);
    final planRepo = ref.read(planRepoProvider);
    final today = planRepo.getTodayWorkout();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Text('오늘 운동'),
            Text(
              DateFormat('M월 d일 (E)', 'ko').format(DateTime.now()),
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      body: today == null
          ? _RestDayView()
          : log == null
              ? const Center(child: CircularProgressIndicator())
              : exerciseIndex.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('오류: $e')),
                  data: (index) => _ChecklistBody(
                    log: log,
                    workoutDay: today,
                    exerciseIndex: index,
                    onStatusChange: (exerciseId, status) => ref
                        .read(checklistProvider.notifier)
                        .markExercise(exerciseId, status),
                    onPainUpdate: (level) => ref
                        .read(checklistProvider.notifier)
                        .updateOverallPain(level),
                  ),
                ),
    );
  }
}

class _ChecklistBody extends StatefulWidget {
  final DailyLog log;
  final WorkoutDay workoutDay;
  final Map<String, Exercise> exerciseIndex;
  final void Function(String, ExerciseStatus) onStatusChange;
  final void Function(int) onPainUpdate;

  const _ChecklistBody({
    required this.log,
    required this.workoutDay,
    required this.exerciseIndex,
    required this.onStatusChange,
    required this.onPainUpdate,
  });

  @override
  State<_ChecklistBody> createState() => _ChecklistBodyState();
}

class _ChecklistBodyState extends State<_ChecklistBody> {
  bool _showPainSlider = false;

  @override
  Widget build(BuildContext context) {
    final completionPct =
        (widget.log.completionRate * 100).round();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                _ProgressHeader(
                  completed: widget.log.completedCount,
                  total: widget.log.entries.length,
                  percentage: completionPct,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showPainSlider = !_showPainSlider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.healing_outlined,
                            color: AppTheme.painColor(
                                widget.log.overallPainLevel),
                            size: 20),
                        const SizedBox(width: 10),
                        Text(
                          '오늘 통증: ${widget.log.overallPainLevel}/10',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _showPainSlider
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showPainSlider) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: PainLevelSlider(
                      value: widget.log.overallPainLevel,
                      onChanged: widget.onPainUpdate,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final entry = widget.log.entries[i];
              final exercise = widget.exerciseIndex[entry.exerciseId];
              if (exercise == null) return const SizedBox.shrink();

              // Match from the plan's workout day for sets/reps/notes
              final planned = widget.workoutDay.exercises
                  .where((pe) => pe.exerciseId == entry.exerciseId)
                  .firstOrNull ??
                  PlannedExercise(
                    exerciseId: entry.exerciseId,
                    phase: 'main',
                    sets: 3,
                    reps: '10',
                    restSeconds: 60,
                  );

              return ExerciseCard(
                exercise: exercise,
                planned: planned,
                logEntry: entry,
                onStatusChange: (status) =>
                    widget.onStatusChange(entry.exerciseId, status),
              );
            },
            childCount: widget.log.entries.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

}

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final int percentage;

  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed / $total 완료',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: total > 0 ? completed / total : 0,
                  backgroundColor: AppTheme.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😴', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              '오늘은 휴식일이에요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '충분한 휴식도 운동만큼 중요합니다.\n가벼운 스트레칭이나 산책을 추천드려요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
