import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/sync/drift_validation_view.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
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

/// Validates, verifies signatures on, and applies or quarantines incoming ops.
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
  });

  final NestDatabase db;
  final CollectionRegistry registry;
  final OpApplier applier;
  final MembershipLog membership;
  final HlcClock hlc;
  final Clock clock;
  final Validator validator;
  final void Function(OpRecord op)? onApplied;

  /// Ingests [memberOps] first, then incoming [ops] for [homeId], and retries waiting ops.
  Future<IngestReport> ingest(
    String homeId, {
    List<Map<String, Object?>> memberOps = const [],
    List<Map<String, Object?>> ops = const [],
  }) async {
    final rep = IngestReport();
    if (memberOps.isNotEmpty) {
      await membership.addWireOps(homeId, memberOps);
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

    final byChange = groupBy(decoded, (o) => o.changeId);
    final view = DriftValidationView(db, registry);
    final newlyPending = <String>{};

    for (final op in decoded) {
      final existing = await (db.select(
        db.ops,
      )..where((o) => o.opId.equals(op.opId))).getSingleOrNull();
      if (existing != null && existing.status != 'pending') {
        rep.already++;
        continue;
      }
      final decision = await _decide(op, byChange[op.changeId]!, view);
      await _store(
        op,
        decision,
        wasPending: existing != null,
        rep: rep,
        newlyPending: newlyPending,
      );
    }

    await retryPending(homeId, rep, newlyPending: newlyPending);
    return rep;
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
        await hlc.observe(op.hlc);
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

      final ops = [for (final r in rows) OpRecord.fromRow(r)];
      final byChange = groupBy(ops, (o) => o.changeId);
      final view = DriftValidationView(db, registry);

      for (final op in ops) {
        final d = await _decide(op, byChange[op.changeId]!, view);
        if (d.verdict == Verdict.accept) {
          await _store(op, d, wasPending: true, rep: rep);
          if ((newlyPending?.remove(op.opId) ?? false) && rep.pending > 0) {
            rep.pending--;
          }
          changed = true;
        } else if (d.verdict == Verdict.quarantine) {
          await (db.update(db.ops)..where((o) => o.opId.equals(op.opId)))
              .write(const OpsCompanion(status: Value('quarantined')));
          rep.quarantined++;
          rep.notes.add('${op.opId}: ${d.reason}');
          if ((newlyPending?.remove(op.opId) ?? false) && rep.pending > 0) {
            rep.pending--;
          }
          changed = true;
        }
      }
    }
  }
}
