import 'package:material_ui/material_ui.dart';

/// Raw palette constants derived from the Nest Mojo - Flat visual design.
///
/// Screens should read colors from `context.nest` ([NestColors]) or
/// `Theme.of(context).colorScheme` rather than referencing hex literals.
abstract final class NestPalette {
  // Brand / hero patterned background (deep green with warm radial accents).
  static const Color brandCanvas = Color(0xFF12201A);
  static const Color brandCanvasGlowGreen = Color(0xFF23503A);
  static const Color brandCanvasGlowWarm = Color(0xFFD98F1C);
  static const Color brandCanvasDot = Color(0xFFEFE7D8);
  static const Color brandCard = Color(0xFF1C3327);
  static const Color brandCardBorder = Color(0x33EFE7D8);
  static const Color brandText = Color(0xFFEFE7D8);
  static const Color brandTextMuted = Color(0xFFC7D1C9);
  static const Color brandBadgeGreen = Color(0xFF2E8B5F);
  static const Color brandBadgeAmber = Color(0xFFB88337);
  static const Color brandLogoSurface = Color(0xFFF4CC49);
  static const Color brandLogoInk = Color(0xFF1D2A21);

  // Light app theme tokens.
  static const Color lightBackground = Color(0xFFF4ECDF);
  static const Color lightCard = Color(0xFFFFFDF8);
  static const Color lightCardSubtle = Color(0xFFFAF3E6);
  static const Color lightCardHigh = Color(0xFFEDE3D2);
  static const Color lightBorder = Color(0xFFD9CEBC);
  static const Color lightText = Color(0xFF1D2A21);
  static const Color lightTextMuted = Color(0xFF4F6054);
  static const Color lightPrimary = Color(0xFF23503A);
  static const Color lightPrimaryContainer = Color(0xFFD7E7DD);
  static const Color lightAccent = Color(0xFFD98F1C);
  static const Color lightAccentContainer = Color(0xFFFBE9C8);
  static const Color lightDanger = Color(0xFFB0412A);
  static const Color lightDangerContainer = Color(0xFFFADCD5);

  // Dark app theme tokens.
  static const Color darkBackground = Color(0xFF0F1612);
  static const Color darkCard = Color(0xFF16221C);
  static const Color darkCardSubtle = Color(0xFF1C2C24);
  static const Color darkCardHigh = Color(0xFF24372E);
  static const Color darkBorder = Color(0xFF2D4237);
  static const Color darkText = Color(0xFFEFE7D8);
  static const Color darkTextMuted = Color(0xFFB1BEB4);
  static const Color darkPrimary = Color(0xFF8FD0A8);
  static const Color darkPrimaryContainer = Color(0xFF23503A);
  static const Color darkAccent = Color(0xFFF0B44E);
  static const Color darkAccentContainer = Color(0xFF4D3611);
  static const Color darkDanger = Color(0xFFF08C72);
  static const Color darkDangerContainer = Color(0xFF5D2316);
}

/// Semantic Nest Mojo - Flat color tokens attached to [ThemeData].
@immutable
class NestColors extends ThemeExtension<NestColors> {
  const NestColors({
    required this.background,
    required this.card,
    required this.cardSubtle,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.primary,
    required this.accent,
    required this.danger,
    required this.brandCanvas,
    required this.brandCanvasGlowGreen,
    required this.brandCanvasGlowWarm,
    required this.brandCanvasDot,
    required this.brandCard,
    required this.brandCardBorder,
    required this.brandText,
    required this.brandTextMuted,
    required this.brandBadgeGreen,
    required this.brandBadgeAmber,
    required this.brandLogoSurface,
    required this.brandLogoInk,
  });

  final Color background;
  final Color card;
  final Color cardSubtle;
  final Color cardBorder;
  final Color textPrimary;
  final Color textMuted;
  final Color primary;
  final Color accent;
  final Color danger;
  final Color brandCanvas;
  final Color brandCanvasGlowGreen;
  final Color brandCanvasGlowWarm;
  final Color brandCanvasDot;
  final Color brandCard;
  final Color brandCardBorder;
  final Color brandText;
  final Color brandTextMuted;
  final Color brandBadgeGreen;
  final Color brandBadgeAmber;
  final Color brandLogoSurface;
  final Color brandLogoInk;

  static const NestColors light = NestColors(
    background: NestPalette.lightBackground,
    card: NestPalette.lightCard,
    cardSubtle: NestPalette.lightCardSubtle,
    cardBorder: NestPalette.lightBorder,
    textPrimary: NestPalette.lightText,
    textMuted: NestPalette.lightTextMuted,
    primary: NestPalette.lightPrimary,
    accent: NestPalette.lightAccent,
    danger: NestPalette.lightDanger,
    brandCanvas: NestPalette.brandCanvas,
    brandCanvasGlowGreen: NestPalette.brandCanvasGlowGreen,
    brandCanvasGlowWarm: NestPalette.brandCanvasGlowWarm,
    brandCanvasDot: NestPalette.brandCanvasDot,
    brandCard: NestPalette.brandCard,
    brandCardBorder: NestPalette.brandCardBorder,
    brandText: NestPalette.brandText,
    brandTextMuted: NestPalette.brandTextMuted,
    brandBadgeGreen: NestPalette.brandBadgeGreen,
    brandBadgeAmber: NestPalette.brandBadgeAmber,
    brandLogoSurface: NestPalette.brandLogoSurface,
    brandLogoInk: NestPalette.brandLogoInk,
  );

