/// Formats a positive quantity [n] as a human-friendly fraction or number.
/// Callers append [unit] (or localize `'a pinch'` via `l10n.recipeAPinch`).
String formatFraction(double n, String unit) {
  if (n > 0 && n < 0.125) {
    return unit == 'pinch' ? 'a pinch' : '<¼';
  }
  if ((unit == 'g' || unit == 'ml') && n >= 10) {
    return '${n.round()}';
  }
  final q = (n * 4).round() / 4;
  final whole = q.floor();
  final rem = ((q - whole) * 4).round();
  if (rem == 0) {
    return '$whole';
  }
  final glyph = switch (rem) {
    1 => '¼',
    2 => '½',
    _ => '¾',
  };
  return whole == 0 ? glyph : '$whole$glyph';
}
