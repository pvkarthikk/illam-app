import 'package:nm_flat/core/domain/merchant_key.dart';

const spendCategories = <String>[
  'Groceries',
  'Shopping',
  'Staff',
  'Utilities',
  'Eating out',
  'Home care',
  'Other',
];

const int maxSpendCategoryLength = 32;

/// Normalizes a user-entered or stored spend category name while preserving
/// canonical built-in spellings and clamping length to [maxSpendCategoryLength].
String normalizeSpendCategory(String raw, {String fallback = 'Other'}) {
  var clean = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (clean.isEmpty) return fallback;

  final lower = clean.toLowerCase();
  for (final cat in spendCategories) {
    if (cat.toLowerCase() == lower) return cat;
  }

  if (clean == clean.toLowerCase()) {
    clean = '${clean[0].toUpperCase()}${clean.substring(1)}';
  }
  if (clean.length > maxSpendCategoryLength) {
    clean = clean.substring(0, maxSpendCategoryLength).trimRight();
  }
  return clean.isEmpty ? fallback : clean;
}

/// Returns built-in categories (with `'Other'` last) merged with normalized,
/// A–Z sorted custom categories from [extra].
List<String> mergeSpendCategories(Iterable<String> extra) {
  final builtInNonOther = [
    for (final cat in spendCategories)
      if (cat != 'Other') cat,
  ];
  final builtInLower = {for (final cat in spendCategories) cat.toLowerCase()};
  final customByLower = <String, String>{};

  for (final raw in extra) {
    final clean = normalizeSpendCategory(raw, fallback: '');
    if (clean.isEmpty) continue;
    final lower = clean.toLowerCase();
    if (builtInLower.contains(lower)) continue;
    customByLower.putIfAbsent(lower, () => clean);
  }

  final customSorted = customByLower.values.toList()
    ..sort((a, b) {
      final ci = a.toLowerCase().compareTo(b.toLowerCase());
      return ci != 0 ? ci : a.compareTo(b);
    });

  return [...builtInNonOther, ...customSorted, 'Other'];
}

const _keywordGroups = <(String, List<String>)>[
  (
    'Groceries',
    [
      'zepto',
      'blinkit',
      'bigbasket',
      'instamart',
      'dmart',
      'd-mart',
      'milk',
      'sabzi',
      'kirana',
      'fresh',
    ],
  ),
  (
    'Shopping',
    ['amazon', 'flipkart', 'meesho', 'myntra', 'ajio', 'nykaa'],
  ),
  (
    'Eating out',
    ['swiggy', 'zomato', 'restaurant', 'cafe', 'dominos'],
  ),
  (
    'Utilities',
    [
      'electricity',
      'bescom',
      'water',
      'gas',
      'broadband',
      'wifi',
      'recharge',
      'dth',
      'bill',
    ],
  ),
  (
    'Home care',
    [
      'urban company',
      'plumber',
      'electrician',
      'laundry',
      'ironing',
      'maintenance',
    ],
  ),
];

/// Guesses a spend category from [merchant], giving priority to learned [rules].
String guessSpendCategory(String merchant, Map<String, String> rules) {
  final key = merchantKey(merchant);
  final learned = rules[key];
  if (learned != null && learned.isNotEmpty) {
    return learned;
  }
  for (final (category, keywords) in _keywordGroups) {
    for (final kw in keywords) {
      if (key.contains(kw)) {
        return category;
      }
    }
  }
  return 'Other';
}
