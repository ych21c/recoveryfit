import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';

class SessionCompleteArgs {
  final String exerciseName;
  final int totalSets;
  final int totalVolume;
  final int prevPainScore;

  const SessionCompleteArgs({
    required this.exerciseName,
    required this.totalSets,
    required this.totalVolume,
    required this.prevPainScore,
  });

  static SessionCompleteArgs fromMap(Map<String, dynamic> m) =>
      SessionCompleteArgs(
        exerciseName: m['exerciseName'] as String? ?? '',
        totalSets: m['totalSets'] as int? ?? 0,
        totalVolume: m['totalVolume'] as int? ?? 0,
        prevPainScore: m['prevPainScore'] as int? ?? 5,
      );
}

class SessionCompletePage extends ConsumerStatefulWidget {
  final SessionCompleteArgs args;
  const SessionCompletePage({super.key, required this.args});

  @override
  ConsumerState<SessionCompletePage> createState() =>
      _SessionCompletePageState();
}

class _SessionCompletePageState extends ConsumerState<SessionCompletePage> {
  bool _showFeedback = false;
  int _selectedPain = 5;

  @override
  void initState() {
    super.initState();
    _selectedPain = widget.args.prevPainScore;
  }

  void _openFeedback() => setState(() => _showFeedback = true);

  Future<void> _saveFeedback() async {
    await ref.read(checklistProvider.notifier).updateOverallPain(_selectedPain);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Summary screen
          SafeArea(
            child: Opacity(
              opacity: _showFeedback ? 0.4 : 1.0,
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  const SizedBox(height: 20),

                  // Complete icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: const Center(
                        child: Text('🎉', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      '운동 완료!',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      '오늘의 재활 루틴을 모두 마쳤어요 🎊',
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _SummaryCard(
                          value: '${widget.args.totalSets}세트',
                          label: '완료 세트 수'),
                      _SummaryCard(
                          value: '${widget.args.totalVolume} kg',
                          label: '총 볼륨'),
                      _SummaryCard(
                          value: '🔥 계속',
                          label: '도전 중'),
                      _SummaryCard(
                          value: widget.args.exerciseName.isNotEmpty
                              ? widget.args.exerciseName
                              : '운동',
                          label: '완료 운동'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openFeedback,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error),
                      child: const Text('세션 종료 및 피드백'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pain feedback modal
          if (_showFeedback)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showFeedback = false),
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          if (_showFeedback)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _PainFeedbackSheet(
                prevScore: widget.args.prevPainScore,
                selectedScore: _selectedPain,
                onScoreChanged: (v) => setState(() => _selectedPain = v),
                onSave: _saveFeedback,
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ]),
      );
}

// ── Pain Feedback Sheet ───────────────────────────────────────────────────────

class _PainFeedbackSheet extends StatelessWidget {
  final int prevScore;
  final int selectedScore;
  final ValueChanged<int> onScoreChanged;
  final VoidCallback onSave;

  const _PainFeedbackSheet({
    required this.prevScore,
    required this.selectedScore,
    required this.onScoreChanged,
    required this.onSave,
  });

  Color _chipColor(int n) {
    if (n <= 3) return AppTheme.success;
    if (n <= 6) return AppTheme.warning;
    return AppTheme.error;
  }

  Color _chipBg(int n) {
    if (n <= 3) return const Color(0xFFE8F5E9);
    if (n <= 6) return const Color(0xFFFFF8E1);
    return const Color(0xFFFFEBEE);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 32, offset: Offset(0, -8))],
      ),
      padding: EdgeInsets.fromLTRB(
          22, 24, 22, MediaQuery.of(context).padding.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
                color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('🤔', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          const Text('오늘 통증은 어떠셨나요?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('운동 후 통증 변화를 알려주세요',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),

          // Pre-fill note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '📌 지난 세션 통증: $prevScore점 (기본 선택됨)',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 14),

          // Pain chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(10, (i) {
              final n = i + 1;
              final isSel = n == selectedScore;
              return GestureDetector(
                onTap: () => onScoreChanged(n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _chipBg(n),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? AppTheme.primary : _chipColor(n).withValues(alpha: 0.4),
                      width: isSel ? 2.5 : 1.5,
                    ),
                    boxShadow: isSel
                        ? [BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1)]
                        : null,
                  ),
                  child: Center(
                    child: Text('$n',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _chipColor(n))),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 = 통증 없음',
                  style: TextStyle(fontSize: 11, color: AppTheme.success)),
              Text('10 = 극심한 통증',
                  style: TextStyle(fontSize: 11, color: AppTheme.error)),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              child: const Text('저장 및 종료 (원터치)'),
            ),
          ),
        ],
      ),
    );
  }
}
