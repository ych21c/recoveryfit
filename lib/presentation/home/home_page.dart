import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/daily_log.dart';
import '../../data/models/workout_plan.dart';
import '../../data/repositories/exercise_repository.dart';
import '../providers/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final plan = ref.watch(planProvider);
    final planNotifier = ref.read(planProvider.notifier);
    final todayLog = ref.watch(checklistProvider);
    final planRepo = ref.read(planRepoProvider);
    final today = planRepo.getTodayWorkout();

    return Scaffold(
      body: Column(
        children: [
          _HomeHeader(profile: profile, todayLog: todayLog)
              .animate().fadeIn(duration: 300.ms),
          Expanded(
            child: plan == null
                ? _NoPlanBody(
                    isLoading: planNotifier.isLoading,
                    error: planNotifier.errorMessage,
                    onGenerate: profile != null
                        ? () => ref.read(planProvider.notifier).generatePlan(profile)
                        : null,
                  )
                : _PlanBody(
                    plan: plan,
                    today: today,
                    todayLog: todayLog,
                    exerciseRepo: ExerciseRepository.instance,
                    onBatchComplete: () =>
                        ref.read(checklistProvider.notifier).batchComplete(),
                    onExerciseTap: (index) {
                      if (today != null) {
                        AppRouter.goSession(context,
                            exercises: today.exercises,
                            exerciseIndex: index,
                            log: todayLog);
                      }
                    },
                    onExerciseSkip: (exerciseId) => ref
                        .read(checklistProvider.notifier)
                        .markExercise(exerciseId, ExerciseStatus.skipped),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final dynamic profile;
  final DailyLog? todayLog;
  const _HomeHeader({required this.profile, required this.todayLog});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat("M월 d일 EEEE", "ko").format(DateTime.now());
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("안녕하세요 👋",
                        style: TextStyle(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(children: [
                _StatPill(
                    value: profile?.painLevel != null ? "통증 ${profile!.painLevel}" : "통증 -",
                    label: "점수 ▼"),
                const SizedBox(width: 10),
                const _StatPill(value: "🔥 0일", label: "연속 운동"),
                const SizedBox(width: 10),
                _StatPill(
                    value: "${((todayLog?.completionRate ?? 0) * 100).round()}%",
                    label: "오늘 달성률"),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
          ]),
        ),
      );
}

class _NoPlanBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback? onGenerate;
  const _NoPlanBody({required this.isLoading, this.error, required this.onGenerate});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🤖", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text("운동 플랜이 없습니다",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!,
                    style: const TextStyle(color: AppTheme.error, fontSize: 13),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator(color: AppTheme.primary)
              else
                ElevatedButton(onPressed: onGenerate, child: const Text("AI 플랜 생성하기")),
            ],
          ),
        ),
      );
}

class _PlanBody extends StatelessWidget {
  final WorkoutPlan plan;
  final WorkoutDay? today;
  final DailyLog? todayLog;
  final ExerciseRepository exerciseRepo;
  final VoidCallback onBatchComplete;
  final void Function(int) onExerciseTap;
  final void Function(String) onExerciseSkip;

