import 'dart:async';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/ops/op_applier.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/sync/drift_validation_view.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/core/util/json_util.dart';

/// Thrown inside a local write transaction when validation refuses a change.
class ChangeRejected implements Exception {
  const ChangeRejected(this.reason);

  final String reason;
}

class PendingOp {
  const PendingOp.set(this.tbl, this.id, this.field, this.value)
    : kind = 'set',
      delta = null;

  const PendingOp.inc(this.tbl, this.id, this.field, this.delta)
    : kind = 'inc',
      value = null;

  final String tbl;
  final String id;
  final String kind;
  final String field;
  final Object? value;
  final int? delta;
}

class ChangeBuilder {
  final List<PendingOp> ops = [];

  String create(String tbl, Map<String, Object?> fields, {String? id}) {
    final newId = id ?? Ids.newId();
    set(tbl, newId, 'deleted', false);
    for (final entry in fields.entries) {
      set(tbl, newId, entry.key, entry.value);
    }
    return newId;
  }

  void set(String tbl, String id, String field, Object? value) =>
      ops.add(PendingOp.set(tbl, id, field, value));

  void setAll(String tbl, String id, Map<String, Object?> fields) {
    for (final entry in fields.entries) {
      set(tbl, id, entry.key, entry.value);
    }
  }

  void inc(String tbl, String id, String field, int delta) =>
      ops.add(PendingOp.inc(tbl, id, field, delta));

  void delete(String tbl, String id) => set(tbl, id, 'deleted', true);
}

class ChangeWriter {
  ChangeWriter(
    this.db,
    this.registry,
    this.hlc,
    this.prefs, {
    this._validator,
    this._signer,
    this._clock,
    this._onRejected,
  }) : _applier = OpApplier(db, registry);

  final NestDatabase db;
  final CollectionRegistry registry;
  final HlcClock hlc;
  final DevicePrefs prefs;
  final Validator? _validator;
  final OpSigner? _signer;
  final Clock? _clock;
  final void Function(String reason)? _onRejected;
  final OpApplier _applier;
  final StreamController<void> _changed = StreamController<void>.broadcast();

  /// Fires after every locally accepted change (not when rejected).
  Stream<void> get changed => _changed.stream;

  Future<ChangeResult> write(
    String label,
    void Function(ChangeBuilder c) build, {
    String? homeId,
  }) async {
    final home =
        homeId ?? prefs.currentHomeId ?? (throw StateError('No current home'));
    final member = prefs.memberId ?? prefs.deviceId;
    final builder = ChangeBuilder();
    build(builder);
    final ops = builder.ops;
    if (ops.isEmpty) return ChangeResult(Ids.newId(), null);

    for (final op in ops) {
      registry.check(
        op.tbl,
        op.field,
        op.kind,
        op.kind == 'set' ? op.value : op.delta,
      );
    }

    final changeId = Ids.newId();
    late final List<UndoEntry> inverse;
    late final int nextSeq;
    try {
      await db.transaction(() async {
        inverse = await _inverseOf(ops);
        final state = await _nextSeqAndMaxHlc();
        final maxHlc = state.maxHlc;
        if (maxHlc != null) {
          await hlc.observe(maxHlc);
        }
        var seq = state.seq;
        final recs = <OpRecord>[];
        for (final op in ops) {
          final opHlc = await hlc.next(persist: false);
          recs.add(
            OpRecord(
              opId: '${prefs.deviceId}:$seq',
              homeId: home,
              deviceId: prefs.deviceId,
              seq: seq,
              hlc: opHlc,
              authorMemberId: member,
              changeId: changeId,
              tbl: op.tbl,
              entityId: op.id,
              kind: op.kind,
              field: op.field,
              valueJson: op.kind == 'set' ? encodeValue(op.value) : null,
              delta: op.kind == 'inc' ? op.delta : null,
            ),
          );
          seq++;
        }
        await hlc.flush();

        if (_validator != null) {
          final hasDevices = await db
              .customSelect(
                'SELECT 1 FROM member_devices WHERE home_id = ? LIMIT 1',
                variables: [Variable.withString(home)],
              )
              .getSingleOrNull();
          if (hasDevices != null) {
            final view = DriftValidationView(db, registry);
            final nowMs = (_clock ?? SystemClock()).nowMs;
            for (final rec in recs) {
              final d = await _validator.check(rec, recs, view, nowMs: nowMs);
              if (d.verdict != Verdict.accept) {
                throw ChangeRejected(d.reason);
              }
            }
          }
        }

        final signed = <OpRecord>[];
        for (final rec in recs) {
          signed.add(_signer != null ? await _signer.sign(rec) : rec);
        }
        await _applier.applyLocal(signed);
        nextSeq = seq;
      });
    } on ChangeRejected catch (e) {
      final cb = _onRejected;
      if (cb != null) {
        Timer.run(() => cb(e.reason));
      }
      return ChangeResult(changeId, null);
    }

    await prefs.setNextSeq(nextSeq);
    if (!_changed.isClosed) {
      _changed.add(null);
    }
    return ChangeResult(
      changeId,
      UndoToken(label: label, homeId: home, entries: inverse, runner: undo),
    );
  }

