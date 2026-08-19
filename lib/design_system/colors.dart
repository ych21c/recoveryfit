import 'package:flutter/material.dart';

/// RecoveryFit Design Token — Color System (REQ-00-C)
abstract class AppColors {
  // Primary palette — start pages (deep navy + mint)
  static const Color primaryDark      = Color(0xFF0D1B2A);
  static const Color primaryMint      = Color(0xFF00C9A7);
  static const Color primaryMintLight = Color(0xFF33D4B8);

  // Text on dark backgrounds
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70 %
  static const Color textTertiary  = Color(0x73FFFFFF); // 45 %

  // Surface
  static const Color surfaceOverlay = Color(0x990D1B2A); // 60 %

  // Hero illustration tints
  static const Color heroLayer1 = Color(0xFF1A3A4A);
  static const Color heroLayer2 = Color(0xFF0F2535);

  // --- v1.2.0 alias tokens (keeps existing screens compiling) ---
  static const Color kPrimaryBlue  = Color(0xFF4F8EF7);
  static const Color kDarkText     = Color(0xFF1E3A5F);
  static const Color kSubtitleText = Color(0xFF64748B);
  static const Color kBgStart      = Color(0xFFEFF6FF);
  static const Color kBgEnd        = Color(0xFFF8FAFC);
}
