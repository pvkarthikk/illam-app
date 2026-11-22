import 'package:material_ui/material_ui.dart';

abstract final class NestText {
  static const serif = 'YoungSerif';
  static const sans = 'HankenGrotesk';

  static TextStyle _serif(
    double size, {
    double? height,
    double? spacing,
    List<FontFeature>? features,
  }) => TextStyle(
    fontFamily: serif,
    fontSize: size,
    fontWeight: FontWeight.w400,
    height: height,
    letterSpacing: spacing,
    fontFeatures: features,
  );

  static TextStyle _sans(
    double size,
    double weight, {
    double? height,
    double? spacing,
    List<FontFeature>? features,
  }) => TextStyle(
    fontFamily: sans,
    fontSize: size,
    height: height,
    letterSpacing: spacing,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation.weight(weight)],
    fontFeatures: features,
  );

  static const _tab = [FontFeature.tabularFigures()];

  // Serif styles (YoungSerif, weight 400)
  static final display38 = _serif(38, height: 1.05, spacing: -0.57);
  static final display34 = _serif(34, height: 1.05);
  static final display30 = _serif(30, height: 1.05);
  static final title28 = _serif(28);
  static final sheetTitle24 = _serif(24);
  static final title22 = _serif(22);
  static final cardTitle20 = _serif(20);
  static final bigNumber30 = _serif(30, features: _tab);
  static final bigNumber54 = _serif(54, features: _tab);

  // Sans styles (HankenGrotesk variable)
  static final section13 = _sans(13, 800, spacing: 1.04);
  static final eyebrow12 = _sans(12, 700, spacing: 0.96);
  static final itemTitle16 = _sans(16, 650, height: 1.25);
  static final body16 = _sans(16, 400);
  static final body15 = _sans(15, 400, height: 1.45);
  static final meta13 = _sans(13, 500);
  static final small12 = _sans(12, 600);
  static final button15 = _sans(15, 700);
  static final button16 = _sans(16, 700);
  static final tag12 = _sans(12, 700);
  static final figures16 = _sans(16, 700, features: _tab);
}
