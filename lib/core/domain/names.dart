/// Name rules. Pure Dart.
abstract final class Names {
  static String titleCase(String s) {
    final words = s
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1));
    return words.join(' ');
  }

  static String firstName(String full) {
    final t = titleCase(full);
    return t.isEmpty ? '' : t.split(' ').first;
  }

  static String? surname(String full) {
    final t = titleCase(full);
    return t.isEmpty ? null : t.split(' ').last;
  }
}
