import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class PainLevelSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String? label;

  const PainLevelSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        Row(
          children: [
            const Text('1', style: TextStyle(color: AppTheme.textSecondary)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.painColor(value),
                  thumbColor: AppTheme.painColor(value),
                  overlayColor: AppTheme.painColor(value).withValues(alpha: 0.2),
                  inactiveTrackColor: AppTheme.border,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            const Text('10', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.painColor(value).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _label(value),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.painColor(value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _label(int v) {
    if (v <= 2) return '$v — 통증 없음';
    if (v <= 4) return '$v — 약한 불편감';
    if (v <= 6) return '$v — 중간 통증';
    if (v <= 8) return '$v — 강한 통증';
    return '$v — 심한 통증';
  }
}
