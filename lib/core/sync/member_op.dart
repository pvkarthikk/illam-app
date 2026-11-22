import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/canonical_json.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/crypto/sign.dart';

/// Immutable membership operation in the per-home membership log.
class MemberOp {
  const MemberOp({
    this.opId = '',
    required this.homeId,
    required this.type,
    required this.authorDeviceId,
    required this.hlc,
    this.sig = '',
    this.prev = const [],
    this.payload = const {},
  });

  final String opId;
  final String homeId;
  final String type;
  final String authorDeviceId;
  final String hlc;
  final String sig;
  final List<String> prev;
  final Map<String, Object?> payload;

  MemberOp copyWith({String? opId, String? sig}) => MemberOp(
    opId: opId ?? this.opId,
    homeId: homeId,
    type: type,
    authorDeviceId: authorDeviceId,
    hlc: hlc,
    sig: sig ?? this.sig,
    prev: prev,
    payload: payload,
  );
}

/// Canonical encoding, hashing, signing, and wire conversion for [MemberOp].
abstract final class MemberOpCodec {
  static Map<String, Object?> _bodyMap(MemberOp o) => {
    'v': 1,
    'type': o.type,
    'homeId': o.homeId,
    'author': o.authorDeviceId,
    'hlc': o.hlc,
    'prev': o.prev,
    'payload': o.payload,
  };

  /// UTF-8 canonical JSON body used for hashing and Ed25519 signatures.
  static List<int> body(MemberOp o) => utf8.encode(canonicalJson(_bodyMap(o)));

  /// Hex SHA-256 of `SignDomain.op || 0x00 || body(o)`.
  static Future<String> computeId(MemberOp o) async =>
      toHex(await sha256Of(domainBytes(SignDomain.op, body(o))));

  /// Computes `opId` and signs `body(o)` under [kp] and [SignDomain.op].
  static Future<MemberOp> sign(MemberOp o, SimpleKeyPair kp) async {
    final id = await computeId(o);
    final sig = await Signer.sign(kp, SignDomain.op, body(o));
    return o.copyWith(opId: id, sig: sig);
  }

  /// Verifies [o.sig] under Ed25519 public key [pub] and [SignDomain.op].
  static Future<bool> verify(MemberOp o, List<int> pub) =>
      Signer.verify(pub, SignDomain.op, body(o), o.sig);

  /// Encodes [o] to its wire map (including hint `opId` and `sig`).
  static Map<String, Object?> toWire(MemberOp o) => {
    ..._bodyMap(o),
    'opId': o.opId,
    'sig': o.sig,
  };

  /// Decodes a wire map and recomputes `opId` locally (never trusting sender).
  static Future<MemberOp> fromWire(Map<String, Object?> m) async {
    final prevRaw = m['prev'] as List? ?? const [];
    final payloadRaw = m['payload'] as Map? ?? const {};
    final op = MemberOp(
      homeId: m['homeId'] as String,
      type: m['type'] as String,
      authorDeviceId: m['author'] as String,
      hlc: m['hlc'] as String,
      sig: (m['sig'] as String?) ?? '',
      prev: [for (final p in prevRaw) p as String],
      payload: Map<String, Object?>.from(payloadRaw),
    );
    final id = await computeId(op);
    return op.copyWith(opId: id);
  }
}
