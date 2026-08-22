import 'package:flutter/material.dart';

import 'colors.dart';

abstract class AppTypography {
  static const TextStyle headlineL = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineM = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyL = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyS = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Bold 17 sp, letter-spacing 0.01 em, navy colour (for mint CTA button)
  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.17, // 0.01 em
    color: AppColors.primaryDark,
  );
}
