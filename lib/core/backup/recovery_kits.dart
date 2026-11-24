import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/canonical_json.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/sync/membership_log.dart';

/// Canonical UTF-8 bytes signed by a recovery kit for a `recover` op.
List<int> recoverMessage(Map<String, Object?> payload) {
  final copy = Map<String, Object?>.from(payload)..remove('recoverySig');
  return utf8.encode(canonicalJson(copy));
}

/// Signs a `recover` op payload using the recovery kit's 32-byte Ed25519 [kitSeed].
Future<String> signRecover(
  Map<String, Object?> payload,
  List<int> kitSeed,
) async {
  final ed = Ed25519();
  final kp = await ed.newKeyPairFromSeed(kitSeed);
  final sig = await ed.sign(recoverMessage(payload), keyPair: kp);
  return b64(sig.bytes);
}

/// Verifies `payload['recoverySig']` against `payload['kitPub']` over `recoverMessage`.
Future<bool> verifyRecover(Map<String, Object?> payload) async {
  try {
    final sigRaw = payload['recoverySig'];
    final kitPubRaw = payload['kitPub'];
    if (sigRaw is! String || kitPubRaw is! String) return false;
    final sigBytes = unb64(sigRaw);
    final pubBytes = decodeKey(kitPubRaw);
    return await Ed25519().verify(
      recoverMessage(payload),
      signature: Signature(
        sigBytes,
        publicKey: SimplePublicKey(
          Uint8List.fromList(pubBytes),
          type: KeyPairType.ed25519,
        ),
      ),
    );
  } on Object {
    return false;
  }
}

/// Manages this phone's per-home Ed25519 recovery kit in [BackupConfigStore] and [MembershipLog].
class RecoveryKits {
  RecoveryKits(this.configs, this.log, this.keys, this.prefs);

  final BackupConfigStore configs;
  final MembershipLog log;
  final Future<DeviceKeys> keys;
  final DevicePrefs prefs;

  Future<bool> isLive(String homeId) async {
    final cfg = await configs.load(homeId);
    final pub = cfg.kit?['pub'];
    if (pub is! String || pub.isEmpty) return false;
    final replay = await log.replayState(homeId);
    return replay.liveKits.containsKey(pub);
  }

  Future<bool> ensureLive(String homeId, {bool force = false}) async {
    final provisional = prefs.getText('provisionalRestore_$homeId');
    if (provisional != null && provisional.isNotEmpty) return false;

    final cfg = await configs.load(homeId);
    if (cfg.kit != null && !force && await isLive(homeId)) return true;

    final ed = Ed25519();
    final kp = await ed.newKeyPair();
    final seed = await kp.extractPrivateKeyBytes();
    final pub = (await kp.extractPublicKey()).bytes;
    final pubB64 = b64(pub);
    final k = await keys;

    final res = await log.append(homeId, 'addRecoveryKey', {
      'pub': pubB64,
      'deviceId': k.deviceId,
    });
    if (res.effect == 'applied') {
      cfg.kit = {'pub': pubB64, 'seed': b64(seed)};
      await configs.save(homeId, cfg);
      return true;
    }
    return false;
  }
}

