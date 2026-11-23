import 'package:flutter/material.dart';

/// Central colour palette, sampled from the SkinGuard AI Figma design.
///
/// Theme-dependent colours are getters that follow the active appearance
/// (see [setDark]). Brand and illustration colours stay constant.
class AppColors {
  AppColors._();

  static bool _isDark = false;

  static bool get isDark => _isDark;

  /// Called by the app root whenever the appearance setting changes.
  static void setDark(bool value) => _isDark = value;

  static Color _pick(int light, int dark) => Color(_isDark ? dark : light);

  // Brand
  static Color get primary => _pick(0xFF4D6B2A, 0xFF648440); // olive green
  static const Color primaryDark = Color(0xFF3B5420);
  static Color get primarySoft =>
      _pick(0xFFDFE8CC, 0xFF2A3320); // light sage chips / circles
  static const Color splashButton = Color(0xFF34B886);

  // Surfaces
  static Color get background => _pick(0xFFF4F2E6, 0xFF171A12); // warm cream
  static Color get surface => _pick(0xFFFBFBF4, 0xFF22261A); // cards, inputs
  static Color get surfaceMuted =>
      _pick(0xFFE4E2D3, 0xFF2F3324); // segmented track
  static Color get surfaceRaised =>
      _pick(0xFFFFFFFF, 0xFF2B3021); // selected cards
  static Color get border => _pick(0xFFDAD8C6, 0xFF3D4230);
  static Color get divider => _pick(0xFFE6E3D3, 0xFF33372A);

  // Text
  static Color get textPrimary => _pick(0xFF282F1C, 0xFFEDEEE0);
  static Color get textSecondary => _pick(0xFF75756A, 0xFFB0B1A2);
  static Color get textHint => _pick(0xFF9A998C, 0xFF85867A);

  /// Text drawn on skin-coloured illustrations, in either appearance.
  static const Color textOnSkin = Color(0xFF282F1C);

  // Accents
  static Color get blush =>
      _pick(0xFFFBE4D6, 0xFF3A2A22); // "crucial question" / dermatologist card
  static Color get blushBorder => _pick(0xFFEFC3A9, 0xFF5C4234);
  static Color get blushLight => _pick(0xFFFFF6F0, 0xFF2C211B);
  static Color get clay => _pick(0xFFB05A2A, 0xFFE0A07A);
  static const Color brown = Color(0xFF8B4A22);
  static const Color skin = Color(0xFFF0D8C3);
  static const Color skinBorder = Color(0xFFC9A184);
  static const Color star = Color(0xFFE8A93A);

  // Status
  static Color get danger => _pick(0xFF9B2C24, 0xFFF0A59A);
  static Color get dangerSoft => _pick(0xFFF6D6CF, 0xFF4A2421);
  static const Color success = Color(0xFF7BC86C);
  static const Color warning = Color(0xFFE0A030);

  // Camera
  static const Color cameraBackground = Color(0xFF11130C);
  static const Color cameraPreview = Color(0xFF5A4334);
}
