import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// Three value-proposition columns: icon (in mint glass tile) + two-line label.
/// Fixed data — landing page only.
class ValuePointsRow extends StatelessWidget {
  const ValuePointsRow({super.key});

  static const _items = [
    _ValueItem(
      icon: Icons.health_and_safety_outlined,
      line1: '이중 안전',
      line2: '검증',
    ),
    _ValueItem(
      icon: Icons.psychology_outlined,
      line1: 'AI 개인화',
      line2: '플랜',
    ),
    _ValueItem(
      icon: Icons.touch_app_outlined,
      line1: '터치 최소화',
      line2: '인터페이스',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items
          .map((item) => Expanded(child: _ValueItemWidget(item: item)))
          .toList(),
    );
  }
}

class _ValueItem {
  final IconData icon;
  final String line1;
  final String line2;
  const _ValueItem({required this.icon, required this.line1, required this.line2});
}

class _ValueItemWidget extends StatelessWidget {
  final _ValueItem item;

  const _ValueItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTypography.bodyS.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryMint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryMint.withValues(alpha: 0.30),
            ),
          ),
          child: Icon(
            item.icon,
            color: AppColors.primaryMint,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${item.line1}\n${item.line2}',
          textAlign: TextAlign.center,
          style: labelStyle,
        ),
      ],
    );
  }
}
