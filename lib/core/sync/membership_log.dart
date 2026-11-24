import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:nm_flat/core/backup/recovery_kits.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/sync/member_op.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/util/device_model.dart';

class AppendResult {
  const AppendResult(this.opId, this.effect, this.reason);

  final String opId;
  final String effect;
  final String? reason;
}

/// Manages per-home signed membership ops and replays them into `member_devices` and `members`.
class MembershipLog {
  MembershipLog(
    this.db,
    this.keys,
    this.hlc,
    this.clock, {
    Future<String> Function()? modelOf,
  }) : _modelOf = modelOf ?? deviceModel;

  final NestDatabase db;
  final Future<DeviceKeys> keys;
  final HlcClock hlc;
  final Clock clock;
  final Future<String> Function() _modelOf;

  void Function()? onAppended;
  void Function(String memberId, String name)? onMemberJoined;
  Future<void> Function(ReplayResult result)? onReplayed;
  String? lastReplayedHomeId;

  MemberOp _fromRow(MemberOpRow r) => MemberOp(
    opId: r.opId,
    homeId: r.homeId,
    type: r.opType,
    authorDeviceId: r.authorDeviceId,
    hlc: r.hlc,
    sig: r.sig,
    prev: [for (final p in jsonDecode(r.prevJson) as List) p as String],
    payload: Map<String, Object?>.from(jsonDecode(r.payloadJson) as Map),
  );

