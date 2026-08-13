import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

// ── Design tokens (landing-specific) ─────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kMint = Color(0xFF00C9A7);
const _kMintDark = Color(0xFF009E84);
const _kWhite = Colors.white;
const _kSubText = Color(0xCCFFFFFF); // rgba(255,255,255,0.8)
const _kCaption = Color(0x73FFFFFF); // rgba(255,255,255,0.45)

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: const [
            Icon(Icons.directions_run_rounded, color: _kMint, size: 18),
            SizedBox(width: 8),
            Text(
              'RecoveryFit',
              style: TextStyle(
                color: _kWhite,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ── Hero section (top ~55%) ────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.58,
            child: const _HeroSection(),
          ),

          // ── Gradient overlay: transparent → navy ──────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [Colors.transparent, _kNavy],
                ),
              ),
            ),
          ),

          // ── Content (headline + value points + CTA) ───────────────────────
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Push content below the hero
                  const Spacer(),

                  // Headline group
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '부상 후에도',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _kWhite,
                                height: 1.35,
                              ),
                            ),
                            Text(
                              '운동할 수 있어요',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _kWhite,
                                height: 1.35,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.15, end: 0),
                        const SizedBox(height: 12),
                        Text(
                          'AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: _kSubText,
                            height: 1.5,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 500.ms)
                            .slideY(begin: 0.15, end: 0),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Value points row
                  const _ValuePointsRow()
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 36),

                  // CTA button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _CtaButton(
                      onPressed: () => context.go(AppRoutes.disclaimer),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 450.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  // Disclaimer caption – split so find.text('의료기기') resolves
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '의료기기',
                        style: TextStyle(
                          fontSize: 11,
                          color: _kCaption,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        ' 아님 · 전문의 상담을 대체하지 않습니다',
                        style: TextStyle(
                          fontSize: 11,
                          color: _kCaption,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 400.ms),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero illustration ─────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kNavy,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative rings
          CustomPaint(
            size: Size.infinite,
            painter: _RingsPainter(),
          ),

          // Central illustration
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Outer glow circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kMint.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kMint.withValues(alpha: 0.14),
                    ),
                    child: Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_kMint, _kMintDark],
                          ),
                        ),
                        child: const Icon(
                          Icons.directions_run_rounded,
                          color: _kNavy,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 700.ms)
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 700.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 28),

              // Stat pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatPill(icon: Icons.shield_outlined, label: '이중 안전 검증')
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(width: 12),
                  _StatPill(icon: Icons.psychology_outlined, label: 'AI 개인화')
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 500.ms),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final r in [90.0, 140.0, 195.0, 255.0]) {
      paint.color = _kMint.withValues(alpha: math.max(0, 0.18 - r * 0.0005));
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Accent arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = _kMint.withValues(alpha: 0.35)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 195),
      -math.pi * 0.7,
      math.pi * 0.5,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _kMint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _kMint.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _kMint, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _kMint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Value points (3-column row) ───────────────────────────────────────────────

class _ValuePointsRow extends StatelessWidget {
  const _ValuePointsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _ValuePoint(
            icon: Icons.verified_user_outlined,
            label: '이중 안전\n검증',
            delay: 500.ms,
          ),
          _ValuePoint(
            icon: Icons.psychology_outlined,
            label: 'AI 개인화\n플랜',
            delay: 600.ms,
          ),
          _ValuePoint(
            icon: Icons.touch_app_outlined,
            label: '터치 최소화\n인터페이스',
            delay: 700.ms,
          ),
        ],
      ),
    );
  }
}

class _ValuePoint extends StatelessWidget {
  final IconData icon;
  final String label;
  final Duration delay;

  const _ValuePoint({
    required this.icon,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kMint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _kMint.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: _kMint, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xB3FFFFFF), // rgba(255,255,255,0.7)
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(delay: delay, duration: 400.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }
}

// ── CTA Button ────────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CtaButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kMint,
          foregroundColor: _kNavy,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('시작하기'),
      ),
    );
  }
}
