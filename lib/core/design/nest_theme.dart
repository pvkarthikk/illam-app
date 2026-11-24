import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/nest_colors.dart';
import 'package:nm_flat/core/design/nest_text.dart';

abstract final class NestTheme {
  static final ThemeData _light = _build(NestColors.light, Brightness.light);
  static final ThemeData _dark = _build(NestColors.dark, Brightness.dark);

  static ThemeData light() => _light;
  static ThemeData dark() => _dark;

  static ThemeData _build(NestColors c, Brightness b) {
    final colorScheme = ColorScheme(
      brightness: b,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.primary,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: c.accentSoft,
      onSecondaryContainer: c.accentInk,
      error: c.danger,
      onError: c.onDanger,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.danger,
      surface: c.card,
      onSurface: c.ink,
      onSurfaceVariant: c.ink2,
      surfaceContainerHighest: c.paper2,
      outline: c.line2,
      outlineVariant: c.line,
      scrim: c.scrim,
    );

    final textTheme = ThemeData(brightness: b).textTheme.apply(
      fontFamily: NestText.sans,
      bodyColor: c.ink,
      displayColor: c.ink,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c.line2, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      fontFamily: NestText.sans,
      scaffoldBackgroundColor: c.paper,
      extensions: [c],
      dividerColor: c.line,
      colorScheme: colorScheme,
      textTheme: textTheme,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink,
        contentTextStyle: TextStyle(
          fontFamily: NestText.sans,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.paper,
        ),
        actionTextColor: c.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        showDragHandle: true,
        dragHandleSize: const Size(36, 4),
        dragHandleColor: c.line2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        modalBarrierColor: c.scrim,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.card,
        indicatorColor: c.primarySoft,
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: NestText.sans,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? c.ink : c.ink3,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? c.primary : c.ink3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Color(0xFFFFFAF2)),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.primary
              : c.line2,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }
}
