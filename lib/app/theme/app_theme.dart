import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// Light and dark themes share one builder so every component theme is
/// defined once; only the palette differs. Screens should rely on these
/// component themes instead of styling AppBars, snackbars, dialogs or
/// sheets locally.
class AppTheme {
  static ThemeData get light => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.brandBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brandBlue,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE4E7FD),
      onPrimaryContainer: const Color(0xFF232A80),
      secondary: AppColors.brandBlue,
      tertiary: AppColors.brandBlueDark,
      error: AppColors.danger,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: const Color(0xFFC9CCDC),
      outlineVariant: AppColors.borderLight,
      surfaceContainerLowest: AppColors.surfaceLight,
      surfaceContainerLow: AppColors.canvasLight,
      surfaceContainer: AppColors.canvasLight,
      surfaceContainerHigh: AppColors.fieldFillLight,
      surfaceContainerHighest: AppColors.fieldFillLight,
      inverseSurface: AppColors.surfaceDark,
      onInverseSurface: AppColors.textPrimaryDark,
    ),
    canvas: AppColors.canvasLight,
    card: AppColors.cardLight,
    fieldFill: AppColors.fieldFillLight,
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.brandBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.brandBlue,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF2A2F66),
      onPrimaryContainer: const Color(0xFFDDE0FF),
      secondary: AppColors.brandBlue,
      tertiary: AppColors.brandBlueDark,
      error: AppColors.danger,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: const Color(0xFF4A4F66),
      outlineVariant: AppColors.borderDark,
      surfaceContainerLowest: AppColors.midnight,
      surfaceContainerLow: AppColors.surfaceDark,
      surfaceContainer: AppColors.cardDark,
      surfaceContainerHigh: AppColors.cardDark,
      surfaceContainerHighest: AppColors.fieldFillDark,
      inverseSurface: AppColors.textPrimaryDark,
      onInverseSurface: AppColors.midnight,
    ),
    canvas: AppColors.midnight,
    card: AppColors.cardDark,
    fieldFill: AppColors.fieldFillDark,
  );

  static ThemeData _build(
    ColorScheme scheme, {
    required Color canvas,
    required Color card,
    required Color fieldFill,
  }) {
    final isDark = scheme.brightness == Brightness.dark;
    final baseText = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    OutlineInputBorder outline(BorderSide side) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
      borderSide: side,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      visualDensity: VisualDensity.standard,
      // Nunito everywhere, in the scheme's on-surface colors.
      textTheme: GoogleFonts.nunitoTextTheme(baseText)
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        // Surface-colored bar with a hairline bottom border, never primary.
        backgroundColor: scheme.surface,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          fontSize: 17,
          color: scheme.onSurface,
        ),
      ),
      // Light: white card with a soft shadow. Dark: flat card, hairline border.
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 1.5,
        shadowColor: const Color(0x1A1A1D27),
        margin: EdgeInsets.zero,
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: isDark
              ? BorderSide(color: scheme.outlineVariant)
              : BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          shape: buttonShape,
          textStyle: AppTextStyles.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          shape: buttonShape,
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          shape: buttonShape,
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.tertiaryContainer,
        disabledColor: scheme.onSurface.withValues(alpha: 0.08),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space2,
          vertical: AppDimensions.space1,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.14),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: fieldFill,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space4,
          vertical: AppDimensions.space4,
        ),
        // Filled fields: no outline until focused.
        border: outline(BorderSide.none),
        enabledBorder: outline(BorderSide.none),
        focusedBorder: outline(BorderSide(color: scheme.primary, width: 1.5)),
        errorBorder: outline(BorderSide(color: scheme.error)),
        focusedErrorBorder: outline(
          BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.heroRadius),
        ),
        titleTextStyle: AppTextStyles.headingLarge.copyWith(
          color: scheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.cardRadius),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: scheme.onSurface,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.15),
      ),
    );
  }
}
