import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/canonical_json.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';

class OpRecord {
  const OpRecord({
    required this.opId,
    required this.homeId,
    required this.deviceId,
    required this.seq,
    required this.hlc,
    required this.authorMemberId,
    required this.changeId,
    required this.tbl,
    required this.entityId,
    required this.kind,
    required this.field,
    this.valueJson,
    this.delta,
    this.sig = '',
  });

  factory OpRecord.fromRow(OpRow r) => OpRecord(
    opId: r.opId,
    homeId: r.homeId,
    deviceId: r.deviceId,
    seq: r.seq,
    hlc: r.hlc,
    authorMemberId: r.authorMemberId,
    changeId: r.changeId,
    tbl: r.tbl,
    entityId: r.entityId,
    kind: r.kind,
    field: r.field,
    valueJson: r.valueJson,
    delta: r.delta,
    sig: r.sig,
  );

  factory OpRecord.fromJson(Map<String, Object?> j) => OpRecord(
    opId: j['opId'] as String,
    homeId: j['homeId'] as String,
    deviceId: j['deviceId'] as String,
    seq: (j['seq'] as num).toInt(),
    hlc: j['hlc'] as String,
    authorMemberId: j['authorMemberId'] as String,
    changeId: j['changeId'] as String,
    tbl: j['tbl'] as String,
    entityId: j['entityId'] as String,
    kind: j['kind'] as String,
    field: j['field'] as String,
    valueJson: j['valueJson'] as String?,
    delta: (j['delta'] as num?)?.toInt(),
    sig: (j['sig'] as String?) ?? '',
  );

  final String opId;
  final String homeId;
  final String deviceId;
  final int seq;
  final String hlc;
  final String authorMemberId;
  final String changeId;
  final String tbl;
  final String entityId;
  final String kind;
  final String field;
  final String? valueJson;
  final int? delta;
  final String sig;

  OpRecord copyWith({String? sig}) => OpRecord(
    opId: opId,
    homeId: homeId,
    deviceId: deviceId,
    seq: seq,
    hlc: hlc,
    authorMemberId: authorMemberId,
    changeId: changeId,
    tbl: tbl,
    entityId: entityId,
    kind: kind,
    field: field,
    valueJson: valueJson,
    delta: delta,
    sig: sig ?? this.sig,
  );

  String toCanonicalJson() => canonicalJson(opSigningMap(this));

  OpsCompanion toCompanion() => OpsCompanion.insert(
    opId: opId,
    homeId: homeId,
    deviceId: deviceId,
    seq: seq,
    hlc: hlc,
    authorMemberId: authorMemberId,
    changeId: changeId,
    tbl: tbl,
    entityId: entityId,
    kind: kind,
    field: field,
    valueJson: Value(valueJson),
    delta: Value(delta),
    sig: Value(sig),
  );

  Map<String, Object?> toJson() => {
    'opId': opId,
    'homeId': homeId,
    'deviceId': deviceId,
    'seq': seq,
    'hlc': hlc,
    'authorMemberId': authorMemberId,
    'changeId': changeId,
    'tbl': tbl,
    'entityId': entityId,
    'kind': kind,
    'field': field,
    'valueJson': valueJson,
    'delta': delta,
    'sig': sig,
  };
}
