import 'package:flutter/material.dart';

abstract class AppMotion {
  static const Duration durationFast    = Duration(milliseconds: 100);
  static const Duration durationNormal  = Duration(milliseconds: 200);
  static const Duration durationSlow    = Duration(milliseconds: 400);
  static const Duration durationFadeIn  = Duration(milliseconds: 600);
  static const Duration durationHold    = Duration(milliseconds: 1200);
  static const Duration durationFadeOut = Duration(milliseconds: 400);

  static const Curve easingDefault = Curves.easeInOut;
}
