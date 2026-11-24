import 'dart:convert';

import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/sign.dart';
import 'package:nm_flat/core/crypto/sign_worker.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';

/// The 14-field canonical map included in every op signature.
Map<String, Object?> opSigningMap(OpRecord o) => {
  'v': 1,
  'opId': o.opId,
  'homeId': o.homeId,
  'deviceId': o.deviceId,
  'seq': o.seq,
  'hlc': o.hlc,
  'author': o.authorMemberId,
  'changeId': o.changeId,
  'tbl': o.tbl,
  'entityId': o.entityId,
  'kind': o.kind,
  'field': o.field,
  'value': o.valueJson,
  'delta': o.delta,
};

/// UTF-8 encoded canonical JSON bytes of [opSigningMap].
List<int> opSigningBytes(OpRecord o) => utf8.encode(o.toCanonicalJson());

/// Serializes [o] to its sync wire representation (including `sig`).
Map<String, Object?> opToWire(OpRecord o) => {...opSigningMap(o), 'sig': o.sig};

/// Parses a sync wire map [m] back into an [OpRecord].
OpRecord opFromWire(Map<String, Object?> m) => OpRecord(
  opId: m['opId'] as String,
  homeId: m['homeId'] as String,
  deviceId: m['deviceId'] as String,
  seq: (m['seq'] as num).toInt(),
  hlc: m['hlc'] as String,
  authorMemberId: m['author'] as String,
  changeId: m['changeId'] as String,
  tbl: m['tbl'] as String,
  entityId: m['entityId'] as String,
  kind: m['kind'] as String,
  field: m['field'] as String,
  valueJson: m['value'] as String?,
  delta: (m['delta'] as num?)?.toInt(),
  sig: (m['sig'] as String?) ?? '',
);

/// Signs and verifies [OpRecord]s under [SignDomain.env].
class OpSigner {
  const OpSigner(this._keys, {this.worker});

  final Future<DeviceKeys> _keys;
  final SignWorker? worker;

  /// Returns a copy of [o] signed by the current device's signing key pair.
  Future<OpRecord> sign(OpRecord o) async {
    final k = await _keys;
    final kp = await k.signKeyPair();
    final sig = await Signer.sign(kp, SignDomain.env, opSigningBytes(o));
    return o.copyWith(sig: sig);
  }

  /// Signs [records] using [worker] when available, falling back to [sign].
  Future<List<OpRecord>> signAll(List<OpRecord> records) async {
    if (records.isEmpty) return const [];
    final w = worker;
    if (w != null) {
      try {
        final sigs = await w.signAll(SignDomain.env, [
          for (final r in records) opSigningBytes(r),
        ]);
        if (sigs.length == records.length) {
          return [
            for (var i = 0; i < records.length; i++)
              records[i].copyWith(sig: sigs[i]),
          ];
        }
      } on Object {
        // Fall through to sequential in-isolate signing on worker failure.
      }
    }
    return [for (final r in records) await sign(r)];
  }

  /// Verifies [o.sig] under Ed25519 public key [pub] and [SignDomain.env].
  static Future<bool> verify(OpRecord o, List<int> pub) =>
      Signer.verify(pub, SignDomain.env, opSigningBytes(o), o.sig);
}
