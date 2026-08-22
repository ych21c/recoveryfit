import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';

/// Three mint dots that bounce sequentially (stagger 200 ms each).
/// Animation per dot: 1.2 s cycle — scale/opacity 0.3×0.8 → 1.0×1.2 → 0.3×0.8.
class DotLoadingIndicator extends StatelessWidget {
  const DotLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedDot(delayMs: 0),
        const SizedBox(width: 8),
        _AnimatedDot(delayMs: 200),
        const SizedBox(width: 8),
        _AnimatedDot(delayMs: 400),
      ],
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int delayMs;

  const _AnimatedDot({required this.delayMs});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 0–40 %: grow / brighten → 40–80 %: shrink / dim → 80–100 %: hold dim
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: ConstantTween(0.8), weight: 20),
    ]).animate(_ctrl);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: ConstantTween(0.3), weight: 20),
    ]).animate(_ctrl);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: child,
        ),
      ),
      child: const Icon(
        Icons.circle,
        color: AppColors.primaryMint,
        size: 8,
      ),
    );
  }
}
