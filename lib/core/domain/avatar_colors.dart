import 'dart:convert';

abstract final class AvatarColors {
  static const palette = <String>[
    '#23503A',
    '#34508A',
    '#B0412A',
    '#B07A1A',
    '#7A5AA8',
    '#4F8A8B',
    '#8A5A2B',
    '#5E8A2B',
    '#A8362A',
  ];

  static String pick(String memberId, Set<String> used) {
    var h = 0x811c9dc5;
    for (final b in utf8.encode(memberId)) {
      h = h ^ b;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    final start = h % palette.length;
    for (var i = 0; i < palette.length; i++) {
      final c = palette[(start + i) % palette.length];
      if (!used.contains(c)) return c;
    }
    return palette[start];
  }
}
