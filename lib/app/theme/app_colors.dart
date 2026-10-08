import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const seed = Color(0xFF5B6AF0);
  static const brandBlue = Color(0xFF5B6AF0); // primary (indigo)
  static const brandBlueDark = Color(0xFF4A58D4); // primary dark variant
  static const brandNavy = Color(0xFF0F1117);
  static const onboardingViolet = Color(0xFF5B6AF0);

  // Backgrounds and surfaces
  static const canvasLight = Color(0xFFF7F8FC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  static const midnight = Color(0xFF0F1117);
  static const surfaceDark = Color(0xFF1A1D27);
  static const midnight2 = surfaceDark;
  static const cardDark = Color(0xFF1E2130);

  // Text
  static const textPrimaryLight = Color(0xFF0F1117);
  static const textPrimaryDark = Color(0xFFF0F2FF);
  // The design's secondary grey (#8A8FA8) is only 3.2:1 on white, so light
  // mode uses a darker shade of the same hue (5.0:1). Dark mode uses it as is.
  static const textSecondaryLight = Color(0xFF666B87);
  static const textSecondaryDark = Color(0xFF8A8FA8);

  // Filled text fields
  static const fieldFillLight = Color(0xFFF0F2FF);
  static const fieldFillDark = Color(0xFF252838);

  // Subtle borders
  static const borderLight = Color(0xFFE4E6F0);
  static const borderDark = Color(0x1AFFFFFF);

  // Semantic colors. Used for task status chips, priority badges and alerts.
  static const success = Color(0xFF22C55E); // completed
  static const info = Color(
    0xFF5B6AF0,
  ); // assigned / in progress accent (indigo)
  static const warning = Color(0xFFF59E0B); // in progress / medium priority
  static const danger = Color(0xFFEF4444); // overdue / urgent / high priority
  static const neutral = Color(0xFF8A8FA8); // cancelled

  // Low-opacity fills for chip/badge backgrounds — same hues as above,
  // just softened so text/icon on top stays the readable, saturated color.
  static const successBg = Color(0x2622C55E);
  static const infoBg = Color(0x265B6AF0);
  static const warningBg = Color(0x26F59E0B);
  static const dangerBg = Color(0x26EF4444);
  static const neutralBg = Color(0x268A8FA8);

  /// The semantic colors above are mid-tones. As text or small icons they
  /// are too pale on light surfaces (e.g. [success] on white is under 2:1)
  /// and slightly too dim on their own tints in dark mode. This returns a
  /// darker (light mode) or lighter (dark mode) shade of the same hue that
  /// reaches at least 5.4:1 on the chip tints and on the app surfaces
  /// (WCAG AA for small text is 4.5:1).
  static Color readable(Color color, Brightness brightness) {
    final hsl = HSLColor.fromColor(color);
    final lightness = brightness == Brightness.dark
        ? hsl.lightness + (1 - hsl.lightness) * 0.3
        : hsl.lightness * 0.45;
    return hsl.withLightness(lightness).toColor();
  }
}

/// Shorthand for [AppColors.readable] with the current theme's brightness.
extension ReadableSemanticColor on BuildContext {
  Color readable(Color color) =>
      AppColors.readable(color, Theme.of(this).brightness);
}
