import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/sync/drift_validation_view.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

class IngestReport {
  int applied = 0;
  int already = 0;
  int pending = 0;
  int quarantined = 0;
  final List<String> notes = [];
}

/// Validates, verifies signatures on, gap-orders, and applies incoming ops.
class IncomingPipeline {
  IncomingPipeline({
    required this.db,
    required this.registry,
    required this.applier,
    required this.membership,
    required this.hlc,
    required this.clock,
    this.validator = const Validator(),
    this.onApplied,
    this.afterIngest,
  });

  final NestDatabase db;
  final CollectionRegistry registry;
  final OpApplier applier;
  final MembershipLog membership;
  final HlcClock hlc;
  final Clock clock;
  final Validator validator;
  final void Function(OpRecord op)? onApplied;
  final Future<void> Function()? afterIngest;

  /// Ingests [memberOps] first, then incoming [ops] for [homeId], and retries waiting ops.
  Future<IngestReport> ingest(
    String homeId, {
    List<Map<String, Object?>> memberOps = const [],
    List<Map<String, Object?>> ops = const [],
  }) async {
    final rep = IngestReport();
    if (memberOps.isNotEmpty) {
      await membership.addWireOps(homeId, memberOps);
      await _revokeEnded(homeId);
    }

    final decoded = [
      for (final m in ops)
        if (m['homeId'] == homeId) opFromWire(m),
    ]
      ..sort((a, b) {
        final d = a.deviceId.compareTo(b.deviceId);
        if (d != 0) return d;
        return a.seq.compareTo(b.seq);
      });

    final have = Map<String, int>.from((await SyncStore(db).myVector(homeId)).map);
    final byChange = groupBy(decoded, (o) => o.changeId);
    final view = DriftValidationView(db, registry);
    final newlyPending = <String>{};

    var i = 0;
    while (i < decoded.length) {
      final changeId = decoded[i].changeId;
      var end = i + 1;
      while (end < decoded.length &&
          end - i < 20 &&
          decoded[end].changeId == changeId) {
        end++;
      }
      final run = decoded.sublist(i, end);
      i = end;

      await db.transaction(() async {
        for (final op in run) {
          final existing = await (db.select(
            db.ops,
          )..where((o) => o.opId.equals(op.opId))).getSingleOrNull();
          if (existing != null && existing.status != 'pending') {
            rep.already++;
            continue;
          }

          final expected = (have[op.deviceId] ?? 0) + 1;
          if (op.seq > expected) {
            if (existing == null) {
              final pub = await membership.signPubOf(op.deviceId);
              if (pub != null && !await OpSigner.verify(op, pub)) {
                rep.quarantined++;
                continue;
              }
              await db
                  .into(db.ops)
                  .insert(
                    op.toCompanion().copyWith(status: const Value('pending')),
                    mode: InsertMode.insertOrIgnore,
                  );
              rep.pending++;
              newlyPending.add(op.opId);
            }
            continue;
          }

          final decision = await _decide(op, byChange[op.changeId]!, view);
          if (decision.reason == 'badSignature') {
            rep.quarantined++;
            continue;
          }
          await _store(
            op,
            decision,
            wasPending: existing != null,
            rep: rep,
            newlyPending: newlyPending,
          );
          have[op.deviceId] = max(have[op.deviceId] ?? 0, op.seq);
        }
      });
    }

    await retryPending(homeId, rep, newlyPending: newlyPending);
    if (afterIngest != null) {
      await afterIngest!();
    }
    return rep;
  }

  Future<void> _revokeEnded(String homeId) async {
    final devs =
        await (db.select(db.memberDevices)..where(
              (d) => d.homeId.equals(homeId) & d.endedHlc.isNotNull(),
            ))
            .get();
    if (devs.isEmpty) return;

    final view = DriftValidationView(db, registry);
    for (final dev in devs) {
      final endedHlc = dev.endedHlc;
      if (endedHlc == null || endedHlc.isEmpty) continue;
      final info = await view.memberForDevice(dev.deviceId);
      if (info != null && info.status == 'active') continue;
      final badOps =
          await (db.select(db.ops)..where(
                (o) =>
                    o.homeId.equals(homeId) &
                    o.deviceId.equals(dev.deviceId) &
                    o.status.equals('applied') &
                    o.hlc.isBiggerOrEqualValue(endedHlc) &
                    o.tbl.equals('members').not(),
              ))
              .get();
      if (badOps.isNotEmpty) {
        await applier.revoke(badOps);
      }
    }
  }

