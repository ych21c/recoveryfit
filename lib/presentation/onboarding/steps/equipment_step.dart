import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';

class EquipmentStep extends StatelessWidget {
  final WorkoutEnvironment environment;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const EquipmentStep({
    super.key,
    required this.environment,
    required this.selected,
    required this.onChanged,
  });

  static const _homeEquipment = [
    ('dumbbell', '덤벨', Icons.fitness_center),
    ('kettlebell', '케틀벨', Icons.sports_martial_arts),
    ('resistance_band', '저항 밴드', Icons.cable),
    ('pull_up_bar', '풀업바', Icons.sports_gymnastics),
    ('foam_roller', '폼롤러', Icons.roller_skating),
    ('stability_ball', '짐볼', Icons.sports_volleyball),
    ('yoga_mat', '요가매트', Icons.self_improvement),
  ];

  static const _gymEquipment = [
    ('barbell', '바벨', Icons.fitness_center),
    ('cable', '케이블 머신', Icons.cable),
    ('smith_machine', '스미스 머신', Icons.hardware),
    ('machine', '운동 기구 일반', Icons.settings),
  ];

  List<(String, String, IconData)> get _displayList {
    return switch (environment) {
      WorkoutEnvironment.home => _homeEquipment,
      WorkoutEnvironment.gym => [..._homeEquipment, ..._gymEquipment],
      WorkoutEnvironment.both => [..._homeEquipment, ..._gymEquipment],
    };
  }

  void _toggle(String id) {
    final updated = List<String>.from(selected);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '보유 장비를 선택해 주세요 (선택 사항)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '선택한 장비를 우선적으로 활용한 운동을 추천합니다.',
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _displayList.map((item) {
              final (id, label, icon) = item;
              final isSelected = selected.contains(id);
              return GestureDetector(
                onTap: () => _toggle(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppTheme.primary : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (selected.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '선택하지 않으면 맨몸 운동 중심으로 구성됩니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