  /// Per-device sequence and the newest HLC in one round trip (both read the
  /// same `ops` rows for this device, so one scan serves both).
  Future<({int seq, String? maxHlc})> _nextSeqAndMaxHlc() async {
    final row = await db
        .customSelect(
          'SELECT COALESCE(MAX(seq), 0) AS m, MAX(hlc) AS h '
          'FROM ops WHERE device_id = ?',
          variables: [Variable.withString(prefs.deviceId)],
        )
        .getSingle();
    return (seq: (row.data['m'] as int) + 1, maxHlc: row.data['h'] as String?);
  }

  /// Reads every row the change touches up front — one `IN` query per distinct
  /// table instead of one query per op (and per set field).
  Future<Map<String, Map<String, Object?>>> _readUndoRows(
    List<PendingOp> ops,
  ) async {
    final byTable = <String, Set<String>>{};
    for (final op in ops) {
      byTable.putIfAbsent(op.tbl, () => <String>{}).add(op.id);
    }
    final out = <String, Map<String, Object?>>{};
    for (final e in byTable.entries) {
      final spec = registry.spec(e.key);
      final t = spec.table.actualTableName;
      final ids = e.value.toList();
      final rows = await db
          .customSelect(
            'SELECT * FROM $t WHERE id IN '
            '(${List.filled(ids.length, '?').join(', ')})',
            variables: [for (final id in ids) Variable.withString(id)],
            readsFrom: {spec.table},
          )
          .get();
      for (final r in rows) {
        out['${e.key}/${r.data['id']}'] = {
          for (final col in r.data.entries)
            col.key: spec.columns.containsKey(col.key)
                ? registry.fromSql(e.key, col.key, col.value)
                : col.value,
        };
      }
    }
    return out;
  }

  Future<List<UndoEntry>> _inverseOf(List<PendingOp> ops) async {
    final entries = <UndoEntry>[];
    final rows = await _readUndoRows(ops);
    final createdRows = <String>{};
    final existingRows = <String>{};
    final setIndex = <String, int>{};

    for (final op in ops) {
      final rowKey = '${op.tbl}/${op.id}';
      if (createdRows.contains(rowKey)) continue;

      if (!existingRows.contains(rowKey)) {
        final row = rows[rowKey];
        if (row == null) {
          createdRows.add(rowKey);
          entries.add(
            UndoEntry(
              tbl: op.tbl,
              id: op.id,
              field: 'deleted',
              kind: 'set',
              value: true,
              guarded: true,
              expected: false,
            ),
          );
          continue;
        }
        existingRows.add(rowKey);
      }

      if (op.kind == 'inc') {
        entries.add(
          UndoEntry(
            tbl: op.tbl,
            id: op.id,
            field: op.field,
            kind: 'inc',
            delta: -(op.delta ?? 0),
          ),
        );
        continue;
      }

      final fieldKey = '${op.tbl}/${op.id}/${op.field}';
      final prevIdx = setIndex[fieldKey];
      if (prevIdx != null) {
        final firstOld = entries[prevIdx].value;
        entries[prevIdx] = UndoEntry(
          tbl: op.tbl,
          id: op.id,
          field: op.field,
          kind: 'set',
          value: firstOld,
          guarded: true,
          expected: op.value,
        );
        continue;
      }

      final oldVal = rows[rowKey]?[op.field];
      setIndex[fieldKey] = entries.length;
      entries.add(
        UndoEntry(
          tbl: op.tbl,
          id: op.id,
          field: op.field,
          kind: 'set',
          value: oldVal,
          guarded: true,
          expected: op.value,
        ),
      );
    }

    return entries.reversed.toList();
  }

  Future<UndoOutcome> undo(UndoToken t) async {
    if (t.used) return const UndoDone();
    final me = prefs.memberId ?? prefs.deviceId;

    for (final e in t.entries) {
      if (!e.guarded) continue;
      final tName = registry.spec(e.tbl).table.actualTableName;
      final row = await db
          .customSelect(
            'SELECT ${e.field} AS v FROM $tName WHERE id = ?',
            variables: [Variable.withString(e.id)],
          )
          .getSingleOrNull();
      final current = row == null
          ? null
          : registry.fromSql(e.tbl, e.field, row.data['v']);
      if (_valuesEqual(current, e.expected)) continue;

      final updaterRow = await db
          .customSelect(
            'SELECT updated_by AS u FROM $tName WHERE id = ?',
            variables: [Variable.withString(e.id)],
          )
          .getSingleOrNull();
      final u = updaterRow?.data['u'] as String?;
      if (u == me) return const UndoConflict(byMe: true);
      if (u != null && registry.has('members')) {
        final memberRow = await db
            .customSelect(
              'SELECT first_name AS n FROM members WHERE id = ?',
              variables: [Variable.withString(u)],
            )
            .getSingleOrNull();
        return UndoConflict(byMe: false, name: memberRow?.data['n'] as String?);
      }
      return const UndoConflict(byMe: false);
    }

    t.used = true;
    await write('Undo: ${t.label}', (c) {
      for (final e in t.entries) {
        if (e.kind == 'inc') {
          c.inc(e.tbl, e.id, e.field, e.delta ?? 0);
        } else {
          c.set(e.tbl, e.id, e.field, e.value);
        }
      }
    }, homeId: t.homeId);
    return const UndoDone();
  }

  bool _valuesEqual(Object? a, Object? b) {
    if (a == b) return true;
    if (a is bool && (b == 0 || b == 1)) return a == (b == 1);
    if (b is bool && (a == 0 || a == 1)) return b == (a == 1);
    if (a is int && b is double) return a.toDouble() == b;
    if (a is double && b is int) return a == b.toDouble();
    return false;
  }
}
