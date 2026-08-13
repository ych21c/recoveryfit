import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InjuryStep extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const InjuryStep({super.key, required this.value, required this.onChanged});

  @override
  State<InjuryStep> createState() => _InjuryStepState();
}

class _InjuryStepState extends State<InjuryStep> {
  late final TextEditingController _ctrl;

  static const _examples = [
    '무릎 인대 나갔어요',
    '허리 디스크 초기',
    '어깨 회전근개 통증',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _fill(String text) {
    _ctrl.text = text;
    _ctrl.selection = TextSelection.collapsed(offset: text.length);
    widget.onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('부상 / 통증 설명'),
          TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: '부상이나 통증 부위를 입력해주세요',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 4),
          const _FieldLabel('빠른 선택 예시'),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _examples.map((e) {
              final sel = widget.value == e;
              return GestureDetector(
                onTap: () => _fill(e),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppTheme.primary
                        : const Color(0xFFEEF7F4),
                    border: Border.all(
                      color: sel
                          ? AppTheme.primary
                          : const Color(0xFFB2D8CF),
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel
                          ? Colors.white
                          : AppTheme.primaryDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7F4),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppTheme.primary, width: 3),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Quick-Edit 안내',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '예시 칩을 탭하면 입력창에 자동 완성됩니다. 키보드로 세부 내용을 수정할 수도 있어요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.6,
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      );
}
