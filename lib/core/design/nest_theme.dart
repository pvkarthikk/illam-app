import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';

/// Typography & Material 3 theme definitions for Nest Mojo - Flat.
abstract final class NestTheme {
  static const String bodyFontFamily = 'Hanken Grotesk';
  static const List<String> bodyFontFallback = <String>[
    'Segoe UI',
    'sans-serif',
  ];

  static const String displayFontFamily = 'Young Serif';
  static const List<String> displayFontFallback = <String>[
    'Iowan Old Style',
    'Georgia',
    'serif',
  ];

  static ThemeData light() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: NestPalette.lightPrimary,
      onPrimary: NestPalette.lightCard,
      primaryContainer: NestPalette.lightPrimaryContainer,
      onPrimaryContainer: NestPalette.brandCanvas,
      secondary: NestPalette.lightAccent,
      onSecondary: NestPalette.lightText,
      secondaryContainer: NestPalette.lightAccentContainer,
      onSecondaryContainer: NestPalette.lightText,
      tertiary: NestPalette.brandBadgeGreen,
      onTertiary: NestPalette.lightCard,
      tertiaryContainer: NestPalette.lightPrimaryContainer,
      onTertiaryContainer: NestPalette.lightText,
      error: NestPalette.lightDanger,
      onError: NestPalette.lightCard,
      errorContainer: NestPalette.lightDangerContainer,
      onErrorContainer: NestPalette.lightText,
      surface: NestPalette.lightBackground,
      onSurface: NestPalette.lightText,
      surfaceContainerLowest: NestPalette.lightCard,
      surfaceContainerLow: NestPalette.lightCard,
      surfaceContainer: NestPalette.lightCardSubtle,
      surfaceContainerHigh: NestPalette.lightCardHigh,
      surfaceContainerHighest: NestPalette.lightBorder,
      onSurfaceVariant: NestPalette.lightTextMuted,
      outline: NestPalette.lightBorder,
      outlineVariant: NestPalette.lightCardHigh,
      shadow: NestPalette.brandCanvas,
      scrim: NestPalette.brandCanvas,
      inverseSurface: NestPalette.brandCanvas,
      onInverseSurface: NestPalette.darkText,
      inversePrimary: NestPalette.darkPrimary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      nestColors: NestColors.light,
    );
  }

  static ThemeData dark() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: NestPalette.darkPrimary,
      onPrimary: NestPalette.darkBackground,
      primaryContainer: NestPalette.darkPrimaryContainer,
      onPrimaryContainer: NestPalette.darkText,
      secondary: NestPalette.darkAccent,
      onSecondary: NestPalette.darkBackground,
      secondaryContainer: NestPalette.darkAccentContainer,
      onSecondaryContainer: NestPalette.darkText,
      tertiary: NestPalette.brandBadgeGreen,
      onTertiary: NestPalette.darkText,
      tertiaryContainer: NestPalette.darkCardHigh,
      onTertiaryContainer: NestPalette.darkText,
      error: NestPalette.darkDanger,
      onError: NestPalette.darkBackground,
      errorContainer: NestPalette.darkDangerContainer,
      onErrorContainer: NestPalette.darkText,
      surface: NestPalette.darkBackground,
      onSurface: NestPalette.darkText,
      surfaceContainerLowest: NestPalette.darkBackground,
      surfaceContainerLow: NestPalette.darkCard,
      surfaceContainer: NestPalette.darkCard,
      surfaceContainerHigh: NestPalette.darkCardSubtle,
      surfaceContainerHighest: NestPalette.darkCardHigh,
      onSurfaceVariant: NestPalette.darkTextMuted,
      outline: NestPalette.darkBorder,
      outlineVariant: NestPalette.darkCardHigh,
      shadow: NestPalette.darkBackground,
      scrim: NestPalette.darkBackground,
      inverseSurface: NestPalette.lightBackground,
      onInverseSurface: NestPalette.lightText,
      inversePrimary: NestPalette.lightPrimary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      nestColors: NestColors.dark,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required NestColors nestColors,
  }) {
    final TextTheme textTheme = _buildTextTheme(nestColors);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: nestColors.background,
      fontFamily: bodyFontFamily,
      fontFamilyFallback: bodyFontFallback,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: nestColors.background,
        foregroundColor: nestColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: nestColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: nestColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: nestColors.cardBorder),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return nestColors.cardSubtle;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return nestColors.textPrimary;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: nestColors.cardBorder),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: nestColors.cardBorder,
        thickness: 1,
      ),
      extensions: <ThemeExtension<dynamic>>[nestColors],
    );
  }

  static TextTheme _buildTextTheme(NestColors colors) {
    TextStyle displayStyle({
      required double fontSize,
      required double height,
      double letterSpacing = -0.3,
    }) {
      return TextStyle(
        fontFamily: displayFontFamily,
        fontFamilyFallback: displayFontFallback,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      );
    }

    TextStyle bodyStyle({
      required double fontSize,
      required double height,
      FontWeight fontWeight = FontWeight.w400,
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: bodyFontFamily,
        fontFamilyFallback: bodyFontFallback,
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color ?? colors.textPrimary,
      );
    }

    return TextTheme(
      displayLarge: displayStyle(fontSize: 44, height: 1.12),
      displayMedium: displayStyle(fontSize: 36, height: 1.14),
      displaySmall: displayStyle(fontSize: 30, height: 1.18),
      headlineLarge: displayStyle(fontSize: 28, height: 1.2),
      headlineMedium: displayStyle(fontSize: 24, height: 1.24),
      headlineSmall: displayStyle(fontSize: 20, height: 1.26, letterSpacing: -0.2),
      titleLarge: displayStyle(fontSize: 20, height: 1.28, letterSpacing: -0.15),
      titleMedium: bodyStyle(
        fontSize: 16,
        height: 1.38,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: bodyStyle(
        fontSize: 14,
        height: 1.38,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: bodyStyle(fontSize: 16, height: 1.48),
      bodyMedium: bodyStyle(fontSize: 14, height: 1.48),
      bodySmall: bodyStyle(
        fontSize: 12,
        height: 1.42,
        color: colors.textMuted,
      ),
      labelLarge: bodyStyle(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: bodyStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      labelSmall: bodyStyle(
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: colors.textMuted,
      ),
    );
  }
}