  /// Imports wire membership ops for [homeId], verifies signatures, and replays state.
  Future<int> addWireOps(
    String homeId,
    List<Map<String, Object?>> wire,
  ) async {
    var inserted = 0;
    final added = <MemberOp>[];
    for (final w in wire) {
      final op = await MemberOpCodec.fromWire(w);
      if (op.homeId != homeId) continue;
      if (op.type == 'genesis') {
        final gj = op.payload['genesisJson'] as String?;
        if (gj == null || await HomeIds.fromGenesis(gj) != homeId) continue;
      }
      final existing = await (db.select(
        db.memberOps,
      )..where((t) => t.opId.equals(op.opId))).getSingleOrNull();
      if (existing != null) continue;

      await db
          .into(db.memberOps)
          .insert(
            MemberOpsCompanion.insert(
              opId: op.opId,
              homeId: op.homeId,
              opType: op.type,
              authorDeviceId: op.authorDeviceId,
              hlc: op.hlc,
              prevJson: Value(jsonEncode(op.prev)),
              payloadJson: Value(jsonEncode(op.payload)),
              sig: op.sig,
              sigOk: const Value(null),
              effect: const Value('pending'),
              reason: const Value(null),
              receivedAt: Value(clock.nowMs),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      inserted++;
      added.add(op);
    }
    await _verifyUnknown(homeId);
    await (db.delete(db.memberOps)
          ..where((t) => t.homeId.equals(homeId) & t.sigOk.equals(false)))
        .go();
    for (final op in added) {
      final row = await (db.select(
        db.memberOps,
      )..where((t) => t.opId.equals(op.opId))).getSingleOrNull();
      if (row != null &&
          row.sigOk == true &&
          Hlc.parse(op.hlc).wall <= clock.nowMs + 300000) {
        await hlc.observe(op.hlc);
      }
    }
    await replayAndProject(homeId);
    return inserted;
  }

  Future<void> _verifyUnknown(String homeId) async {
    var changed = true;
    while (changed) {
      changed = false;
      final rows = await (db.select(
        db.memberOps,
      )..where((t) => t.homeId.equals(homeId))).get();

      final known = <String, String>{};
      for (final r in rows) {
        if (r.sigOk != true) continue;
        final payload = jsonDecode(r.payloadJson) as Map<String, Object?>;
        if (r.opType == 'genesis') {
          final gj = payload['genesisJson'] as String?;
          if (gj != null) {
            final g = jsonDecode(gj) as Map<String, Object?>;
            final key = g['signPub'] as String?;
            if (key != null) known[r.authorDeviceId] = key;
          }
        } else if (r.opType == 'addMember' || r.opType == 'recover') {
          final dev = payload['device'] as Map?;
          final devId = dev?['deviceId'] as String?;
          final key = dev?['signPub'] as String?;
          if (devId != null && key != null) known[devId] = key;
        }
      }

      for (final r in rows) {
        if (r.sigOk != null) continue;
        final op = _fromRow(r);
        if (r.opType == 'recover') {
          final dev = op.payload['device'] as Map?;
          final key = dev?['signPub'] as String?;
          if (key == null) continue;
          bool okOp;
          try {
            okOp = await MemberOpCodec.verify(op, decodeKey(key));
          } on Object {
            okOp = false;
          }
          final okRec = okOp && await verifyRecover(op.payload);
          await (db.update(db.memberOps)..where((t) => t.opId.equals(r.opId)))
              .write(MemberOpsCompanion(sigOk: Value(okRec)));
          changed = true;
          continue;
        }
        String? key;
        if (r.opType == 'genesis') {
          final payload = jsonDecode(r.payloadJson) as Map<String, Object?>;
          final gj = payload['genesisJson'] as String?;
          if (gj != null) {
            final g = jsonDecode(gj) as Map<String, Object?>;
            key = g['signPub'] as String?;
          }
        } else {
          key = known[r.authorDeviceId];
        }
        if (key == null) continue;

        bool ok;
        try {
          ok = await MemberOpCodec.verify(op, decodeKey(key));
        } on Object {
          ok = false;
        }
        await (db.update(db.memberOps)..where((t) => t.opId.equals(r.opId)))
            .write(MemberOpsCompanion(sigOk: Value(ok)));
        changed = true;
      }
    }
  }

  /// Signs and appends a new membership op for [homeId], then replays state.
  Future<AppendResult> append(
    String homeId,
    String type,
    Map<String, Object?> payload,
  ) async {
    final k = await keys;
    final rows = await (db.select(
      db.memberOps,
    )..where((t) => t.homeId.equals(homeId))).get();

    final referenced = <String>{};
    for (final r in rows) {
      if (r.sigOk != true) continue;
      for (final p in jsonDecode(r.prevJson) as List) {
        referenced.add(p as String);
      }
    }
    final h = await hlc.next();
    final prev = [
      for (final r in rows)
        if (r.sigOk == true &&
            !referenced.contains(r.opId) &&
            r.hlc.compareTo(h) < 0)
          r.opId,
    ]..sort();

    final unsigned = MemberOp(
      homeId: homeId,
      type: type,
      authorDeviceId: k.deviceId,
      hlc: h,
      prev: prev,
      payload: payload,
    );
    final signed = await MemberOpCodec.sign(unsigned, await k.signKeyPair());

    await db
        .into(db.memberOps)
        .insert(
          MemberOpsCompanion.insert(
            opId: signed.opId,
            homeId: signed.homeId,
            opType: signed.type,
            authorDeviceId: signed.authorDeviceId,
            hlc: signed.hlc,
            prevJson: Value(jsonEncode(signed.prev)),
            payloadJson: Value(jsonEncode(signed.payload)),
            sig: signed.sig,
            sigOk: const Value(true),
            effect: const Value('pending'),
            reason: const Value(null),
            receivedAt: Value(clock.nowMs),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    final r = await replayAndProject(homeId);
    onAppended?.call();
    final e = r.effects[signed.opId] ?? 'pending';
    final idx = e.indexOf(':');
    if (idx < 0) return AppendResult(signed.opId, e, null);
    return AppendResult(
      signed.opId,
      e.substring(0, idx),
      e.substring(idx + 1),
    );
  }

  /// Replays verified membership ops for [homeId] and projects devices and members.
  Future<ReplayResult> replayAndProject(String homeId) async {
    final rows = await (db.select(
      db.memberOps,
    )..where((t) => t.homeId.equals(homeId) & t.sigOk.equals(true))).get();
    final oldEffects = <String, String>{
      for (final row in rows)
        if (row.opType == 'addMember') row.opId: row.effect,
    };
    final ops = [for (final r in rows) _fromRow(r)];
    final r = replayMembership(ops);

    await db.transaction(() async {
      for (final entry in r.effects.entries) {
        final raw = entry.value;
        final idx = raw.indexOf(':');
        final effect = idx < 0 ? raw : raw.substring(0, idx);
        final reason = idx < 0 ? null : raw.substring(idx + 1);
        await (db.update(
          db.memberOps,
        )..where((t) => t.opId.equals(entry.key))).write(
          MemberOpsCompanion(effect: Value(effect), reason: Value(reason)),
        );
      }

      await (db.delete(
        db.memberDevices,
      )..where((t) => t.homeId.equals(homeId))).go();

      for (final d in r.devices.values) {
        await db
            .into(db.memberDevices)
            .insert(
              MemberDevicesCompanion.insert(
                deviceId: d.deviceId,
                homeId: homeId,
                memberId: d.memberId,
                signPub: d.signPub,
                agreePub: Value(d.agreePub),
                model: Value(d.model),
                addedAt: Value(d.addedAt),
                active: Value(d.active),
                endedHlc: Value(d.endedHlc),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final m in r.members.values) {
        await db.customInsert(
          'INSERT OR IGNORE INTO members '
          '(id, home_id, created_at, created_by, updated_at, updated_by) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          variables: [
            Variable.withString(m.memberId),
            Variable.withString(homeId),
            Variable.withInt(m.joinedAt),
            Variable.withString(m.invitedBy ?? m.memberId),
            Variable.withInt(m.joinedAt),
            Variable.withString(m.memberId),
          ],
          updates: {db.members},
        );
        await db.customUpdate(
          '''
          UPDATE members
          SET role = ?,
              status = ?,
              joined_at = ?,
              joined_via = ?,
              invited_by = ?,
              full_name = CASE WHEN full_name IS NULL OR full_name = '' THEN ? ELSE full_name END,
              first_name = CASE WHEN first_name IS NULL OR first_name = '' THEN ? ELSE first_name END,
              color = CASE WHEN color IS NULL OR color = '' THEN ? ELSE color END,
              device_model = CASE WHEN device_model IS NULL OR device_model = '' THEN ? ELSE device_model END
          WHERE id = ?
          ''',
          variables: [
            Variable.withString(m.role),
            Variable.withString(m.status),
            Variable.withInt(m.joinedAt),
            Variable.withString(m.joinedVia),
            Variable<String>(m.invitedBy),
            Variable.withString(m.name),
            Variable.withString(Names.firstName(m.name)),
            Variable.withString(m.color),
            Variable.withString(m.model),
            Variable.withString(m.memberId),
          ],
          updates: {db.members},
          updateKind: UpdateKind.update,
        );
      }
    });

    final joinedCb = onMemberJoined;
    if (joinedCb != null) {
      final myId = (await keys).deviceId;
      for (final op in ops) {
        if (op.type != 'addMember' || op.authorDeviceId == myId) continue;
        if (r.effects[op.opId] == 'applied' &&
            oldEffects[op.opId] != 'applied') {
          final memberId = op.payload['memberId'] as String?;
          final name = (op.payload['name'] as String?) ?? '';
          if (memberId != null) {
            joinedCb(memberId, name);
          }
        }
      }
    }

    lastReplayedHomeId = homeId;
    final replayedCb = onReplayed;
    if (replayedCb != null) {
      try {
        await replayedCb(r);
      } on Object catch (e) {
        debugPrint('onReplayed failed: $e');
      }
    }

    return r;
  }

  /// Computes replay state from verified membership ops for [homeId] without mutating DB projection.
  Future<ReplayResult> replayState(String homeId) async {
    final rows = await (db.select(
      db.memberOps,
    )..where((t) => t.homeId.equals(homeId) & t.sigOk.equals(true))).get();
    return replayMembership([for (final r in rows) _fromRow(r)]);
  }

  /// Returns stored `recover` membership ops for [homeId] whose effect is `'applied'`.
  Future<List<MemberOp>> effectiveRecovers(String homeId) async {
    final rows =
        await (db.select(db.memberOps)
              ..where(
                (t) =>
                    t.homeId.equals(homeId) &
                    t.opType.equals('recover') &
                    t.effect.equals('applied'),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.hlc),
                (t) => OrderingTerm.desc(t.opId),
              ]))
            .get();
    return [for (final r in rows) _fromRow(r)];
  }

  /// Returns wire map for a single stored [opId], if present.
  Future<Map<String, Object?>?> wireForOp(String opId) async {
    final row = await (db.select(
      db.memberOps,
    )..where((t) => t.opId.equals(opId))).getSingleOrNull();
    return row == null ? null : MemberOpCodec.toWire(_fromRow(row));
  }

  /// Appends a signed `genesis` op if this creator phone does not yet have one for [homeId].
  Future<void> ensureGenesis(String homeId, String? genesisJson) async {
    if (genesisJson == null || genesisJson.isEmpty) return;
    final k = await keys;
    final existing = await (db.select(db.memberOps)
          ..where((t) => t.homeId.equals(homeId) & t.opType.equals('genesis')))
        .getSingleOrNull();
    if (existing != null) return;

    final g = jsonDecode(genesisJson) as Map<String, Object?>;
    if (g['creatorDeviceId'] != k.deviceId) return;

    await append(homeId, 'genesis', {
      'genesisJson': genesisJson,
      'agreePub': b64(k.agreePub),
      'model': await _modelOf(),
    });
  }

  /// Looks up the Ed25519 public key bytes for [deviceId] from `member_devices`.
  Future<List<int>?> signPubOf(String deviceId) async {
    final row = await (db.select(
      db.memberDevices,
    )..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();
    if (row == null) return null;
    return decodeKey(row.signPub);
  }

  /// Returns wire maps for every membership op of [homeId], ordered by `(hlc, op_id)`.
  Future<List<Map<String, Object?>>> allWire(String homeId) async {
    final rows =
        await (db.select(db.memberOps)
              ..where((t) => t.homeId.equals(homeId) & t.sigOk.equals(true))
              ..orderBy([
                (t) => OrderingTerm.asc(t.hlc),
                (t) => OrderingTerm.asc(t.opId),
              ]))
            .get();
    return [for (final r in rows) MemberOpCodec.toWire(_fromRow(r))];
  }

  /// Deterministic debug-only device keys derived from [seed].
  static Future<DeviceKeys> demoKeys(String seed) async {
    final signSeed = await sha256Of(utf8.encode(seed));
    final agreeSeed = await sha256Of(utf8.encode('$seed/x'));
    return DeviceKeys.fromSeeds(signSeed, agreeSeed);
  }

  /// Appends an `addMember` op for a deterministic debug demo member.
  Future<void> addDemoMember({
    required String homeId,
    required String memberId,
    required String fullName,
    required String color,
    required String role,
    required String model,
    required String via,
    required String seed,
  }) async {
    final d = await demoKeys(seed);
    await append(homeId, 'addMember', {
      'memberId': memberId,
      'name': fullName,
      'color': color,
      'role': role,
      'via': via,
      'device': {
        'deviceId': d.deviceId,
        'signPub': b64(d.signPub),
        'agreePub': b64(d.agreePub),
        'model': model,
      },
    });
  }
}
