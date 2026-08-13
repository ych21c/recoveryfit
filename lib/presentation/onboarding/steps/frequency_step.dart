import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FrequencyStep extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const FrequencyStep({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주 몇 회 운동하고 싶으세요?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '4주 플랜의 주간 운동일 수를 설정합니다.',
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 40),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: value > 1 ? () => onChanged(value - 1) : null,
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    Text(
                      '$value회',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Text(
                      '/ 주',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                _CircleButton(
                  icon: Icons.add,
                  onTap: value < 6 ? () => onChanged(value + 1) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _RecommendationCard(frequency: value),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primary : AppTheme.border,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: enabled ? Colors.white : AppTheme.textSecondary,
            size: 28),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final int frequency;
  const _RecommendationCard({required this.frequency});

  String _rec() {
    if (frequency <= 2) return '주 2회 이하: 완전 초보자나 급성 재활 초기에 적합합니다.';
    if (frequency <= 3) return '주 3회: 근력 운동의 기본 빈도. 충분한 회복 시간을 확보합니다.';
    if (frequency <= 4) return '주 4회: 중급 수준. 부위 분할 훈련에 적합합니다.';
    if (frequency <= 5) return '주 5회: 고급 수준. 회복 관리에 주의하세요.';
    return '주 6회: 상급 운동선수 수준. 충분한 수면과 영양 섭취가 필요합니다.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _rec(),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
