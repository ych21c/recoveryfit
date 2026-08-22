import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// Mint-background CTA button. Height 56 px, border-radius 14 px, full width.
class CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CtaButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryMint,
        foregroundColor: AppColors.primaryDark,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 8,
        shadowColor: AppColors.primaryMint.withValues(alpha: 0.35),
      ),
      child: Text(label, style: AppTypography.button),
    );
  }
}
