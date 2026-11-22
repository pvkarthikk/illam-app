import 'dart:math';

import 'package:flutter/services.dart';

enum PwStrength { tooShort, okay, strong }

final _lowerRe = RegExp(r'[a-z]');
final _upperRe = RegExp(r'[A-Z]');
final _digitRe = RegExp(r'[0-9]');
final _symbolRe = RegExp(r'[^a-zA-Z0-9]');

PwStrength passwordStrength(String pw) {
  if (pw.length < 10) return PwStrength.tooShort;
  if (pw.length >= 16) return PwStrength.strong;
  if (pw.length >= 12) {
    var classes = 0;
    if (_lowerRe.hasMatch(pw)) classes++;
    if (_upperRe.hasMatch(pw)) classes++;
    if (_digitRe.hasMatch(pw)) classes++;
    if (_symbolRe.hasMatch(pw)) classes++;
    if (classes >= 3) return PwStrength.strong;
  }
  return PwStrength.okay;
}

String suggestPassword(List<String> words, Random rnd) {
  final picked = [
    for (var i = 0; i < 5; i++) words[rnd.nextInt(words.length)],
    rnd.nextInt(100).toString().padLeft(2, '0'),
  ];
  return picked.join('-');
}

List<String>? _cachedWords;

Future<List<String>> loadWordList() async {
  final cached = _cachedWords;
  if (cached != null) return cached;
  final raw = await rootBundle.loadString('assets/data/eff_large_wordlist.txt');
  final list = [
    for (final line in raw.split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];
  _cachedWords = list;
  return list;
}
