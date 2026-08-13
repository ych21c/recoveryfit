import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/injury_rules.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/storage_service.dart';
import '../providers/providers.dart';
import 'steps/injury_step.dart';
import 'steps/pain_level_step.dart';
import 'steps/goal_step.dart';
import 'steps/environment_step.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _currentStep = 0;

  // Form state
  String _injuryText = '';
  int _painLevel = 5;
  String _shortGoal = 'pain_relief';    // pain_relief | mobility | rehab
  WorkoutGoal _longGoal = WorkoutGoal.recovery;
  int _frequency = 3;
  WorkoutEnvironment _environment = WorkoutEnvironment.home;
  List<String> _equipment = ['bodyweight'];

  String? _errorMessage;

  static const _totalSteps = 5;

  // Step meta (shown in gradient header)
  static const _stepMeta = [
    ('1 / 5 단계', '어디가 불편하신가요?', '부상 부위나 통증 상황을 자유롭게 알려주세요'),
    ('2 / 5 단계', '지금 통증이 얼마나 심한가요?', 'NRS 척도로 현재 통증 강도를 선택해주세요'),
    ('3 / 5 단계', '지금 당장 원하는 게 뭔가요?', '단기 목표를 선택해주세요 (1개 선택)'),
    ('4 / 5 단계', '궁극적으로 원하는 변화는?', '장기 목표를 선택해주세요 (1개 선택)'),
    ('5 / 5 단계', '운동 환경을 알려주세요', '기본값으로 바로 플랜 생성도 OK'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _startGeneration();
    }
  }

  void _previous() {
    if (_currentStep > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _isCurrentStepValid {
    if (_currentStep == 0) return _injuryText.trim().length >= 5;
    return true;
  }

  Future<void> _startGeneration() async {
    setState(() => _errorMessage = null);

    try {
      final bodyParts = InjuryRules.detectBodyParts(_injuryText);
      final profile = UserProfile(
        id: const Uuid().v4(),
        injuryDescription: '[$_shortGoal] ${_injuryText.trim()}',
        painLevel: _painLevel,
        goal: _longGoal.name,
        weeklyFrequency: _frequency,
        environment: _environment.name,
        equipment: _equipment,
        createdAt: DateTime.now(),
        detectedBodyParts: bodyParts,
      );

      await ref.read(profileProvider.notifier).save(profile);
      await StorageService.instance.setOnboardingDone();

      if (mounted) {
        context.go(AppRoutes.generating, extra: profile);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (badge, title, subtitle) = _stepMeta[_currentStep];
    return Scaffold(
      body: Column(
        children: [
          _GradientHeader(
            badge: badge,
            title: title,
            subtitle: subtitle,
            currentStep: _currentStep,
            totalSteps: _totalSteps,
            onBack: _currentStep > 0 ? _previous : null,
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                InjuryStep(
                  value: _injuryText,
                  onChanged: (v) => setState(() => _injuryText = v),
                ),
                PainLevelStep(
                  value: _painLevel,
                  onChanged: (v) => setState(() => _painLevel = v),
                ),
                GoalStep(
                  isShortTerm: true,
                  shortValue: _shortGoal,
                  longValue: _longGoal,
                  onShortChanged: (v) => setState(() => _shortGoal = v),
                  onLongChanged: (v) => setState(() => _longGoal = v),
                ),
                GoalStep(
                  isShortTerm: false,
                  shortValue: _shortGoal,
                  longValue: _longGoal,
                  onShortChanged: (v) => setState(() => _shortGoal = v),
                  onLongChanged: (v) => setState(() => _longGoal = v),
                ),
                EnvironmentStep(
                  frequency: _frequency,
                  environment: _environment,
                  equipment: _equipment,
                  onFrequencyChanged: (v) => setState(() => _frequency = v),
                  onEnvironmentChanged: (v) => setState(() => _environment = v),
                  onEquipmentChanged: (v) => setState(() => _equipment = v),
                ),
              ],
            ),
          ),
          _Footer(
            isLast: _currentStep == _totalSteps - 1,
            enabled: _isCurrentStepValid,
            errorMessage: _errorMessage,
            onNext: _next,
          ),
        ],
      ),
    );
  }
}

// ── Gradient Header ──────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const _GradientHeader({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button row
              if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '이전',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(height: 10),

              // Step pip indicators
              Row(
                children: List.generate(totalSteps, (i) {
                  final isDone = i < currentStep;
                  final isActive = i == currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.white.withValues(alpha: 0.7)
                            : isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final bool isLast;
  final bool enabled;
  final String? errorMessage;
  final VoidCallback onNext;

  const _Footer({
    required this.isLast,
    required this.enabled,
    required this.onNext,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: AppTheme.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onNext : null,
              child: Text(isLast ? '🤖 AI 플랜 생성하기' : '다음'),
            ),
          ),
          if (!enabled)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '최소 5자 이상 입력 시 다음 단계 활성화',
                style: TextStyle(fontSize: 11, color: AppTheme.textDisabled),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
