import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_theme.dart';
import '../data/models/daily_log.dart';
import '../data/models/exercise.dart';
import '../data/models/workout_plan.dart';

/// Unified exercise card used on both the checklist and plan detail screens.
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final PlannedExercise planned;
  final ExerciseLogEntry? logEntry; // null when used in plan view (no logging)
  final void Function(ExerciseStatus)? onStatusChange;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.planned,
    this.logEntry,
    this.onStatusChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = logEntry?.statusEnum ?? ExerciseStatus.pending;
    final isCompleted = status == ExerciseStatus.completed;
    final isSkipped = status == ExerciseStatus.skipped;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.primary.withValues(alpha: 0.08)
              : isSkipped
                  ? AppTheme.textSecondary.withValues(alpha: 0.06)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppTheme.primary.withValues(alpha: 0.4)
                : AppTheme.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PhaseBadge(phase: planned.phase),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.nameKo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSkipped
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        decoration: isSkipped
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle,
                        color: AppTheme.primary, size: 22),
                  if (isSkipped)
                    Icon(Icons.skip_next,
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        size: 22),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.repeat,
                    label: '${planned.sets}세트 × ${planned.reps}',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: '휴식 ${planned.restSeconds}초',
                  ),
                  if (planned.intensityNote.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.speed,
                      label: planned.intensityNote,
                    ),
                  ],
                ],
              ),
              if (planned.coachNote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        planned.coachNote,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (onStatusChange != null) ...[
                const SizedBox(height: 12),
                _ActionButtons(
                  status: status,
                  onStatusChange: onStatusChange!,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0);
  }
}

class _PhaseBadge extends StatelessWidget {
  final String phase;
  const _PhaseBadge({required this.phase});

  static const _labels = {
    'warmup': ('준비', Color(0xFFFF9800)),
    'rehab': ('재활', Color(0xFF2196F3)),
    'main': ('메인', Color(0xFF1DB954)),
    'cooldown': ('마무리', Color(0xFF9C27B0)),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labels[phase] ?? ('운동', AppTheme.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ExerciseStatus status;
  final void Function(ExerciseStatus) onStatusChange;

  const _ActionButtons({
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _ActionButton(
            label: '완료',
            icon: Icons.check,
            color: AppTheme.primary,
            selected: status == ExerciseStatus.completed,
            onTap: () => onStatusChange(ExerciseStatus.completed),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _ActionButton(
            label: '스킵',
            icon: Icons.skip_next,
            color: AppTheme.textSecondary,
            selected: status == ExerciseStatus.skipped,
            onTap: () => onStatusChange(ExerciseStatus.skipped),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: selected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
