/// Converts HTML email bodies into clean, pipe-preserving plain-text lines.
List<String> htmlToStructuredLines(String html) {
  if (html.trim().isEmpty) return const [];

  var s = html;
  s = s.replaceAll(
    RegExp(r'<!--[\s\S]*?-->', dotAll: true),
    ' ',
  );
  s = s.replaceAll(
    RegExp(
      r'<(script|style|head|noscript|title)\b[^>]*>[\s\S]*?</\1>',
      caseSensitive: false,
      dotAll: true,
    ),
    '\n',
  );
  // Preserve horizontal table column boundaries before stripping tags.
  s = s.replaceAll(
    RegExp(r'</t[dh]\b[^>]*>', caseSensitive: false),
    ' | ',
  );
  s = s.replaceAll(
    RegExp(
      r'<br\s*/?>|<hr\s*/?>|</?(?:tr|p|div|li|ul|ol|table|section|article|blockquote|h[1-6])\b[^>]*>',
      caseSensitive: false,
    ),
    '\n',
  );
  s = s.replaceAll(RegExp(r'<[^>]+>'), ' ');
  s = decodeHtmlEntities(s);

  final out = <String>[];
  for (final rawLine in s.split(RegExp(r'\r?\n'))) {
    var line = rawLine.replaceAll(RegExp(r'[\t \u00A0]+'), ' ').trim();
    if (line.isEmpty) continue;
    if (line.contains('|')) {
      final cells = line
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (cells.isEmpty) continue;
      line = cells.join(' | ');
    }
    if (line.isNotEmpty) out.add(line);
  }
  return out;
}

const _namedEntities = <String, String>{
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'ensp': ' ',
  'emsp': ' ',
  'thinsp': ' ',
  'rupee': '₹',
  'ndash': '-',
  'mdash': '-',
  'minus': '-',
  'middot': '·',
  'bull': '•',
  'times': 'x',
  'lsquo': "'",
  'rsquo': "'",
  'ldquo': '"',
  'rdquo': '"',
};

/// Decodes common named and numeric HTML character entities.
String decodeHtmlEntities(String input) {
  return input.replaceAllMapped(
    RegExp(r'&(#x[0-9A-Fa-f]+|#[0-9]+|[A-Za-z]+);'),
    (m) {
      final token = m.group(1)!;
      if (token.startsWith('#x') || token.startsWith('#X')) {
        final code = int.tryParse(token.substring(2), radix: 16);
        return code != null && code > 0 ? String.fromCharCode(code) : '';
      }
      if (token.startsWith('#')) {
        final code = int.tryParse(token.substring(1));
        return code != null && code > 0 ? String.fromCharCode(code) : '';
      }
      return _namedEntities[token.toLowerCase()] ?? m.group(0)!;
    },
  );
}

/// Splits already plain-text email or PDFBox output into trimmed non-empty lines.
List<String> plainTextToLines(String text) {
  if (text.trim().isEmpty) return const [];
  final out = <String>[];
  for (final raw in text.split(RegExp(r'\r?\n'))) {
    final clean = raw.replaceAll(RegExp(r'[\t \u00A0]+'), ' ').trim();
    if (clean.isNotEmpty) out.add(clean);
  }
  return out;
}
