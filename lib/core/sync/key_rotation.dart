import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';

/// Handles symmetric home key unwrapping, missing-holder repair rotation, and dial-info snapshots.
class KeyRotation {
  KeyRotation(this.keyRing, this.membershipLog, this.keys);

  final HomeKeyRing keyRing;
  final MembershipLog membershipLog;
  final Future<DeviceKeys> keys;

  DateTime? _lastRotation;

  Uint8List _randomKey() => randomBytes(32);

  bool _rotatedInLast(Duration d) =>
      _lastRotation != null && DateTime.now().difference(_lastRotation!) < d;

  /// Seals [newKey] to every currently active device's X25519 `agreePub`.
  Future<Map<String, Object?>> buildRotatePayload(
    ReplayResult s,
    Uint8List newKey,
  ) async {
    final wrapped = <String, String>{};
    for (final devId in s.activeDeviceIds()) {
      final agreePub = s.devices[devId]?.agreePub ?? '';
      if (agreePub.isEmpty) continue;
      final sealed = await SealedBox.seal(base64Decode(agreePub), newKey);
      wrapped[devId] = base64Encode(sealed);
    }
    return {'wrapped': wrapped};
  }

  /// Picks up newly rotated keys wrapped for [me], and repairs missing active holders if [me] is an admin.
  Future<void> afterReplay(
    ReplayResult s, {
    required String me,
    required String homeId,
  }) async {
    if (s.deleted) return;
    final curKeyId = s.currentKeyId;
    final existing = await keyRing.all(homeId);
    if (curKeyId != null && !existing.any((k) => k.keyId == curKeyId)) {
      final wrapped = s.wrapFor(curKeyId, me);
      if (wrapped != null) {
        final k = await keys;
        final opened = await SealedBox.open(
          await k.agreeKeyPair(),
          base64Decode(wrapped),
        );
        await keyRing.add(homeId, curKeyId, opened);
      }
    }

    final holders = curKeyId == null
        ? const <String>{}
        : (s.keyHolders[curKeyId] ?? const <String>{});
    final missing = s.activeDeviceIds().difference(holders);
    final myDev = s.devices[me];
    final amAdmin =
        s.isActiveDevice(me) &&
        myDev != null &&
        s.members[myDev.memberId]?.role == 'admin';

    if (missing.isNotEmpty &&
        amAdmin &&
        !_rotatedInLast(const Duration(minutes: 1))) {
      _lastRotation = DateTime.now();
      final newKey = _randomKey();
      final payload = await buildRotatePayload(s, newKey);
      final res = await membershipLog.append(homeId, 'rotateKey', payload);
      if (res.effect == 'applied') {
        await keyRing.add(homeId, res.opId, newKey);
      }
    }
  }

  /// Builds [DialInfo] from active peer devices and the current ring keys before erasing [homeId].
  Future<DialInfo> dialInfoFor(
    String homeId,
    ReplayResult s,
    String me,
  ) async {
    final deviceIds = [
      for (final id in s.activeDeviceIds())
        if (id != me) id,
    ];
    final signPubs = <String, String>{};
    for (final id in deviceIds) {
      final pub = await membershipLog.signPubOf(id);
      if (pub != null) {
        signPubs[id] = b64(pub);
      } else {
        final fallback = s.devices[id]?.signPub ?? '';
        if (fallback.isNotEmpty) signPubs[id] = fallback;
      }
    }
    final ring = await keyRing.all(homeId);
    return DialInfo(deviceIds, signPubs, [
      for (final k in ring) base64Encode(k.bytes),
    ]);
  }
}

final keyRotationProvider = Provider<KeyRotation>(
  (ref) => KeyRotation(
    ref.watch(homeKeyRingProvider),
    ref.read(membershipLogProvider),
    ref.watch(deviceKeysProvider.future),
  ),
);
