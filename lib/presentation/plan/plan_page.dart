import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/workout_plan.dart';
import '../providers/providers.dart';

class PlanPage extends ConsumerWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('4주 플랜'),
        backgroundColor: Colors.white,
      ),
      body: plan == null
          ? const Center(
              child: Text(
                '플랜이 없습니다. 먼저 온보딩을 완료해주세요.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : _PlanBody(plan: plan),
    );
  }
}

class _PlanBody extends StatefulWidget {
  final WorkoutPlan plan;
  const _PlanBody({required this.plan});

  @override
  State<_PlanBody> createState() => _PlanBodyState();
}

class _PlanBodyState extends State<_PlanBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.plan.weeks.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: widget.plan.weeks
                .map((w) => Tab(text: '${w.weekNumber}주차'))
                .toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.plan.weeks
                .asMap()
                .entries
                .map(
                  (entry) => _WeekView(
                    week: entry.value,
                    weekIndex: entry.key,
                    plan: widget.plan,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  final WorkoutWeek week;
  final int weekIndex;
  final WorkoutPlan plan;

  const _WeekView({
    required this.week,
    required this.weekIndex,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (week.theme.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined,
                    color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    week.theme,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ...week.days.asMap().entries.map(
              (entry) => _DayCard(
                day: entry.value,
                dayIndex: entry.key,
                weekIndex: weekIndex,
                plan: plan,
              ),
            ),
        if (week.progressionNote.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '📝 ${week.progressionNote}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final WorkoutDay day;
  final int dayIndex;
  final int weekIndex;
  final WorkoutPlan plan;

  const _DayCard({
    required this.day,
    required this.dayIndex,
    required this.weekIndex,
    required this.plan,
  });

  static const _dayNames = ['월', '화', '수', '목', '금', '토', '일'];

  String get _dayName =>
      day.dayOfWeek >= 1 && day.dayOfWeek <= 7
          ? _dayNames[day.dayOfWeek - 1]
          : '?';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(
        '/plan/day/$weekIndex/$dayIndex',
        extra: plan,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _dayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.focusArea,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.exercises.length}개 운동 · 약 ${day.estimatedMinutes}분',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
