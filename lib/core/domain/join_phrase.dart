import 'dart:convert';
import 'dart:math';

import 'package:nm_flat/core/crypto/bytes.dart';

enum PhraseCheck { ok, badFormat, unknownWord }

/// Pure helpers for generating, normalising, and validating 3-word join phrases.
abstract final class JoinPhrase {
  static final _format = RegExp(r'^[1-9][0-9]-[a-z]+-[a-z]+-[a-z]+$');
  static final _sep = RegExp(r'[\s_\-]+');

  static String normalise(String s) =>
      s.trim().toLowerCase().replaceAll(_sep, '-');

  static PhraseCheck check(String input, Set<String> words) {
    final norm = normalise(input);
    if (!_format.hasMatch(norm)) return PhraseCheck.badFormat;
    final parts = norm.split('-').skip(1);
    for (final w in parts) {
      if (!words.contains(w)) return PhraseCheck.unknownWord;
    }
    return PhraseCheck.ok;
  }

  static String generate(List<String> words, Random rng) {
    final n = 10 + rng.nextInt(90);
    final w1 = words[rng.nextInt(words.length)];
    final w2 = words[rng.nextInt(words.length)];
    final w3 = words[rng.nextInt(words.length)];
    return '$n-$w1-$w2-$w3';
  }

  static String nameplate(String phrase) => normalise(phrase).split('-').first;

  static List<int> password(String phrase) =>
      utf8.encode(normalise(phrase).split('-').skip(1).join(' '));

  static String context(String nameplate) => 'illam-join-v1|$nameplate';
}

/// QR ticket encoding connection details and ephemeral PAKE secret.
class JoinTicket {
  const JoinTicket({
    required this.homeId,
    required this.ip,
    required this.nameplate,
    required this.port,
    required this.secret,
    required this.expiry,
  });

  final String homeId;
  final String ip;
  final String nameplate;
  final int port;
  final List<int> secret;
  final int expiry;

  String toUrl() {
    final a = b64url(
      utf8.encode(jsonEncode({'ip': ip, 'p': port, 'n': nameplate})),
    );
    final s = b64url(secret);
    return 'https://illam.app/j#v=1&h=$homeId&a=$a&s=$s&e=$expiry';
  }

  static JoinTicket? parse(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host != 'illam.app' || uri.path != '/j') {
        return null;
      }
      final q = Uri.splitQueryString(uri.fragment);
      if (q['v'] != '1') return null;
      final h = q['h'];
      final aRaw = q['a'];
      final sRaw = q['s'];
      final eRaw = q['e'];
      if (h == null ||
          h.isEmpty ||
          aRaw == null ||
          sRaw == null ||
          eRaw == null) {
        return null;
      }
      final addr =
          jsonDecode(utf8.decode(unb64url(aRaw))) as Map<String, Object?>;
      return JoinTicket(
        homeId: h,
        ip: addr['ip'] as String,
        nameplate: addr['n'] as String,
        port: (addr['p'] as num).toInt(),
        secret: unb64url(sRaw),
        expiry: int.parse(eRaw),
      );
    } on Object {
      return null;
    }
  }
}
