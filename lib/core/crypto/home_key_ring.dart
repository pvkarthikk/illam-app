import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/providers.dart';

/// Symmetric key entry stored in a home's key ring.
class HomeKey {
  const HomeKey(this.keyId, this.bytes);

  final String keyId;
  final Uint8List bytes;
}

/// Ordered ring of up to [max] per-home symmetric keys in [SecureStore].
class HomeKeyRing {
  const HomeKeyRing(this.store);

  static const int max = 3;

  final SecureStore store;

  Future<List<String>> _ids(String homeId) async {
    final raw = await store.read(SecureKeys.homeKeyIds(homeId));
    if (raw != null) {
      return [for (final e in jsonDecode(raw) as List) e as String];
    }
    final genesis = await store.read(SecureKeys.homeKey(homeId, 'genesis'));
    if (genesis != null) return ['genesis'];
    return const [];
  }

  Future<List<HomeKey>> all(String homeId) async {
    final ids = await _ids(homeId);
    final out = <HomeKey>[];
    for (final id in ids) {
      final raw = await store.read(SecureKeys.homeKey(homeId, id));
      if (raw == null) continue;
      out.add(HomeKey(id, Uint8List.fromList(base64Decode(raw))));
    }
    return out;
  }

  Future<HomeKey?> current(String homeId) async {
    final list = await all(homeId);
    return list.isEmpty ? null : list.first;
  }

  Future<void> add(String homeId, String keyId, List<int> bytes) async {
    await store.write(SecureKeys.homeKey(homeId, keyId), base64Encode(bytes));
    final prev = await _ids(homeId);
    final next = [
      keyId,
      for (final id in prev)
        if (id != keyId) id,
    ];
    for (var i = max; i < next.length; i++) {
      await store.delete(SecureKeys.homeKey(homeId, next[i]));
    }
    final kept = next.length > max ? next.sublist(0, max) : next;
    await store.write(SecureKeys.homeKeyIds(homeId), jsonEncode(kept));
  }

  Future<void> clear(String homeId) async {
    final ids = await _ids(homeId);
    for (final id in ids) {
      await store.delete(SecureKeys.homeKey(homeId, id));
    }
    await store.delete(SecureKeys.homeKeyIds(homeId));
  }
}

final homeKeyRingProvider = Provider<HomeKeyRing>(
  (ref) => HomeKeyRing(ref.watch(secureStoreProvider)),
);
