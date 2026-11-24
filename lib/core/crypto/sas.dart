import 'dart:convert';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/kdf.dart';

/// 64 Emoji <= 5.0 symbols used for 3-emoji Short Authentication String checks.
const List<String> sasEmojis = [
  '🐶', '🐱', '🐭', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧',
  '🐦', '🦆', '🦉', '🐴', '🦄', '🐝', '🦋', '🐌', '🐢', '🐍', '🐙', '🦀', '🐠', '🐬', '🐳', '🐞',
  '🍎', '🍋', '🍌', '🍉', '🍇', '🍓', '🍒', '🍑', '🍍', '🥥', '🥕', '🌽', '🥑', '🍄', '🥜', '🍞',
  '🧀', '🍕', '🍩', '🍪', '🎂', '☕', '🌻', '🌵', '🌲', '🌙', '⭐', '🔥', '🌈', '⚽', '🎸', '🎈',
];

/// Derives 3 verification emojis from shared [ke], channel [transcript], and nonces [nI] / [nJ].
Future<List<String>> sasFor(
  List<int> ke,
  List<int> transcript,
  List<int> nI,
  List<int> nJ,
) async {
  final b = await hkdfSha256(
    ikm: ke,
    salt: transcript,
    info: concatBytes([utf8.encode('illam/sas/v1'), nI, nJ]),
    length: 3,
  );
  return [for (final byte in b) sasEmojis[byte & 63]];
}
