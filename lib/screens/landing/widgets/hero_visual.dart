import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';

/// Hero illustration zone (top 55 % of landing screen).
/// Reproduces the inline-SVG scene from the ATM-5 HTML mock:
///   gradient background → rehab figure + stat panels → bottom fade overlay.
class HeroVisual extends StatelessWidget {
  const HeroVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeroPainter(),
      size: Size.infinite,
    );
  }
}

class _HeroPainter extends CustomPainter {
  // Reference frame used in the HTML SVG (matches 375 px wide design)
  static const double _refW = 375;
  static const double _refH = 225;

  @override
  void paint(Canvas canvas, Size size) {
    // ── 1. Gradient background ───────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment(-0.342, 0.940), // 160 ° from top
        end: Alignment(0.342, -0.940),
        colors: [
          AppColors.heroLayer1, // #1A3A4A
          AppColors.heroLayer2, // #0F2535
          AppColors.primaryDark, // #0D1B2A
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── 2. Scale to reference frame (contain, centered) ─────────────────────
    // HTML mock's <svg width="375" height="260"> isn't stretched by its flex
    // parent — it renders at its own aspect ratio and gets centered, with the
    // container's gradient showing around it. math.max() (cover) was wrong
    // here: on a real phone the hero zone is much taller-than-wide relative to
    // the 375×225 reference, so cover-fit blew the scale up ~2× past what's
    // needed to fill the width alone, pushing the side icon boxes (heart-rate
    // at x 42-94, AI at x 282-334) entirely off-screen — reproduced from a
    // QA Test Lab screenshot where only the centered graph panel was visible.
    final scaleX = size.width / _refW;
    final scaleY = size.height / _refH;
    final scale = math.min(scaleX, scaleY);
    final offX = (size.width - _refW * scale) / 2;
    final offY = (size.height - _refH * scale) / 2;

    canvas.save();
    canvas.translate(offX, offY);
    canvas.scale(scale);

    _drawIllustration(canvas);

    canvas.restore();

    // ── 3. Gradient overlay (bottom 70 %) — drawn in actual canvas coords ───
    final overlayTop = size.height * 0.30;
    final overlayRect =
        Rect.fromLTWH(0, overlayTop, size.width, size.height - overlayTop);

    final overlayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.primaryDark.withValues(alpha: 0.6),
          AppColors.primaryDark,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(overlayRect);
    canvas.drawRect(overlayRect, overlayPaint);
  }

  /// All coordinates are in the 375 × 225 reference space.
  void _drawIllustration(Canvas canvas) {
    // ── Ambient teal glow ellipses ─────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(187, 130), width: 240, height: 180),
      Paint()..color = AppColors.primaryMint.withValues(alpha: 0.06),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(187, 130), width: 160, height: 120),
      Paint()..color = AppColors.primaryMint.withValues(alpha: 0.08),
    );

    // ── Rehab mat ──────────────────────────────────────────────────────────
    final matPaint = Paint()
      ..color = AppColors.primaryMint.withValues(alpha: 0.20);
    final matRRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 190, 255, 12), const Radius.circular(6));
    canvas.drawRRect(matRRect, matPaint);

    // ── Torso ──────────────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(100, 165, 130, 28), const Radius.circular(14)),
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );

    // ── Head ───────────────────────────────────────────────────────────────
    canvas.drawCircle(
      const Offset(108, 165),
      20,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // Eyes (mint dots)
    final eyePaint = Paint()
      ..color = AppColors.primaryMint.withValues(alpha: 0.8);
    canvas.drawCircle(const Offset(103, 163), 2.5, eyePaint);
    canvas.drawCircle(const Offset(113, 163), 2.5, eyePaint);

    // ── Raised leg (rotated −25 °) ─────────────────────────────────────────
    canvas.save();
    canvas.translate(220, 140);
    canvas.rotate(-25 * math.pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 90, 22), const Radius.circular(11)),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    canvas.restore();

    // ── Foot ellipse (rotated −25 °) ──────────────────────────────────────
    canvas.save();
    canvas.translate(300, 120);
    canvas.rotate(-25 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 36, height: 20),
      Paint()..color = AppColors.primaryMint.withValues(alpha: 0.30),
    );
    canvas.restore();

    // ── Heart-rate icon box (top-left) ────────────────────────────────────
    _drawIconBox(canvas, const Rect.fromLTWH(42, 30, 52, 52), 14);
    final ecgPaint = Paint()
      ..color = AppColors.primaryMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final ecg = Path()
      ..moveTo(56, 57)
      ..relativeLineTo(4, -8)
      ..relativeLineTo(4, 14)
      ..relativeLineTo(4, -10)
      ..relativeLineTo(3, 4)
      ..relativeLineTo(8, 0);
    canvas.drawPath(ecg, ecgPaint);

    // ── AI icon box (top-right) ───────────────────────────────────────────
    _drawIconBox(canvas, const Rect.fromLTWH(282, 30, 52, 52), 14);
    final aiCirclePaint = Paint()
      ..color = AppColors.primaryMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(308, 52), 10, aiCirclePaint);
    canvas.drawCircle(
      const Offset(308, 52),
      4,
      Paint()..color = AppColors.primaryMint.withValues(alpha: 0.60),
    );
    // Spokes
    final spokePaint = Paint()
      ..color = AppColors.primaryMint
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    _drawLine(canvas, spokePaint,
        const Offset(308, 38), const Offset(308, 42));
    _drawLine(canvas, spokePaint,
        const Offset(308, 62), const Offset(308, 66));
    _drawLine(canvas, spokePaint,
        const Offset(294, 52), const Offset(298, 52));
    _drawLine(canvas, spokePaint,
        const Offset(318, 52), const Offset(322, 52));

    // ── Pain-trend graph panel (centre-top) ───────────────────────────────
    final panelRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(120, 20, 135, 55),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      panelRect,
      Paint()..color = AppColors.primaryDark.withValues(alpha: 0.60),
    );
    canvas.drawRRect(
      panelRect,
      Paint()
        ..color = AppColors.primaryMint.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Graph line (pain trending downward = improving)
    const chartPts = [
      Offset(135, 65),
      Offset(155, 58),
      Offset(175, 52),
      Offset(195, 54),
      Offset(215, 42),
      Offset(235, 30),
    ];
    final chartPath = Path()..moveTo(chartPts[0].dx, chartPts[0].dy);
    for (final p in chartPts.skip(1)) {
      chartPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      chartPath,
      Paint()
        ..color = AppColors.primaryMint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    // End-point dot
    canvas.drawCircle(
        chartPts.last, 3, Paint()..color = AppColors.primaryMint);

    // ── Decorative ambient dots ────────────────────────────────────────────
    canvas.drawCircle(const Offset(70, 100), 3,
        Paint()..color = AppColors.primaryMint.withValues(alpha: 0.40));
    canvas.drawCircle(const Offset(310, 110), 2,
        Paint()..color = AppColors.primaryMint.withValues(alpha: 0.30));
    canvas.drawCircle(const Offset(160, 15), 2,
        Paint()..color = Colors.white.withValues(alpha: 0.20));
    canvas.drawCircle(const Offset(240, 20), 1.5,
        Paint()..color = Colors.white.withValues(alpha: 0.15));
  }

  /// Draws a translucent mint-bordered rounded-rect icon box.
  void _drawIconBox(Canvas canvas, Rect rect, double radius) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rr,
      Paint()..color = AppColors.primaryMint.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = AppColors.primaryMint.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawLine(Canvas canvas, Paint paint, Offset a, Offset b) {
    canvas.drawLine(a, b, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
