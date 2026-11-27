const supportedLanguageCodes = ['en', 'ta', 'hi'];

const systemLanguageCode = 'system';

/// Normalizes a persisted language preference (`'system'`, `'en'`, `'ta'`, or `'hi'`).
String normalizeStoredLanguage(String? raw) {
  final clean = (raw ?? '').trim().toLowerCase();
  if (clean == systemLanguageCode || clean.isEmpty) {
    return systemLanguageCode;
  }
  final base = clean.split(RegExp(r'[-_]')).first;
  return supportedLanguageCodes.contains(base) ? base : systemLanguageCode;
}

/// Resolves the active app language code from [stored] preference and prioritized
/// [systemLanguageCodes], falling back to `'en'` when none are supported.
String resolveLanguageCode(
  String stored,
  Iterable<String> systemLanguageCodes,
) {
  final normalized = normalizeStoredLanguage(stored);
  if (normalized != systemLanguageCode) return normalized;

  for (final code in systemLanguageCodes) {
    final base = code.trim().split(RegExp(r'[-_]')).first.toLowerCase();
    if (supportedLanguageCodes.contains(base)) {
      return base;
    }
  }
  return 'en';
}
