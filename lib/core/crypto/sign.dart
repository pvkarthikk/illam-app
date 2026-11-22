import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/crypto/bytes.dart';

/// Signature domain separation constants.
abstract final class SignDomain {
  static const env = 'nestmojo/env/v1';
  static const op = 'nestmojo/op/v1';
  static const auth = 'nestmojo/auth/v1';
  static const join = 'nestmojo/join/v1';
}

/// Returns `utf8(domain) || 0x00 || body` for domain-separated signing/hashing.
Uint8List domainBytes(String domain, List<int> body) =>
    concatBytes([utf8.encode(domain), const [0], body]);

/// Ed25519 domain-separated signer and verifier.
abstract final class Signer {
  static final _ed = Ed25519();

  /// Signs `domainBytes(domain, body)` with [kp] and returns standard base64.
  static Future<String> sign(
    SimpleKeyPair kp,
    String domain,
    List<int> body,
  ) async {
    final sig = await _ed.sign(domainBytes(domain, body), keyPair: kp);
    return b64(sig.bytes);
  }

  /// Verifies [sig] over `domainBytes(domain, body)` under Ed25519 [pub].
  static Future<bool> verify(
    List<int> pub,
    String domain,
    List<int> body,
    String sig,
  ) async {
    if (sig.isEmpty || pub.length != 32) return false;
    try {
      final sigBytes = unb64(sig);
      return await _ed.verify(
        domainBytes(domain, body),
        signature: Signature(
          sigBytes,
          publicKey: SimplePublicKey(pub, type: KeyPairType.ed25519),
        ),
      );
    } on Object {
      return false;
    }
  }
}
