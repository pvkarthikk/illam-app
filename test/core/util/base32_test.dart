import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/util/base32.dart';
import 'package:nm_flat/core/util/ids.dart';

void main() {
  group('Base32', () {
    test('RFC 4648 test vectors without padding', () {
      const vectors = {
        '': '',
        'f': 'MY',
        'fo': 'MZXQ',
        'foo': 'MZXW6',
        'foob': 'MZXW6YQ',
        'fooba': 'MZXW6YTB',
        'foobar': 'MZXW6YTBOI',
      };
      for (final entry in vectors.entries) {
        final encoded = Base32.encode(utf8.encode(entry.key));
        expect(encoded, entry.value);
        expect(Base32.decode(encoded), utf8.encode(entry.key));
      }
    });

    test('round-trips random byte lists of lengths 0..40', () {
      final rnd = Random(42);
      for (var len = 0; len <= 40; len++) {
        final input = List.generate(len, (_) => rnd.nextInt(256));
        expect(Base32.decode(Base32.encode(input)), input);
      }
    });

    test('decode is case-insensitive and ignores =', () {
      expect(Base32.decode('mzxw6'), utf8.encode('foo'));
      expect(Base32.decode('MZXW6==='), utf8.encode('foo'));
    });

    test('decode throws FormatException on invalid characters', () {
      expect(() => Base32.decode('MZ!'), throwsFormatException);
    });
  });

  group('Ids', () {
    test('randomDeviceId returns distinct 16-char lowercase base32 strings', () {
      final first = Ids.randomDeviceId();
      final second = Ids.randomDeviceId();
      expect(first.length, 16);
      expect(second.length, 16);
      expect(RegExp(r'^[a-z2-7]{16}$').hasMatch(first), isTrue);
      expect(RegExp(r'^[a-z2-7]{16}$').hasMatch(second), isTrue);
      expect(first, isNot(second));
    });

    test('newId returns 36-char UUID v4 and randomBytes returns requested len', () {
      expect(Ids.newId().length, 36);
      expect(Ids.randomBytes(16).length, 16);
    });
  });
}