  Future<Decision> _decide(
    OpRecord op,
    List<OpRecord> change,
    ValidationView v,
  ) async {
    final pub = await membership.signPubOf(op.deviceId);
    if (pub == null) return const Decision(Verdict.pending, 'unknownDevice');
    if (!await OpSigner.verify(op, pub)) {
      return const Decision(Verdict.quarantine, 'badSignature');
    }
    return validator.check(op, change, v, nowMs: clock.nowMs);
  }

  Future<void> _store(
    OpRecord op,
    Decision d, {
    required bool wasPending,
    required IngestReport rep,
    Set<String>? newlyPending,
  }) async {
    switch (d.verdict) {
      case Verdict.accept:
        await hlc.observe(op.hlc, persist: false);
        await db.transaction(() async {
          if (wasPending) {
            await applier.applyPending(op);
          } else {
            await applier.applyOne(op);
          }
        });
        rep.applied++;
        onApplied?.call(op);

      case Verdict.pending:
        if (!wasPending) {
          await db
              .into(db.ops)
              .insert(
                op.toCompanion().copyWith(status: const Value('pending')),
                mode: InsertMode.insertOrIgnore,
              );
          rep.pending++;
          newlyPending?.add(op.opId);
        }

      case Verdict.quarantine:
        await db
            .into(db.ops)
            .insert(
              op.toCompanion().copyWith(status: const Value('quarantined')),
              mode: InsertMode.insertOrReplace,
            );
        rep.quarantined++;
        rep.notes.add('${op.opId}: ${d.reason}');
    }
  }

  /// Re-evaluates all waiting ops of [homeId] until no more change status.
  Future<void> retryPending(
    String homeId,
    IngestReport rep, {
    Set<String>? newlyPending,
  }) async {
    var changed = true;
    while (changed) {
      changed = false;
      final rows =
          await (db.select(db.ops)
                ..where(
                  (o) => o.homeId.equals(homeId) & o.status.equals('pending'),
                )
                ..orderBy([
                  (o) => OrderingTerm.asc(o.deviceId),
                  (o) => OrderingTerm.asc(o.seq),
                ]))
              .get();
      if (rows.isEmpty) break;

      final have = Map<String, int>.from(
        (await SyncStore(db).myVector(homeId)).map,
      );
      final ops = [for (final r in rows) OpRecord.fromRow(r)];
      final byChange = groupBy(ops, (o) => o.changeId);
      final view = DriftValidationView(db, registry);

      for (final op in ops) {
        if (op.seq > (have[op.deviceId] ?? 0) + 1) continue;
        final d = await _decide(op, byChange[op.changeId]!, view);
        if (d.verdict == Verdict.accept) {
          await _store(op, d, wasPending: true, rep: rep);
          have[op.deviceId] = max(have[op.deviceId] ?? 0, op.seq);
          if ((newlyPending?.remove(op.opId) ?? false) && rep.pending > 0) {
            rep.pending--;
          }
          changed = true;
        } else if (d.verdict == Verdict.quarantine) {
          if (d.reason == 'badSignature') {
            await (db.delete(
              db.ops,
            )..where((o) => o.opId.equals(op.opId))).go();
          } else {
            await (db.update(db.ops)..where((o) => o.opId.equals(op.opId)))
                .write(const OpsCompanion(status: Value('quarantined')));
            have[op.deviceId] = max(have[op.deviceId] ?? 0, op.seq);
            rep.notes.add('${op.opId}: ${d.reason}');
          }
          rep.quarantined++;
          if ((newlyPending?.remove(op.opId) ?? false) && rep.pending > 0) {
            rep.pending--;
          }
          changed = true;
        }
      }
    }
    await hlc.flush();
  }
}
