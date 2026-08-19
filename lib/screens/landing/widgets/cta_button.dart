import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/motion.dart';
import '../../../design_system/typography.dart';

/// Mint-background CTA button with scale + brightness press feedback.
/// Height 56 px, border-radius 14 px, full width.
class CtaButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const CtaButton({super.key, required this.label, required this.onTap});

  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: AppMotion.durationFast,
          curve: AppMotion.easingDefault,
          child: AnimatedContainer(
            duration: AppMotion.durationFast,
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              // Darken slightly on press (simulates brightness −10 %)
              color: _pressed
                  ? const Color(0xFF00B596)
                  : AppColors.primaryMint,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMint.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(widget.label, style: AppTypography.button),
          ),
        ),
      ),
    );
  }
}