  static const NestColors dark = NestColors(
    background: NestPalette.darkBackground,
    card: NestPalette.darkCard,
    cardSubtle: NestPalette.darkCardSubtle,
    cardBorder: NestPalette.darkBorder,
    textPrimary: NestPalette.darkText,
    textMuted: NestPalette.darkTextMuted,
    primary: NestPalette.darkPrimary,
    accent: NestPalette.darkAccent,
    danger: NestPalette.darkDanger,
    brandCanvas: NestPalette.brandCanvas,
    brandCanvasGlowGreen: NestPalette.brandCanvasGlowGreen,
    brandCanvasGlowWarm: NestPalette.brandCanvasGlowWarm,
    brandCanvasDot: NestPalette.brandCanvasDot,
    brandCard: NestPalette.brandCard,
    brandCardBorder: NestPalette.brandCardBorder,
    brandText: NestPalette.brandText,
    brandTextMuted: NestPalette.brandTextMuted,
    brandBadgeGreen: NestPalette.brandBadgeGreen,
    brandBadgeAmber: NestPalette.brandBadgeAmber,
    brandLogoSurface: NestPalette.brandLogoSurface,
    brandLogoInk: NestPalette.brandLogoInk,
  );

  @override
  NestColors copyWith({
    Color? background,
    Color? card,
    Color? cardSubtle,
    Color? cardBorder,
    Color? textPrimary,
    Color? textMuted,
    Color? primary,
    Color? accent,
    Color? danger,
    Color? brandCanvas,
    Color? brandCanvasGlowGreen,
    Color? brandCanvasGlowWarm,
    Color? brandCanvasDot,
    Color? brandCard,
    Color? brandCardBorder,
    Color? brandText,
    Color? brandTextMuted,
    Color? brandBadgeGreen,
    Color? brandBadgeAmber,
    Color? brandLogoSurface,
    Color? brandLogoInk,
  }) {
    return NestColors(
      background: background ?? this.background,
      card: card ?? this.card,
      cardSubtle: cardSubtle ?? this.cardSubtle,
      cardBorder: cardBorder ?? this.cardBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      brandCanvas: brandCanvas ?? this.brandCanvas,
      brandCanvasGlowGreen: brandCanvasGlowGreen ?? this.brandCanvasGlowGreen,
      brandCanvasGlowWarm: brandCanvasGlowWarm ?? this.brandCanvasGlowWarm,
      brandCanvasDot: brandCanvasDot ?? this.brandCanvasDot,
      brandCard: brandCard ?? this.brandCard,
      brandCardBorder: brandCardBorder ?? this.brandCardBorder,
      brandText: brandText ?? this.brandText,
      brandTextMuted: brandTextMuted ?? this.brandTextMuted,
      brandBadgeGreen: brandBadgeGreen ?? this.brandBadgeGreen,
      brandBadgeAmber: brandBadgeAmber ?? this.brandBadgeAmber,
      brandLogoSurface: brandLogoSurface ?? this.brandLogoSurface,
      brandLogoInk: brandLogoInk ?? this.brandLogoInk,
    );
  }

  @override
  NestColors lerp(ThemeExtension<NestColors>? other, double t) {
    if (other is! NestColors) {
      return this;
    }
    return NestColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardSubtle: Color.lerp(cardSubtle, other.cardSubtle, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      brandCanvas: Color.lerp(brandCanvas, other.brandCanvas, t)!,
      brandCanvasGlowGreen: Color.lerp(
        brandCanvasGlowGreen,
        other.brandCanvasGlowGreen,
        t,
      )!,
      brandCanvasGlowWarm: Color.lerp(
        brandCanvasGlowWarm,
        other.brandCanvasGlowWarm,
        t,
      )!,
      brandCanvasDot: Color.lerp(brandCanvasDot, other.brandCanvasDot, t)!,
      brandCard: Color.lerp(brandCard, other.brandCard, t)!,
      brandCardBorder: Color.lerp(brandCardBorder, other.brandCardBorder, t)!,
      brandText: Color.lerp(brandText, other.brandText, t)!,
      brandTextMuted: Color.lerp(brandTextMuted, other.brandTextMuted, t)!,
      brandBadgeGreen: Color.lerp(brandBadgeGreen, other.brandBadgeGreen, t)!,
      brandBadgeAmber: Color.lerp(brandBadgeAmber, other.brandBadgeAmber, t)!,
      brandLogoSurface: Color.lerp(
        brandLogoSurface,
        other.brandLogoSurface,
        t,
      )!,
      brandLogoInk: Color.lerp(brandLogoInk, other.brandLogoInk, t)!,
    );
  }
}

/// Convenience accessor for [NestColors] from any [BuildContext].
extension NestColorsContext on BuildContext {
  NestColors get nest =>
      Theme.of(this).extension<NestColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? NestColors.dark
          : NestColors.light);
}
