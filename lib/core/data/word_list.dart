import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EFF short word list filtered to lowercase alphabetic join words.
class WordList {
  WordList(this.words) : set = Set<String>.from(words);

  final List<String> words;
  final Set<String> set;

  static final _alpha = RegExp(r'^[a-z]+$');

  static WordList parse(String text) {
    final list = <String>[];
    for (final line in const LineSplitter().convert(text)) {
      final w = line.trim();
      if (_alpha.hasMatch(w)) {
        list.add(w);
      }
    }
    return WordList(list);
  }

  List<String> startingWith(String prefix, {int max = 4}) {
    final out = <String>[];
    for (final w in words) {
      if (w.startsWith(prefix)) {
        out.add(w);
        if (out.length >= max) break;
      }
    }
    return out;
  }
}

final wordListProvider = FutureProvider<WordList>((ref) async {
  final raw = await rootBundle.loadString('assets/data/eff_short_wordlist.txt');
  return WordList.parse(raw);
});
