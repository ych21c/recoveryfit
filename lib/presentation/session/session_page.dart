import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/daily_log.dart';
import '../../data/models/workout_plan.dart';
import '../../data/repositories/exercise_repository.dart';
import '../providers/providers.dart';
import 'session_args.dart';

class _SetData {
  double weight;
  int reps;
  bool completed;
  _SetData({required this.weight, required this.reps, this.completed = false});
  _SetData copy() => _SetData(weight: weight, reps: reps, completed: completed);
}

class SessionPage extends ConsumerStatefulWidget {
  final SessionArgs args;
  const SessionPage({super.key, required this.args});

  @override
  ConsumerState<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPage> {
  late List<_SetData> _sets;
  int? _editingSetIndex;  // null = no overlay
  bool _editingWeight = true; // true=weight, false=reps

  // Rest timer
  int _restSeconds = 0;
  Timer? _timer;

  // Quick-edit selected field
  final _repOptions = [-1, 1];
  final _weightOptions = [-5.0, -1.0, 1.0, 5.0];

  @override
  void initState() {
    super.initState();
    _initSets();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  PlannedExercise get _exercise =>
      widget.args.exercises[widget.args.exerciseIndex];

  String get _exerciseName {
    final ex = ExerciseRepository.instance.getById(_exercise.exerciseId);
    return ex?.nameKo ?? _exercise.exerciseId;
  }

  void _initSets() {
    // Try to pre-fill from previous log entry or use defaults
    final defaultReps = int.tryParse(_exercise.reps.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
    _sets = List.generate(
      _exercise.sets,
      (_) => _SetData(weight: 0, reps: defaultReps),
    );
  }

  void _toggleSet(int i) {
    setState(() {
      _sets[i].completed = !_sets[i].completed;
    });
    if (_sets[i].completed) {
      _startRestTimer();
      // Mark in log
      ref.read(checklistProvider.notifier).markExercise(
            _exercise.exerciseId,
            ExerciseStatus.completed,
          );
    }
  }

  void _addSet() {
    setState(() {
      final last = _sets.last;
      _sets.add(_SetData(weight: last.weight, reps: last.reps));
    });
  }

  void _deleteSet(int i) {
    if (_sets.length > 1) {
      setState(() => _sets.removeAt(i));
    }
  }

  void _startRestTimer() {
    _timer?.cancel();
    setState(() => _restSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds <= 0) {
        t.cancel();
        setState(() => _restSeconds = 0);
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _dismissTimer() {
    _timer?.cancel();
    setState(() => _restSeconds = 0);
  }

  void _openQuickEdit(int setIndex, bool isWeight) {
    setState(() {
      _editingSetIndex = setIndex;
      _editingWeight = isWeight;
    });
  }

  void _closeQuickEdit() => setState(() => _editingSetIndex = null);

  void _adjustWeight(double delta) {
    if (_editingSetIndex == null) return;
    setState(() {
      final newW = (_sets[_editingSetIndex!].weight + delta).clamp(0.0, 300.0);
      _sets[_editingSetIndex!].weight = newW;
    });
  }

  void _adjustReps(int delta) {
    if (_editingSetIndex == null) return;
    setState(() {
      final newR = (_sets[_editingSetIndex!].reps + delta).clamp(1, 100);
      _sets[_editingSetIndex!].reps = newR;
    });
  }

  void _endSession() {
    context.go(AppRoutes.sessionComplete, extra: _buildCompleteArgs());
  }

  Map<String, dynamic> _buildCompleteArgs() {
    final totalSets = _sets.where((s) => s.completed).length;
    final totalVolume = _sets.fold<double>(0, (sum, s) {
      if (s.completed) return sum + s.weight * s.reps;
      return sum;
    });
    return {
      'exerciseName': _exerciseName,
      'totalSets': totalSets,
      'totalVolume': totalVolume.round(),
      'prevPainScore': ref.read(checklistProvider)?.overallPainLevel ?? 5,
    };
  }

  (String, Color) get _phaseInfo {
    switch (_exercise.phase) {
      case 'warmup':  return ('준비운동', AppTheme.primary);
      case 'rehab':   return ('재활/보조', const Color(0xFFC96A00));
      case 'cooldown':return ('쿨다운', const Color(0xFF5C6BC0));
      default:        return ('메인 운동', const Color(0xFF5C6BC0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (phaseLabel, phaseColor) = _phaseInfo;
    final completedCount = _sets.where((s) => s.completed).length;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Gradient header
              Container(
                decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text('오늘의 운동',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 13)),
                            ]),
                          ),
                        ),
                        Text(
                          _exerciseName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          _MetaChip(phaseLabel),
                          const SizedBox(width: 8),
                          _MetaChip('예상 ${_exercise.restSeconds ~/ 60 + 5}분'),
                          const SizedBox(width: 8),
                          _MetaChip('${_sets.length}세트'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

              // Pre-fill banner
              Container(
                color: const Color(0xFFEEF7F4),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: const Row(children: [
                  Text('✨', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text('이전 세션 기록이 자동으로 채워졌습니다',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary)),
                ]),
              ),

              // Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                  children: [
                    // Guide box
                    if (_exercise.coachNote.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('운동 가이드',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(height: 8),
                            Text(_exercise.coachNote,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                    height: 1.5)),
                          ],
                        ),
                      ),
                    ],

                    // Column headers
                    const _SetHeader(),

                    // Set rows
                    ...List.generate(_sets.length, (i) {
                      final s = _sets[i];
                      return _SetRow(
                        index: i,
                        setData: s,
                        isActive: i == completedCount,
                        onToggle: () => _toggleSet(i),
                        onWeightTap: () => _openQuickEdit(i, true),
                        onRepsTap: () => _openQuickEdit(i, false),
                        onDelete: () => _deleteSet(i),
                      );
                    }),

                    // Add set button
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _addSet,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.border,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('+ 세트 추가',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // End session button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _endSession,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error),
                        child: const Text('세션 종료'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Rest timer bar
          if (_restSeconds > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _RestTimerBar(
                seconds: _restSeconds,
                onDismiss: _dismissTimer,
              ),
            ),

          // Quick-edit overlay
          if (_editingSetIndex != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeQuickEdit,
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),
          if (_editingSetIndex != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _QuickEditSheet(
                setIndex: _editingSetIndex!,
                setData: _sets[_editingSetIndex!],
                isWeight: _editingWeight,
                weightOptions: _weightOptions,
                repOptions: _repOptions,
                onAdjustWeight: _adjustWeight,
                onAdjustReps: _adjustReps,
                onSwitchToWeight: () => setState(() => _editingWeight = true),
                onSwitchToReps: () => setState(() => _editingWeight = false),
                onDone: _closeQuickEdit,
              ),
            ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  const _MetaChip(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 11, color: Colors.white)),
      );
}

class _SetHeader extends StatelessWidget {
  const _SetHeader();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(4, 0, 4, 6),
        child: Row(children: [
          SizedBox(width: 36,
            child: Text('세트',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDisabled))),
          Expanded(child: Center(child: Text('무게(kg)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDisabled)))),
          Expanded(child: Center(child: Text('횟수(회)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDisabled)))),
          SizedBox(width: 48, child: Center(child: Text('완료',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDisabled)))),
        ]),
      );
}

class _SetRow extends StatelessWidget {
  final int index;
  final _SetData setData;
  final bool isActive;
  final VoidCallback onToggle;
  final VoidCallback onWeightTap;
  final VoidCallback onRepsTap;
  final VoidCallback onDelete;

  const _SetRow({
    required this.index,
    required this.setData,
    required this.isActive,
    required this.onToggle,
    required this.onWeightTap,
    required this.onRepsTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = setData.completed
        ? const Color(0xFFD4EDE5)
        : isActive
            ? const Color(0xFFEEF7F4)
            : AppTheme.surfaceAlt;
    final chipText = setData.completed
        ? AppTheme.primaryDark
        : AppTheme.textPrimary;
    final chipBorder = setData.completed
        ? AppTheme.primaryLight
        : isActive
            ? AppTheme.primary
            : AppTheme.border;

    return Dismissible(
      key: ValueKey('set_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: setData.completed
              ? const Color(0xFFEEF7F4)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isActive && !setData.completed
              ? Border.all(color: AppTheme.primary, width: 1.5)
              : Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
          ],
        ),
        child: Row(children: [
          SizedBox(
            width: 36,
            child: Text('${index + 1}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: setData.completed
                        ? AppTheme.primary
                        : AppTheme.textSecondary)),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onWeightTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: chipBorder, width: 1.5),
                  ),
                  child: Text(
                    '${setData.weight % 1 == 0 ? setData.weight.round() : setData.weight} kg',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: chipText),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onRepsTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: chipBorder, width: 1.5),
                  ),
                  child: Text(
                    '${setData.reps} 회',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: chipText),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Center(
              child: GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: setData.completed ? AppTheme.primary : null,
                    border: setData.completed
                        ? null
                        : Border.all(color: AppTheme.border, width: 2),
                  ),
                  child: setData.completed
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Rest Timer Bar ────────────────────────────────────────────────────────────

class _RestTimerBar extends StatelessWidget {
  final int seconds;
  final VoidCallback onDismiss;

  const _RestTimerBar({required this.seconds, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryDark,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Stack(
        children: [
          // Progress line at top
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: seconds / 60,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryLight),
              minHeight: 3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  '0:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                const Text('휴식 타이머',
                    style: TextStyle(fontSize: 12, color: Colors.white60)),
              ]),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('건너뛰기 ▶',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Edit Sheet ─────────────────────────────────────────────────────────

class _QuickEditSheet extends StatelessWidget {
  final int setIndex;
  final _SetData setData;
  final bool isWeight;
  final List<double> weightOptions;
  final List<int> repOptions;
  final void Function(double) onAdjustWeight;
  final void Function(int) onAdjustReps;
  final VoidCallback onSwitchToWeight;
  final VoidCallback onSwitchToReps;
  final VoidCallback onDone;

  const _QuickEditSheet({
    required this.setIndex,
    required this.setData,
    required this.isWeight,
    required this.weightOptions,
    required this.repOptions,
    required this.onAdjustWeight,
    required this.onAdjustReps,
    required this.onSwitchToWeight,
    required this.onSwitchToReps,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
          ),
          Text('${setIndex + 1}세트 수정',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(
            isWeight
                ? '${setData.weight % 1 == 0 ? setData.weight.round() : setData.weight} kg'
                : '${setData.reps} 회',
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary),
          ),
          const SizedBox(height: 16),

          // Weight section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('무게 (KG)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.4)),
          ),
          const SizedBox(height: 8),
          Row(
            children: weightOptions.map((w) {
              final isMinus = w < 0;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onAdjustWeight(w),
                  child: Container(
                    margin: EdgeInsets.only(right: w != weightOptions.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isMinus
                          ? const Color(0xFFFFF5F5)
                          : const Color(0xFFEEF7F4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isMinus
                              ? const Color(0xFFFCCACA)
                              : const Color(0xFFC8E6DD)),
                    ),
                    child: Text(
                      w > 0 ? '+${w.round()}kg' : '${w.round()}kg',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isMinus ? AppTheme.error : AppTheme.primary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Reps section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('횟수 (회)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.4)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            GestureDetector(
              onTap: () => onAdjustReps(-1),
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCCACA)),
                ),
                child: const Text('-1회',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.error)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('${setData.reps} 회',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              ),
            ),
            GestureDetector(
              onTap: () => onAdjustReps(1),
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7F4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC8E6DD)),
                ),
                child: const Text('+1회',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onDone, child: const Text('확인')),
          ),
        ],
      ),
    );
  }
}
