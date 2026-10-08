import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App type scale, all in Nunito.
///
/// Built with google_fonts (same as the theme's textTheme): google_fonts
/// registers Nunito under its own family names, so a plain
/// `fontFamily: 'Nunito'` would silently fall back to the platform font.
/// Styles carry no color; callers add one from the color scheme.
class AppTextStyles {
  static TextStyle _nunito(double size, FontWeight weight, double height) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: weight, height: height);

  // Display
  static final TextStyle displayLarge = _nunito(32, FontWeight.w800, 1.2);
  static final TextStyle displayMedium = _nunito(28, FontWeight.w800, 1.2);
  static final TextStyle displaySmall = _nunito(24, FontWeight.w800, 1.3);

  // Heading
  static final TextStyle headingLarge = _nunito(20, FontWeight.w700, 1.4);
  static final TextStyle headingMedium = _nunito(18, FontWeight.w700, 1.4);
  static final TextStyle headingSmall = _nunito(16, FontWeight.w600, 1.4);

  // Body
  static final TextStyle bodyLarge = _nunito(16, FontWeight.normal, 1.5);
  static final TextStyle bodyMedium = _nunito(14, FontWeight.normal, 1.5);
  static final TextStyle bodySmall = _nunito(12, FontWeight.normal, 1.5);

  // Label
  static final TextStyle labelLarge = _nunito(14, FontWeight.w500, 1.4);
  static final TextStyle labelMedium = _nunito(12, FontWeight.w500, 1.4);
  static final TextStyle labelSmall = _nunito(10, FontWeight.w500, 1.4);

  // Button
  static final TextStyle button = _nunito(15, FontWeight.w600, 1.2);
}
