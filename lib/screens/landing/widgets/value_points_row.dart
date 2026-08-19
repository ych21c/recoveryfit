import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// Three value-proposition columns: icon (in mint glass tile) + label text.
/// Fixed data — landing page only.
class ValuePointsRow extends StatelessWidget {
  const ValuePointsRow({super.key});

  static const _items = [
    _ValueItem(
      icon: Icons.health_and_safety_outlined,
      label: '이중 안전\n검증',
    ),
    _ValueItem(
      icon: Icons.psychology_outlined,
      label: 'AI 개인화\n플랜',
    ),
    _ValueItem(
      icon: Icons.touch_app_outlined,
      label: '터치 최소화\n인터페이스',
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
  final String label;
  const _ValueItem({required this.icon, required this.label});
}

class _ValueItemWidget extends StatelessWidget {
  final _ValueItem item;

  const _ValueItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
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
          item.label,
          textAlign: TextAlign.center,
          style: AppTypography.bodyS.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
