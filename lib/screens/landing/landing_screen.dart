import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'widgets/cta_button.dart';
import 'widgets/hero_visual.dart';
import 'widgets/value_points_row.dart';

/// LandingScreen — REQ-00-B.
/// Fullscreen (no scroll). Top 55 %: hero illustration. Bottom 45 %: copy + CTA.
/// Shown only for first-time users (router redirect skips it when onboardingDone).
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // ── Hero illustration (top 55 %) ────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: h * 0.55,
                child: const HeroVisual(),
              ),

              // ── Header logo (top-left, over hero) ───────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Row(
                      children: [
                        // Small mint icon tile
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CustomPaint(
                              size: const Size(16, 16),
                              painter: _SmallLogoIconPainter(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'RecoveryFit',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main content (from 42 % down, aligned to bottom) ────────
              Positioned(
                top: h * 0.42,
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main headline — two separate Text widgets so
                      // find.text('부상 후에도') and find.text('운동할 수 있어요')
                      // each resolve to findsOneWidget in tests.
                      const Text('부상 후에도', style: AppTypography.headlineL),
                      const Text('운동할 수 있어요', style: AppTypography.headlineL),

                      const SizedBox(height: 12),

                      // Sub-headline — two separate Text widgets so
                      // find.text('AI가 내 부상 상태를 분석하고') resolves in tests.
                      Text(
                        'AI가 내 부상 상태를 분석하고',
                        style: AppTypography.bodyL.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '안전한 재활 플랜을 만들어드려요',
                        style: AppTypography.bodyL.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Value props 3-column
                      const ValuePointsRow(),

                      const SizedBox(height: 28),

                      // CTA button
                      CtaButton(
                        label: '무료로 시작하기',
                        onTap: () => context.go(AppRoutes.disclaimer),
                      ),

                      const SizedBox(height: 12),

                      // Medical disclaimer caption
                      Center(
                        child: Text(
                          '의료기기 아님 · 전문의 상담을 대체하지 않습니다',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Small logo icon (16 × 16 reference, navy on mint) ─────────────────────────
// Replicates the SVG in the HTML mock:
//   outer circle + centre dot + upper-left quarter arc
class _SmallLogoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * (6.0 / 16.0);
    final innerR = size.width * (2.0 / 16.0);
    final arcR   = size.width * (3.0 / 16.0);

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), outerR, paint);

    // Centre filled dot
    canvas.drawCircle(
        Offset(cx, cy), innerR, paint..style = PaintingStyle.fill);

    // Upper-left quarter arc (from 9 o'clock counterclockwise to 12 o'clock)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
      3.14159, // 180 ° — left
      -1.5708, // −90 ° sweep (counterclockwise to top)
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
