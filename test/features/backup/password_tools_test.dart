import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/features/backup/password_tools.dart';

void main() {
  test('passwordStrength classifies lengths and character classes', () {
    expect(passwordStrength('123456789'), PwStrength.tooShort);
    expect(passwordStrength('abcdefghij'), PwStrength.okay);
    expect(passwordStrength('Abcdefgh1234'), PwStrength.strong);
    expect(passwordStrength('abcdefghijklmnop'), PwStrength.strong);
  });

  test('suggestPassword returns 5 words and a 2-digit suffix', () {
    final s = suggestPassword(const ['a', 'b', 'c', 'd', 'e', 'f'], Random(1));
    final parts = s.split('-');
    expect(parts.length, 6);
    expect(RegExp(r'^\d{2}$').hasMatch(parts.last), isTrue);
    for (var i = 0; i < 5; i++) {
      expect(['a', 'b', 'c', 'd', 'e', 'f'], contains(parts[i]));
    }
  });
}