  const _PlanBody({
    required this.plan,
    required this.today,
    required this.todayLog,
    required this.exerciseRepo,
    required this.onBatchComplete,
    required this.onExerciseTap,
    required this.onExerciseSkip,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _WeekCard(plan: plan, todayLog: todayLog),
        const SizedBox(height: 16),
        if (today == null)
          const _RestDayCard()
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("오늘의 운동 (${today!.exercises.length}개)",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Text("전체 보기",
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onBatchComplete,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFEEF7F4),
                  border: Border.all(color: AppTheme.primary),
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("⚡", style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text("오늘의 운동 일괄 완료",
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(today!.exercises.length, (i) {
            final ex = today!.exercises[i];
            final logEntry = todayLog?.entries
                .where((e) => e.exerciseId == ex.exerciseId)
                .firstOrNull;
            final isDone = logEntry?.statusEnum == ExerciseStatus.completed;
            final isSkipped = logEntry?.statusEnum == ExerciseStatus.skipped;
            return _ExerciseSwipeCard(
              exercise: ex,
              exerciseRepo: exerciseRepo,
              isDone: isDone,
              isSkipped: isSkipped,
              onTap: () => onExerciseTap(i),
              onSkip: () => onExerciseSkip(ex.exerciseId),
            );
          }),
          const SizedBox(height: 8),
          const Center(
            child: Text("← 카드 좌우 스와이프로 운동 스킵 →",
                style: TextStyle(fontSize: 11, color: AppTheme.textDisabled)),
          ),
        ],
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  final WorkoutPlan plan;
  final DailyLog? todayLog;
  const _WeekCard({required this.plan, required this.todayLog});

  @override
  Widget build(BuildContext context) {
    final pct = ((todayLog?.completionRate ?? 0) * 100).round();
    final now = DateTime.now();
    final weekdays = ["월", "화", "수", "목", "금", "토", "일"];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("이번 주 진척도 ($pct%)",
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
              value: (todayLog?.completionRate ?? 0),
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 8),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text("$pct%",
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isToday = now.weekday == i + 1;
            return Column(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: isToday ? AppTheme.primary : AppTheme.surfaceAlt,
                    shape: BoxShape.circle,
                    boxShadow: isToday
                        ? [BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8, spreadRadius: 2)]
                        : null),
                child: Center(
                  child: Text(isToday ? "●" : "-",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isToday ? Colors.white : AppTheme.textDisabled)),
                ),
              ),
              const SizedBox(height: 3),
              Text(weekdays[i],
                  style: const TextStyle(fontSize: 10, color: AppTheme.textDisabled)),
            ]);
          }),
        ),
      ]),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border)),
        child: const Column(children: [
          Text("😴", style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text("오늘은 휴식일입니다",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          SizedBox(height: 4),
          Text("충분한 휴식이 재활의 일부입니다 💪",
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ]),
      );
}

class _ExerciseSwipeCard extends StatefulWidget {
  final PlannedExercise exercise;
  final ExerciseRepository exerciseRepo;
  final bool isDone;
  final bool isSkipped;
  final VoidCallback onTap;
  final VoidCallback onSkip;

  const _ExerciseSwipeCard({
    required this.exercise,
    required this.exerciseRepo,
    required this.isDone,
    required this.isSkipped,
    required this.onTap,
    required this.onSkip,
  });

  @override
  State<_ExerciseSwipeCard> createState() => _ExerciseSwipeCardState();
}

class _ExerciseSwipeCardState extends State<_ExerciseSwipeCard> {
  double _offset = 0;
  static const _threshold = 70.0;

  (String, String, Color) _phaseInfo(String phase) {
    switch (phase) {
      case "warmup":  return ("🌡️", "준비운동", const Color(0xFF2E7D6B));
      case "rehab":   return ("🩹", "재활", const Color(0xFFC96A00));
      case "cooldown":return ("🧊", "쿨다운", const Color(0xFF5C6BC0));
      default:         return ("💪", "메인", const Color(0xFF5C6BC0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final (emoji, label, color) = _phaseInfo(ex.phase);
    final name = widget.exerciseRepo.getById(ex.exerciseId)?.nameKo ?? ex.exerciseId;

    return GestureDetector(
      onHorizontalDragUpdate: (d) =>
          setState(() => _offset = (_offset + d.delta.dx).clamp(-_threshold * 1.2, 0)),
      onHorizontalDragEnd: (_) {
        if (_offset < -_threshold) widget.onSkip();
        setState(() => _offset = 0);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                  color: AppTheme.error, borderRadius: BorderRadius.circular(14)),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("🚫", style: TextStyle(fontSize: 20)),
                SizedBox(height: 2),
                Text("스킵",
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(_offset, 0),
          child: GestureDetector(
            onTap: widget.isSkipped ? null : widget.onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isSkipped ? AppTheme.surfaceAlt : AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.isDone
                        ? AppTheme.primary.withValues(alpha: 0.4)
                        : AppTheme.border,
                    width: widget.isDone ? 1.5 : 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6)
                ],
              ),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    widget.isSkipped ? "$name (스킵됨)" : name,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: widget.isSkipped ? AppTheme.textDisabled : AppTheme.textPrimary,
                        decoration: widget.isSkipped ? TextDecoration.lineThrough : null),
                  ),
                  const SizedBox(height: 2),
                  Text("${ex.sets}세트 × ${ex.reps}",
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99)),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ),
                ])),
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isDone ? AppTheme.primary : null,
                      border: widget.isDone
                          ? null
                          : Border.all(color: AppTheme.border, width: 2)),
                  child: widget.isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
