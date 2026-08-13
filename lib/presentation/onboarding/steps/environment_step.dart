import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';

class EnvironmentStep extends StatelessWidget {
  final int frequency;
  final WorkoutEnvironment environment;
  final List<String> equipment;
  final ValueChanged<int> onFrequencyChanged;
  final ValueChanged<WorkoutEnvironment> onEnvironmentChanged;
  final ValueChanged<List<String>> onEquipmentChanged;

  const EnvironmentStep({
    super.key,
    required this.frequency,
    required this.environment,
    required this.equipment,
    required this.onFrequencyChanged,
    required this.onEnvironmentChanged,
    required this.onEquipmentChanged,
  });

  static const _freqs = [2, 3, 4, 5];
  static const _equipmentOptions = [
    ('bodyweight', '맨몸'),
    ('dumbbell', '덤벨'),
    ('band', '밴드'),
    ('pullup_bar', '철봉'),
  ];

  void _toggleEquipment(String key) {
    final updated = List<String>.from(equipment);
    if (updated.contains(key)) {
      if (updated.length > 1) updated.remove(key); // keep at least one
    } else {
      updated.add(key);
    }
    onEquipmentChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frequency
          const _SectionTitle('주당 운동 빈도'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _freqs.map((f) {
              final sel = frequency == f;
              return GestureDetector(
                onTap: () => onFrequencyChanged(f),
                child: _FreqChip(label: '주 $f회', selected: sel),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Location
          const _SectionTitle('운동 장소'),
          ...WorkoutEnvironment.values.map((env) {
            final labels = {
              WorkoutEnvironment.home: ('🏠', '집'),
              WorkoutEnvironment.gym: ('🏋️', '헬스장'),
              WorkoutEnvironment.both: ('🔄', '둘 다'),
            };
            final (emoji, label) = labels[env]!;
            return _RadioItem(
              emoji: emoji,
              label: label,
              selected: environment == env,
              onTap: () => onEnvironmentChanged(env),
            );
          }),
          const SizedBox(height: 20),

          // Equipment (shown when home or both)
          const _SectionTitle('보유 장비 (집 선택 시)'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: _equipmentOptions.map((e) {
              final sel = equipment.contains(e.$1);
              return GestureDetector(
                onTap: () => _toggleEquipment(e.$1),
                child: _CheckItem(label: e.$2, selected: sel),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      );
}

class _FreqChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FreqChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _RadioItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioItem({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF7F4) : AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
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
            const SizedBox(width: 12),
            Text('$emoji $label',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool selected;

  const _CheckItem({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEEF7F4) : AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.border,
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
