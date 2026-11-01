import 'package:flutter/material.dart';

/// Central colour palette, sampled from the SkinGuard AI Figma design.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4D6B2A); // olive green (buttons, accents)
  static const Color primaryDark = Color(0xFF3B5420);
  static const Color primarySoft = Color(0xFFDFE8CC); // light sage chips / circles
  static const Color splashButton = Color(0xFF34B886);

  // Surfaces
  static const Color background = Color(0xFFF4F2E6); // warm cream
  static const Color surface = Color(0xFFFBFBF4); // cards, inputs
  static const Color surfaceMuted = Color(0xFFE4E2D3); // segmented track
  static const Color border = Color(0xFFDAD8C6);
  static const Color divider = Color(0xFFE6E3D3);

  // Text
  static const Color textPrimary = Color(0xFF282F1C);
  static const Color textSecondary = Color(0xFF75756A);
  static const Color textHint = Color(0xFF9A998C);

  // Accents
  static const Color blush = Color(0xFFFBE4D6); // "crucial question" / dermatologist card
  static const Color blushBorder = Color(0xFFEFC3A9);
  static const Color blushLight = Color(0xFFFFF6F0);
  static const Color clay = Color(0xFFB05A2A);
  static const Color brown = Color(0xFF8B4A22);
  static const Color skin = Color(0xFFF0D8C3);
  static const Color skinBorder = Color(0xFFC9A184);
  static const Color star = Color(0xFFE8A93A);

  // Status
  static const Color danger = Color(0xFF9B2C24);
  static const Color dangerSoft = Color(0xFFF6D6CF);
  static const Color success = Color(0xFF7BC86C);
  static const Color warning = Color(0xFFE0A030);

  // Camera
  static const Color cameraBackground = Color(0xFF11130C);
  static const Color cameraPreview = Color(0xFF5A4334);
}
