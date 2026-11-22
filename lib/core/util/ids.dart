import 'dart:math';

import 'package:nm_flat/core/util/base32.dart';
import 'package:uuid/uuid.dart';

abstract final class Ids {
  static final _rnd = Random.secure();

  static String newId() => const Uuid().v4();

  static List<int> randomBytes(int n) =>
      List.generate(n, (_) => _rnd.nextInt(256));

  /// Every byte as 2 lowercase hex digits, concatenated.
  static String hex(List<int> b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  /// Temporary device id (P02): 10 random bytes → Base32 → lowercase → first 16 chars.
  static String randomDeviceId() =>
      Base32.encode(randomBytes(10)).toLowerCase().substring(0, 16);
}
