import 'package:nm_flat/core/domain/spend_category.dart';

/// Parsed components of a quick-add spend string.
class ParsedSpend {
  const ParsedSpend(this.amountPaise, this.merchant, this.category);

  final int amountPaise;
  final String merchant;
  final String category;
}

final _amountRe = RegExp(
  r'(?:₹|rs\.?\s*)?(\d[\d,]*(?:\.\d+)?)',
  caseSensitive: false,
);
final _noiseWordsRe = RegExp(
  r'\b(?:spent|paid|at|to|on|for)\b',
  caseSensitive: false,
);

/// Parses a free-form spend string such as "₹450 Swiggy".
ParsedSpend parseSpend(
  String text,
  Map<String, String> rules, {
  required String fallbackMerchant,
}) {
  final match = _amountRe.firstMatch(text);
  final int amountPaise;
  final String restRaw;
  if (match == null) {
    amountPaise = 0;
    restRaw = text;
  } else {
    final numStr = match.group(1)!.replaceAll(',', '');
    final parsed = double.tryParse(numStr) ?? 0;
    amountPaise = (parsed * 100).round();
    restRaw = text.replaceFirst(match.group(0)!, ' ');
  }

  final cleaned = restRaw
      .replaceAll(_noiseWordsRe, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final merchant = cleaned.isEmpty
      ? fallbackMerchant
      : '${cleaned[0].toUpperCase()}${cleaned.substring(1)}';
  final category = guessSpendCategory(merchant, rules);
  return ParsedSpend(amountPaise, merchant, category);
}
