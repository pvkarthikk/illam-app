import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Derives [length] bytes using HKDF-SHA-256.
Future<Uint8List> hkdfSha256({
  required List<int> ikm,
  List<int> salt = const [],
  List<int> info = const [],
  int length = 32,
}) async {
  final kdf = Hkdf(hmac: Hmac.sha256(), outputLength: length);
  final key = await kdf.deriveKey(
    secretKey: SecretKey(ikm),
    nonce: salt,
    info: info,
  );
  return Uint8List.fromList(await key.extractBytes());
}

/// Computes an HMAC-SHA-256 tag of [data] under [key].
Future<Uint8List> hmacSha256(List<int> key, List<int> data) async {
  final mac = await Hmac.sha256().calculateMac(
    data,
    secretKey: SecretKey(key),
  );
  return Uint8List.fromList(mac.bytes);
}

/// Computes the SHA-256 digest of [data].
Future<Uint8List> sha256Of(List<int> data) async {
  final digest = await Sha256().hash(data);
  return Uint8List.fromList(digest.bytes);
}
