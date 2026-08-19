import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/services/storage_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/motion.dart';
import 'widgets/dot_loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    // Total: fadeIn 600 ms + hold 1 200 ms + fadeOut 400 ms = 2 200 ms (≥ min 2 s)
    _ctrl = AnimationController(
      duration: AppMotion.durationFadeIn +
          AppMotion.durationHold +
          AppMotion.durationFadeOut,
      vsync: this,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: AppMotion.durationFadeIn.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: AppMotion.durationHold.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: AppMotion.durationFadeOut.inMilliseconds.toDouble(),
      ),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => _navigate());
  }

  void _navigate() {
    if (!mounted) return;
    final storage = StorageService.instance;
    if (storage.onboardingDone) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.landing);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: AnimatedBuilder(
        animation: _opacity,
        builder: (_, child) => Opacity(opacity: _opacity.value, child: child),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Logo symbol ─────────────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00C9A7), Color(0xFF00957C)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x5900C9A7),
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(40, 40),
                    painter: _RecoveryLoopPainter(),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Wordmark ────────────────────────────────────────────────
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'Recovery'),
                    TextSpan(
                      text: 'Fit',
                      style: TextStyle(color: AppColors.primaryMint),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Tagline ─────────────────────────────────────────────────
              Text(
                '부상 후, 더 강하게',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 0.08 * 15,
                ),
              ),

              const SizedBox(height: 40),

              // ── Loading dots ────────────────────────────────────────────
              const DotLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recovery-loop icon painter ─────────────────────────────────────────────────
// Replicates the SVG in the HTML mock: large circular arc (270 °, clockwise)
// from top point to left point, with an L-shaped arrowhead at the end.
class _RecoveryLoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2; // 20
    final cy = size.height / 2; // 20
    final r = size.width * 0.25; // 10  (= 10 / 40 of viewBox)

    // 270 ° arc clockwise: start at top (−90 °) → sweep +270 °
    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 3 / 2, false, paint);

    // Arrowhead at the end-point (left of circle) replicating:
    // polyline points="10 16 10 20 14 20"
    // In proportion: 4 units above → 4 units right (4/10 of radius)
    final ex = cx - r; // left point x
    final ey = cy;     // left point y
    final arm = r * 0.4;

    final arrow = Path()
      ..moveTo(ex, ey - arm)
      ..lineTo(ex, ey)
      ..lineTo(ex + arm, ey);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
