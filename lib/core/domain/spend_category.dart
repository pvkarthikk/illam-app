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
