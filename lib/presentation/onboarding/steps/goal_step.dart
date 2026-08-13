import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';

class GoalStep extends StatelessWidget {
  final bool isShortTerm;
  final String shortValue;
  final WorkoutGoal longValue;
  final ValueChanged<String> onShortChanged;
  final ValueChanged<WorkoutGoal> onLongChanged;

  const GoalStep({
    super.key,
    required this.isShortTerm,
    required this.shortValue,
    required this.longValue,
    required this.onShortChanged,
    required this.onLongChanged,
  });

  // Short-term goal options
  static const _shortGoals = [
    ('pain_relief', '통증 완화', '현재 통증을 줄이고 일상 생활을 편하게', '🩹'),
    ('mobility', '관절 가동성 회복', '굳어진 관절 범위를 정상으로 되돌리기', '🦵'),
    ('rehab', '부상 재활', '단계적 재활로 부상 부위 기능 회복', '🔄'),
  ];

  // Long-term goal options
  static const _longGoals = [
    (WorkoutGoal.recovery, '스태미나 / 체력 향상', '오래 걷고 뛰어도 지치지 않는 체력 만들기', '⚡'),
    (WorkoutGoal.muscleGain, '근육량 증가', '안전하게 근력을 키우고 체형 개선', '💪'),
    (WorkoutGoal.weightLoss, '체중 감량', '부상 없이 칼로리 소모, 체중 관리', '⚖️'),
  ];

  @override
  Widget build(BuildContext context) {
    if (isShortTerm) {
      return _buildList(
        context,
        defaultLabel: '통증 완화',
        cards: _shortGoals.map((g) => _GoalCard(
          emoji: g.$4,
          title: g.$2,
          subtitle: g.$3,
          selected: shortValue == g.$1,
          onTap: () => onShortChanged(g.$1),
        )).toList(),
      );
    } else {
      return _buildList(
        context,
        defaultLabel: '스태미나/체력 향상',
        cards: _longGoals.map((g) => _GoalCard(
          emoji: g.$4,
          title: g.$2,
          subtitle: g.$3,
          selected: longValue == g.$1,
          onTap: () => onLongChanged(g.$1),
        )).toList(),
      );
    }
  }

  Widget _buildList(BuildContext context,
      {required String defaultLabel, required List<Widget> cards}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cards,
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '✅ $defaultLabel이 기본 선택됩니다. 다른 목표를 탭하면 즉시 변경돼요.',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF7F4) : AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : const Color(0xFFE0F0EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
