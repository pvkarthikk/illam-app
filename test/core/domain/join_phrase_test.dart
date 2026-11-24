import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/data/word_list.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';

void main() {
  const words = {'mango', 'river', 'tulip', 'zebra'};
  const wordList = ['mango', 'river', 'tulip', 'zebra'];

  group('JoinPhrase', () {
    test('normalises and checks valid phrases', () {
      expect(
        JoinPhrase.normalise('47 Mango river TULIP'),
        '47-mango-river-tulip',
      );
      expect(JoinPhrase.check('47 Mango river TULIP', words), PhraseCheck.ok);
      expect(JoinPhrase.check('47__mango--river tulip', words), PhraseCheck.ok);
    });

    test('rejects malformed phrases and unknown words', () {
      expect(JoinPhrase.check('mango river', words), PhraseCheck.badFormat);
      expect(
        JoinPhrase.check('07-mango-river-tulip', words),
        PhraseCheck.badFormat,
      );
      expect(
        JoinPhrase.check('12-mango-river-zzzz', words),
        PhraseCheck.unknownWord,
      );
    });

    test('generate always produces valid phrase', () {
      final rng = Random(1);
      for (var i = 0; i < 200; i++) {
        final p = JoinPhrase.generate(wordList, rng);
        expect(JoinPhrase.check(p, words), PhraseCheck.ok);
      }
    });

    test('password and context extract expected bytes', () {
      expect(
        JoinPhrase.password('47-mango-river-tulip'),
        utf8.encode('mango river tulip'),
      );
      expect(JoinPhrase.context('47'), 'illam-join-v1|47');
    });
  });

  group('WordList', () {
    test('parses EFF short wordlist asset', () {
      final lines = File(
        'assets/data/eff_short_wordlist.txt',
      ).readAsLinesSync();
      expect(lines.length, 1296);

      final parsed = WordList.parse(lines.join('\n'));
      expect(parsed.words.length, 1295);
      expect(
        parsed.words.every((w) => w.length >= 3 && w.length <= 5),
        isTrue,
      );
      expect(parsed.set, containsAll(const ['mango', 'river', 'tulip', 'zebra']));
      expect(parsed.set.contains('yo-yo'), isFalse);

      final ma = parsed.startingWith('ma');
      expect(ma.length, lessThanOrEqualTo(4));
      expect(ma.every((w) => w.startsWith('ma')), isTrue);
    });
  });

  group('JoinTicket', () {
    test('toUrl and parse round-trip and reject invalid URLs', () {
      final t = JoinTicket(
        homeId: 'NM-ABCD2345',
        ip: '192.168.1.5',
        port: 40123,
        nameplate: '47',
        secret: List.generate(16, (i) => i),
        expiry: 1763600600,
      );
      final url = t.toUrl();
      final parsed = JoinTicket.parse(url);
      expect(parsed, isNotNull);
      expect(parsed!.homeId, t.homeId);
      expect(parsed.ip, t.ip);
      expect(parsed.port, t.port);
      expect(parsed.nameplate, t.nameplate);
      expect(parsed.secret, t.secret);
      expect(parsed.expiry, t.expiry);

      expect(
        JoinTicket.parse(url.replaceFirst('illam.app', 'evil.app')),
        isNull,
      );
      expect(JoinTicket.parse(url.replaceFirst('v=1', 'v=2')), isNull);
      expect(JoinTicket.parse('hello'), isNull);
    });
  });
}
