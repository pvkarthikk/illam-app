import 'dart:math';

import 'package:nm_flat/core/data/secure/secure_store.dart';

/// Generates and persists the 256-bit SQLite3MultipleCiphers database key.
class DbKey {
  DbKey._();

  static const String _storeKey = 'db.key.v1';

  static Future<String> loadOrCreate(SecureStore s) async {
    final existing = await s.read(_storeKey);
    if (existing != null && existing.length == 64) {
      return existing;
    }
    final rng = Random.secure();
    final buf = StringBuffer();
    for (var i = 0; i < 32; i++) {
      buf.write(rng.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    final hex = buf.toString();
    await s.write(_storeKey, hex);
    return hex;
  }

  static Future<void> save(SecureStore s, String hex) =>
      s.write(_storeKey, hex);
}
