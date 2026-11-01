import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography from the design: a soft serif (Fraunces) for headings and
/// DM Sans for body text.
///
/// Fonts are downloaded by `google_fonts` on first launch and cached; when
/// offline the platform default font is used. Tests set [useGoogleFonts] to
/// false so no network request is attempted.
class AppTextStyles {
  AppTextStyles._();

  static bool useGoogleFonts = true;

  static TextStyle _serif(double size, FontWeight weight, {double? height}) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: AppColors.textPrimary,
      height: height,
      letterSpacing: -0.3,
    );
    return useGoogleFonts ? GoogleFonts.fraunces(textStyle: base) : base;
  }

  static TextStyle _sans(double size, FontWeight weight,
      {Color color = AppColors.textPrimary, double? height}) {
    final base =
        TextStyle(fontSize: size, fontWeight: weight, color: color, height: height);
    return useGoogleFonts ? GoogleFonts.dmSans(textStyle: base) : base;
  }

  // Headings (serif)
  static TextStyle get display => _serif(34, FontWeight.w700, height: 1.1);
  static TextStyle get h1 => _serif(30, FontWeight.w700, height: 1.15);
  static TextStyle get h2 => _serif(22, FontWeight.w700, height: 1.2);
  static TextStyle get h3 => _serif(18, FontWeight.w700, height: 1.25);

  // Body (sans)
  static TextStyle get title => _sans(17, FontWeight.w600);
  static TextStyle get label => _sans(14, FontWeight.w600);
  static TextStyle get body => _sans(15, FontWeight.w400, height: 1.45);
  static TextStyle get bodySecondary =>
      _sans(15, FontWeight.w400, color: AppColors.textSecondary, height: 1.45);
  static TextStyle get small =>
      _sans(12.5, FontWeight.w400, color: AppColors.textSecondary, height: 1.4);
  static TextStyle get overline => _sans(12, FontWeight.w700,
          color: AppColors.textSecondary)
      .copyWith(letterSpacing: 0.8);
  static TextStyle get button => _sans(16, FontWeight.w700);

  static TextTheme textTheme() {
    final base = TextTheme(
      displaySmall: display,
      headlineMedium: h1,
      headlineSmall: h2,
      titleLarge: h3,
      titleMedium: title,
      titleSmall: label,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: small,
      labelLarge: button,
    );
    return base;
  }
}
