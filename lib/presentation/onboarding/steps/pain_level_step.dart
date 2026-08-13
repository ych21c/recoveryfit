import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PainLevelStep extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PainLevelStep({
    super.key,
    required this.value,
    required this.onChanged,
  });

  // Colour per chip index 1-10
  static const _chipColors = [
    Color(0xFF27AE60), // 1
    Color(0xFF4CAF50), // 2
    Color(0xFF8BC34A), // 3
    Color(0xFFCDDC39), // 4
    Color(0xFFF39C12), // 5 (default)
    Color(0xFFFFC107), // 6
    Color(0xFFFF9800), // 7
    Color(0xFFFF5722), // 8
    Color(0xFFF44336), // 9
    Color(0xFFB71C1C), // 10
  ];

  static const _chipTextDark = {4, 6}; // yellow chips → dark text

  String get _painDesc {
    if (value <= 2) return '😌 경미 — 일상생활에 거의 지장 없음';
    if (value <= 4) return '😐 경미~중등도 — 약간의 불편함';
    if (value <= 6) return '⚡ 중등도 — 활동 시 불편하지만 참을 수 있음';
    if (value <= 8) return '😣 심함 — 활동에 상당한 지장';
    return '🔴 극심 — 즉시 전문의 상담 권장';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          // Large value display
          Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: _chipColors[value - 1],
                ),
              ),
              Text(
                _painDesc,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _chipColors[value - 1],
              inactiveTrackColor: AppTheme.border,
              thumbColor: _chipColors[value - 1],
              overlayColor: _chipColors[value - 1].withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              trackHeight: 8,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 (없음)',
                  style: TextStyle(fontSize: 10, color: AppTheme.textDisabled)),
              Text('5 (중등도)',
                  style: TextStyle(fontSize: 10, color: AppTheme.textDisabled)),
              Text('10 (극심)',
                  style: TextStyle(fontSize: 10, color: AppTheme.textDisabled)),
            ],
          ),

          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '숫자로 직접 선택',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Number chips row
          Row(
            children: List.generate(10, (i) {
              final n = i + 1;
              final bgColor = _chipColors[i];
              final isDark = _chipTextDark.contains(n);
              final isSel = n == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(n),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 9 ? 4 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isSel
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                      boxShadow: isSel
                          ? [BoxShadow(color: bgColor.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)]
                          : null,
                    ),
                    child: Text(
                      '$n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.textPrimary : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🟢 경미',
                  style: TextStyle(fontSize: 11, color: AppTheme.success)),
              Text('🟡 중등도',
                  style: TextStyle(fontSize: 11, color: AppTheme.warning)),
              Text('🔴 심함',
                  style: TextStyle(fontSize: 11, color: AppTheme.error)),
            ],
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(color: AppTheme.secondary, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '기본값: 5점',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC96A00),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '변경이 없으면 그대로 \'다음\'을 누르세요 (원터치 통과)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
