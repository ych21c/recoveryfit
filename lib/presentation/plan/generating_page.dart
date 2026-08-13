import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../providers/providers.dart';

class GeneratingPage extends ConsumerStatefulWidget {
  final UserProfile profile;
  const GeneratingPage({super.key, required this.profile});

  @override
  ConsumerState<GeneratingPage> createState() => _GeneratingPageState();
}

class _GeneratingPageState extends ConsumerState<GeneratingPage> {
  int _currentStep = 0;  // 0..3
  double _progress = 0;
  Timer? _stepTimer;
  String? _error;

  static const _steps = [
    ('부상 데이터 분석', '무릎 인대 손상 패턴 분석 중'),
    ('안전 규칙 검증 (1차)', '프롬프트 레벨 안전 제약 적용'),
    ('안전 규칙 검증 (2차)', '서버 사이드 10개 규칙 검증 중...'),
    ('4주 플랜 생성', '개인화 루틴 JSON 작성'),
  ];

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    // Animate through first 3 steps while LLM runs
    _advanceStep(delay: 0.5);
    _advanceStep(delay: 1.5);
    _advanceStep(delay: 2.5);

    try {
      await ref.read(planProvider.notifier).generatePlan(widget.profile);
      if (!mounted) return;
      final err = ref.read(planProvider.notifier).errorMessage;
      if (err != null) throw Exception(err);

      // Mark last step done
      setState(() {
        _currentStep = 4;
        _progress = 1;
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _advanceStep({required double delay}) {
    Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
      if (!mounted) return;
      setState(() {
        if (_currentStep < 3) _currentStep++;
        _progress = _currentStep / 4;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Robot icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AI가 맞춤 플랜을 만들고 있어요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.profile.detectedBodyParts.isNotEmpty ? widget.profile.detectedBodyParts.first : '부상'} 안전 규칙 검증 및\n4주 재활 운동 플랜을 생성합니다',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Progress steps
              ...List.generate(_steps.length, (i) {
                final isDone = _currentStep > i;
                final isActive = _currentStep == i;
                return _ProgressStep(
                  title: _steps[i].$1,
                  subtitle: _steps[i].$2,
                  isDone: isDone,
                  isActive: isActive,
                );
              }),

              const SizedBox(height: 24),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppTheme.border,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(_progress * 100).round()}% 완료',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(
                            color: AppTheme.error, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _error = null;
                            _currentStep = 0;
                            _progress = 0;
                          });
                          _startGeneration();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error),
                        child: const Text('재시도'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;

  const _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFFEEF7F4)
            : isActive
                ? AppTheme.surface
                : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? AppTheme.primary
              : isActive
                  ? AppTheme.secondary
                  : AppTheme.border,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [BoxShadow(
                color: AppTheme.secondary.withValues(alpha: 0.2),
                blurRadius: 8,
              )]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppTheme.primary
                  : isActive
                      ? AppTheme.secondary
                      : AppTheme.border,
            ),
            child: Center(
              child: Text(
                isDone ? '✓' : isActive ? '⚙' : '📋',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            isDone
                ? '완료'
                : isActive
                    ? '진행 중'
                    : '대기',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDone
                  ? AppTheme.primary
                  : isActive
                      ? AppTheme.secondary
                      : AppTheme.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
