import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/util/base32.dart';
import 'package:nm_flat/core/util/ids.dart';

/// The phone's own key pairs. Seeds live only in [SecureStore].
class DeviceKeys {
  DeviceKeys._({
    required this.signSeed,
    required this.signPub,
    required this.agreeSeed,
    required this.agreePub,
    required this.deviceId,
    required this.fingerprint,
  });

  final List<int> signSeed;
  final List<int> signPub;
  final List<int> agreeSeed;
  final List<int> agreePub;
  final String deviceId;
  final String fingerprint;

  SimpleKeyPair? _signKp;
  SimpleKeyPair? _agreeKp;

  String get signPubB64 => base64.encode(signPub);

  /// Cached Ed25519 key pair derived from [signSeed].
  Future<SimpleKeyPair> signKeyPair() async =>
      _signKp ??= await Ed25519().newKeyPairFromSeed(signSeed);

  /// Cached X25519 key pair derived from [agreeSeed].
  Future<SimpleKeyPair> agreeKeyPair() async =>
      _agreeKp ??= await X25519().newKeyPairFromSeed(agreeSeed);

  static Future<DeviceKeys> ensure(SecureStore s) async =>
      (await load(s)) ?? await create(s);

  static Future<DeviceKeys?> load(SecureStore s) async {
    final sign = await s.read(SecureKeys.signSeed);
    final agree = await s.read(SecureKeys.agreeSeed);
    if (sign == null || agree == null) return null;
    return fromSeeds(base64.decode(sign), base64.decode(agree));
  }

  static Future<DeviceKeys> create(SecureStore s) async {
    final sign = Ids.randomBytes(32);
    final agree = Ids.randomBytes(32);
    await s.write(SecureKeys.signSeed, base64.encode(sign));
    await s.write(SecureKeys.agreeSeed, base64.encode(agree));
    return fromSeeds(sign, agree);
  }

  static Future<String> deviceIdFor(List<int> signPub) async {
    final h = (await Sha256().hash(signPub)).bytes;
    return Base32.encode(h).toLowerCase().substring(0, 16);
  }

  static Future<DeviceKeys> fromSeeds(
    List<int> signSeed,
    List<int> agreeSeed,
  ) async {
    final signPair = await Ed25519().newKeyPairFromSeed(signSeed);
    final signPub = (await signPair.extractPublicKey()).bytes;
    final agreePair = await X25519().newKeyPairFromSeed(agreeSeed);
    final agreePub = (await agreePair.extractPublicKey()).bytes;
    final h = (await Sha256().hash(signPub)).bytes;
    final deviceId = Base32.encode(h).toLowerCase().substring(0, 16);
    final hex = Ids.hex(h);
    final fingerprint =
        '${hex.substring(0, 4)} ${hex.substring(4, 8)} ${hex.substring(8, 12)}';
    return DeviceKeys._(
      signSeed: signSeed,
      signPub: signPub,
      agreeSeed: agreeSeed,
      agreePub: agreePub,
      deviceId: deviceId,
      fingerprint: fingerprint,
    );
  }
}
