import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/app_locale.dart';

void main() {
  test('normalizeStoredLanguage accepts system, en, ta, hi and normalizes variants', () {
    expect(normalizeStoredLanguage(null), systemLanguageCode);
    expect(normalizeStoredLanguage(''), systemLanguageCode);
    expect(normalizeStoredLanguage('system'), systemLanguageCode);
    expect(normalizeStoredLanguage('en'), 'en');
    expect(normalizeStoredLanguage('en_US'), 'en');
    expect(normalizeStoredLanguage('ta-IN'), 'ta');
    expect(normalizeStoredLanguage('HI'), 'hi');
    expect(normalizeStoredLanguage('fr'), systemLanguageCode);
  });

  test('resolveLanguageCode aligns with supported system language or falls back to en', () {
    expect(resolveLanguageCode('system', ['ta_IN']), 'ta');
    expect(resolveLanguageCode('system', ['hi']), 'hi');
    expect(resolveLanguageCode('system', ['en_GB']), 'en');
    expect(resolveLanguageCode('system', ['fr_FR', 'kn_IN']), 'en');
    expect(resolveLanguageCode('system', ['fr_FR', 'ta_IN']), 'ta');
    expect(resolveLanguageCode('system', const []), 'en');
  });

  test('explicit user choice overrides system language', () {
    expect(resolveLanguageCode('ta', ['en_US']), 'ta');
    expect(resolveLanguageCode('hi', ['ta_IN']), 'hi');
    expect(resolveLanguageCode('en', ['hi_IN']), 'en');
  });
}
