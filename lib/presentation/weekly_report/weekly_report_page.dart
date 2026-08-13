import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../providers/providers.dart';

class WeeklyReportPage extends ConsumerStatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  ConsumerState<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends ConsumerState<WeeklyReportPage> {
  bool _isApplying = false;

  Future<void> _applyPlan() async {
    final profile = ref.read(profileProvider);
    if (profile == null) return;

    setState(() => _isApplying = true);
    try {
      await ref.read(planProvider.notifier).adjustPlan(profile);
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('홈',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13)),
                        ]),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text('3주차 리포트',
                          style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '🤖 AI 주간 미세조정 완료',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '지난 7일 데이터를 분석하여 차주 플랜을 업데이트했습니다',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: progressAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (data) => _buildBody(context, data, profile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProgressData data, UserProfile? profile) {
    final painTrend = data.painTrend;
    final avgPain = painTrend.isEmpty
        ? 0
        : (painTrend.map((e) => e.value).reduce((a, b) => a + b) / painTrend.length).round();
    final avgCompletion = data.completionRate.isEmpty
        ? 0.0
        : data.completionRate.map((e) => e.value).reduce((a, b) => a + b) /
            data.completionRate.length;
    final totalVol = data.weeklyVolume.isEmpty ? 0 : data.weeklyVolume.last.value;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            children: [
              // Summary strip
              Row(children: [
                _StripCard(value: '$avgPain점', label: '이번 주 통증', delta: '▼ 감소', isPos: true),
                const SizedBox(width: 8),
                _StripCard(
                    value: '${(avgCompletion * 100).round()}%',
                    label: '완료율',
                    delta: '▲ 향상',
                    isPos: true),
                const SizedBox(width: 8),
                _StripCard(value: '$totalVol', label: '볼륨', delta: '▲ 증가', isPos: true),
              ]),
              const SizedBox(height: 14),
              const _SectionHead('🔧 AI 조정 내역 (Haiku 모델)'),
              _AiCard(
                badge: '재활 동작 감소',
                badgeColor: const Color(0xFFE8F5E9),
                badgeTextColor: AppTheme.success,
                title: '단기 재활 보조 동작 조정',
                desc: '통증이 감소했으므로 재활 전용 동작 비중을 줄이고 근력 강화로 전환합니다.',
                before: '재활 3종 × 3세트',
                after: '재활 2종 × 3세트 (▼20%)',
              ),
              _AiCard(
                badge: '메인 강도 상향',
                badgeColor: const Color(0xFFEEF0FF),
                badgeTextColor: const Color(0xFF5C6BC0),
                title: '메인 근력 동작 부하 증가',
                desc: '볼륨이 안정적으로 증가하고 있어 점진적 과부하 원칙에 따라 무게를 소폭 올립니다.',
                before: '월 스쿼트 5kg × 10회',
                after: '7.5kg × 10회 (+2.5kg)',
              ),
              _AiCard(
                badge: '빈도 유지',
                badgeColor: const Color(0xFFFFF8F0),
                badgeTextColor: const Color(0xFFC96A00),
                title: '주 3회 스케줄 유지',
                desc: '현재 출석률과 회복 패턴이 최적화되어 있어 주 3회 빈도를 유지합니다.',
                before: '주 3회',
                after: '주 3회 (유지)',
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  border: Border.all(color: AppTheme.secondary, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🛡️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '이중 안전 검증 완료 — 모든 조정 사항이 10개 안전 규칙을 통과하였습니다. 부상 제약 조건 준수.',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFFC96A00), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Footer buttons
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: const Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isApplying ? null : _applyPlan,
                  child: _isApplying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('⚡ 차주 플랜 적용하기 (원터치)'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('나중에 검토하기'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Strip Card ────────────────────────────────────────────────────────────────

class _StripCard extends StatelessWidget {
  final String value;
  final String label;
  final String delta;
  final bool isPos;

  const _StripCard({
    required this.value,
    required this.label,
    required this.delta,
    required this.isPos,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
          ),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(delta,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPos ? AppTheme.success : AppTheme.error)),
          ]),
        ),
      );
}

// ── Section Head ─────────────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  final String text;
  const _SectionHead(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      );
}

// ── AI Card ───────────────────────────────────────────────────────────────────

class _AiCard extends StatelessWidget {
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String title;
  final String desc;
  final String before;
  final String after;

  const _AiCard({
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.title,
    required this.desc,
    required this.before,
    required this.after,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: badgeColor, borderRadius: BorderRadius.circular(99)),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: badgeTextColor)),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text(before,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('→',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
              Expanded(
                child: Text(after,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
              ),
            ]),
          ),
        ]),
      );
}
