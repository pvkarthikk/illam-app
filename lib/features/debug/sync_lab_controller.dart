import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:nm_flat/core/crypto/sign.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class SyncCounts {
  const SyncCounts({
    this.applied = 0,
    this.pending = 0,
    this.quarantined = 0,
    this.memApplied = 0,
    this.memIgnored = 0,
    this.memPending = 0,
    this.activeDevices = 0,
  });

  final int applied;
  final int pending;
  final int quarantined;
  final int memApplied;
  final int memIgnored;
  final int memPending;
  final int activeDevices;
}

class MemberLogEntry {
  const MemberLogEntry({required this.op, required this.model});

  final MemberOpRow op;
  final String model;
}

class RecentOpEntry {
  const RecentOpEntry({required this.row, required this.signed});

  final OpRow row;
  final bool signed;
}

class PendingOtherBundle {
  const PendingOtherBundle({
    required this.homeId,
    required this.memberOps,
    required this.ops,
  });

  final String homeId;
  final List<Map<String, Object?>> memberOps;
  final List<Map<String, Object?>> ops;
}

class SyncLabState {
  const SyncLabState({this.otherBundle});

  final PendingOtherBundle? otherBundle;
}

final syncCountsProvider = StreamProvider<SyncCounts>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const SyncCounts());
  final db = ref.watch(dbProvider);
  return db
      .customSelect(
        '''
        SELECT
          (SELECT COUNT(*) FROM ops WHERE home_id = ? AND status = 'applied') AS op_applied,
          (SELECT COUNT(*) FROM ops WHERE home_id = ? AND status = 'pending') AS op_pending,
          (SELECT COUNT(*) FROM ops WHERE home_id = ? AND status = 'quarantined') AS op_quarantined,
          (SELECT COUNT(*) FROM member_ops WHERE home_id = ? AND effect = 'applied') AS mem_applied,
          (SELECT COUNT(*) FROM member_ops WHERE home_id = ? AND effect = 'ignored') AS mem_ignored,
          (SELECT COUNT(*) FROM member_ops WHERE home_id = ? AND effect = 'pending') AS mem_pending,
          (SELECT COUNT(*) FROM member_devices WHERE home_id = ? AND active = 1) AS active_devices
        ''',
        variables: List.filled(7, Variable.withString(home)),
        readsFrom: {db.ops, db.memberOps, db.memberDevices},
      )
      .watchSingle()
      .map(
        (r) => SyncCounts(
          applied: r.data['op_applied'] as int,
          pending: r.data['op_pending'] as int,
          quarantined: r.data['op_quarantined'] as int,
          memApplied: r.data['mem_applied'] as int,
          memIgnored: r.data['mem_ignored'] as int,
          memPending: r.data['mem_pending'] as int,
          activeDevices: r.data['active_devices'] as int,
        ),
      );
});

final syncMemberLogProvider = StreamProvider<List<MemberLogEntry>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <MemberLogEntry>[]);
  final db = ref.watch(dbProvider);
  return (db.select(db.memberOps)
        ..where((t) => t.homeId.equals(home))
        ..orderBy([
          (t) => OrderingTerm.asc(t.hlc),
          (t) => OrderingTerm.asc(t.opId),
        ]))
      .watch()
      .asyncMap((ops) async {
        final devs = await (db.select(
          db.memberDevices,
        )..where((d) => d.homeId.equals(home))).get();
        final models = {for (final d in devs) d.deviceId: d.model};
        return [
          for (final op in ops)
            MemberLogEntry(
              op: op,
              model: _labelForDevice(op.authorDeviceId, models[op.authorDeviceId]),
            ),
        ];
      });
});

final syncRecentOpsProvider = StreamProvider<List<RecentOpEntry>>((ref) {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return Stream.value(const <RecentOpEntry>[]);
  final db = ref.watch(dbProvider);
  final log = ref.watch(membershipLogProvider);
  return (db.select(db.ops)
        ..where((t) => t.homeId.equals(home))
        ..orderBy([
          (t) => OrderingTerm.desc(t.hlc),
          (t) => OrderingTerm.desc(t.seq),
        ])
        ..limit(30))
      .watch()
      .asyncMap((rows) async {
        final out = <RecentOpEntry>[];
        for (final row in rows) {
          var ok = false;
          if (row.sig.isNotEmpty) {
            final pub = await log.signPubOf(row.deviceId);
            if (pub != null) {
              ok = await OpSigner.verify(OpRecord.fromRow(row), pub);
            }
          }
          out.add(RecentOpEntry(row: row, signed: ok));
        }
        return out;
      });
});

String _labelForDevice(String deviceId, String? model) {
  if (model != null && model.isNotEmpty) return model;
  return deviceId.length > 8 ? deviceId.substring(0, 8) : deviceId;
}

final syncLabVectorProvider = FutureProvider<Map<String, int>>((ref) async {
  final home = ref.watch(currentHomeIdProvider).value;
  if (home == null) return const {};
  ref.watch(opsTickProvider);
  final vec = await ref.watch(syncStoreProvider).myVector(home);
  return vec.map;
});

final syncLabControllerProvider =
    AsyncNotifierProvider<SyncLabController, SyncLabState>(
      SyncLabController.new,
    );

class SyncLabController extends AsyncNotifier<SyncLabState> {
  @override
  Future<SyncLabState> build() async => const SyncLabState();

  String? get _homeId =>
      ref.read(currentHomeIdProvider).value ??
      ref.read(prefsProvider).currentHomeId;

  Future<void> verifyAll(AppLocalizations l) async {
    final home = _homeId;
    if (home == null) return;
    final db = ref.read(dbProvider);
    final log = ref.read(membershipLogProvider);
    final rows = await (db.select(
      db.ops,
    )..where((o) => o.homeId.equals(home))).get();

    var ok = 0;
    var bad = 0;
    var unsigned = 0;
    for (final r in rows) {
      if (r.sig.isEmpty) {
        unsigned++;
        continue;
      }
      final pub = await log.signPubOf(r.deviceId);
      if (pub == null) {
        unsigned++;
        continue;
      }
      if (await OpSigner.verify(OpRecord.fromRow(r), pub)) {
        ok++;
      } else {
        bad++;
      }
    }
    ref.read(snackbarProvider).show(l.syncLabVerifyResult(ok, bad, unsigned));
  }

  Future<({String text, int count})?> _buildBundle() async {
    final home = _homeId;
    if (home == null) return null;
    final db = ref.read(dbProvider);
    final log = ref.read(membershipLogProvider);
    final memberOps = await log.allWire(home);
    final opRows =
        await (db.select(db.ops)
              ..where(
                (o) =>
                    o.homeId.equals(home) &
                    o.status.isIn(const ['applied', 'quarantined']),
              )
              ..orderBy([
                (o) => OrderingTerm.asc(o.deviceId),
                (o) => OrderingTerm.asc(o.seq),
              ]))
            .get();
    final ops = [for (final r in opRows) opToWire(OpRecord.fromRow(r))];
    final bundle = {
      'format': 'nestmojo-bundle/v1',
      'homeId': home,
      'memberOps': memberOps,
      'ops': ops,
    };
    final gz = gzip.encode(utf8.encode(jsonEncode(bundle)));
    return (text: 'NMB1:${base64.encode(gz)}', count: ops.length);
  }

  Future<void> exportBundle(AppLocalizations l) async {
    final built = await _buildBundle();
    if (built == null) return;
    await Clipboard.setData(ClipboardData(text: built.text));
    ref.read(snackbarProvider).show(l.syncLabExported(built.count));
  }

  Future<void> shareBundle() async {
    final built = await _buildBundle();
    if (built == null) return;
    await SharePlus.instance.share(ShareParams(text: built.text));
  }

  Future<void> importFromClipboard(AppLocalizations l) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text?.trim() ?? '';
    final parsed = _decodeBundle(raw);
    if (parsed == null) {
      ref.read(snackbarProvider).show(l.syncLabBadBundle);
      return;
    }

    final current = _homeId;
    if (current != parsed.homeId) {
      state = AsyncData(SyncLabState(otherBundle: parsed));
      ref.read(snackbarProvider).show(l.syncLabOtherHome);
      return;
    }

    state = const AsyncData(SyncLabState());
    final rep = await ref
        .read(incomingProvider)
        .ingest(current!, memberOps: parsed.memberOps, ops: parsed.ops);
    ref
        .read(snackbarProvider)
        .show(
          l.syncLabImportResult(
            rep.applied,
            rep.already,
            rep.pending,
            rep.quarantined,
          ),
        );
  }

  PendingOtherBundle? _decodeBundle(String raw) {
    if (!raw.startsWith('NMB1:')) return null;
    try {
      final gz = base64.decode(raw.substring(5));
      final jsonStr = utf8.decode(gzip.decode(gz));
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, Object?>) return null;
      if (decoded['format'] != 'nestmojo-bundle/v1') return null;
      final homeId = decoded['homeId'];
      if (homeId is! String || homeId.isEmpty) return null;
      final memRaw = decoded['memberOps'] as List? ?? const [];
      final opsRaw = decoded['ops'] as List? ?? const [];
      return PendingOtherBundle(
        homeId: homeId,
        memberOps: [
          for (final m in memRaw) Map<String, Object?>.from(m as Map),
        ],
        ops: [for (final o in opsRaw) Map<String, Object?>.from(o as Map)],
      );
    } on Object {
      return null;
    }
  }

  Future<void> replaceHomeWithPendingBundle(AppLocalizations l) async {
    final bundle = state.value?.otherBundle;
    if (bundle == null) return;
    state = const AsyncData(SyncLabState());
    await ref.read(dbProvider).wipeAll();
    await ref.read(prefsProvider).setCurrentHomeId(bundle.homeId);
    final rep = await ref
        .read(incomingProvider)
        .ingest(bundle.homeId, memberOps: bundle.memberOps, ops: bundle.ops);
    ref
        .read(snackbarProvider)
        .show(
          l.syncLabImportResult(
            rep.applied,
            rep.already,
            rep.pending,
            rep.quarantined,
          ),
        );
  }

  Future<void> tamperTest(AppLocalizations l) async {
    final home = _homeId;
    if (home == null) return;
    final db = ref.read(dbProvider);
    final newest =
        await (db.select(db.ops)
              ..where((o) => o.homeId.equals(home) & o.status.equals('applied'))
              ..orderBy([
                (o) => OrderingTerm.desc(o.hlc),
                (o) => OrderingTerm.desc(o.seq),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (newest == null) return;

    final arjun = await MembershipLog.demoKeys('demo-arjun');
    final base = OpRecord.fromRow(newest);
    final seq = 900000 + Random().nextInt(99999);
    final tampered = OpRecord(
      opId: '${arjun.deviceId}:$seq',
      homeId: home,
      deviceId: arjun.deviceId,
      seq: seq,
      hlc: base.hlc,
      authorMemberId: 'demo-arjun',
      changeId: base.changeId,
      tbl: base.tbl,
      entityId: base.entityId,
      kind: base.kind,
      field: base.field,
      valueJson: '"TAMPERED"',
      delta: base.delta,
      sig: base.sig,
    );
    final rep = await ref
        .read(incomingProvider)
        .ingest(home, ops: [opToWire(tampered)]);
    ref
        .read(snackbarProvider)
        .show(
          l.syncLabImportResult(
            rep.applied,
            rep.already,
            rep.pending,
            rep.quarantined,
          ),
        );
  }

  Future<void> _ingestAsArjun({
    required AppLocalizations l,
    required String tbl,
    required String entityId,
    required String field,
    required String valueJson,
  }) async {
    final home = _homeId;
    if (home == null) return;
    final db = ref.read(dbProvider);
    final arjun = await MembershipLog.demoKeys('demo-arjun');
    final maxRow = await db
        .customSelect(
          'SELECT COALESCE(MAX(seq), 0) AS m FROM ops WHERE device_id = ?',
          variables: [Variable.withString(arjun.deviceId)],
        )
        .getSingle();
    final seq = (maxRow.data['m'] as int) + 1;
    final hlc = await ref.read(hlcProvider).next();

    final unsigned = OpRecord(
      opId: '${arjun.deviceId}:$seq',
      homeId: home,
      deviceId: arjun.deviceId,
      seq: seq,
      hlc: hlc,
      authorMemberId: 'demo-arjun',
      changeId: Ids.newId(),
      tbl: tbl,
      entityId: entityId,
      kind: 'set',
      field: field,
      valueJson: valueJson,
    );
    final sig = await Signer.sign(
      await arjun.signKeyPair(),
      SignDomain.env,
      opSigningBytes(unsigned),
    );
    final signed = unsigned.copyWith(sig: sig);
    final rep = await ref
        .read(incomingProvider)
        .ingest(home, ops: [opToWire(signed)]);
    ref
        .read(snackbarProvider)
        .show(
          l.syncLabImportResult(
            rep.applied,
            rep.already,
            rep.pending,
            rep.quarantined,
          ),
        );
  }

  Future<void> asArjunTick(AppLocalizations l) async {
    final home = _homeId;
    if (home == null) return;
    final db = ref.read(dbProvider);
    final item =
        await (db.select(db.items)
              ..where(
                (i) =>
                    i.homeId.equals(home) &
                    i.deleted.equals(false) &
                    i.done.equals(false) &
                    i.list.equals('grocery'),
              )
              ..limit(1))
            .getSingleOrNull();
    if (item == null) return;
    await _ingestAsArjun(
      l: l,
      tbl: 'items',
      entityId: item.id,
      field: 'done',
      valueJson: 'true',
    );
  }

  Future<void> asArjunRename(AppLocalizations l) async {
    final home = _homeId;
    if (home == null) return;
    await _ingestAsArjun(
      l: l,
      tbl: 'homes',
      entityId: home,
      field: 'name',
      valueJson: '"Arjun Home"',
    );
  }

  Future<void> connectLocal(int port) async {
    await ref.read(syncEngineProvider).dialForDebug('127.0.0.1', port);
  }

  Future<void> syncNow(AppLocalizations l) async {
    final n = await ref.read(syncEngineProvider).syncNow();
    ref.read(snackbarProvider).show(n > 0 ? l.syncedSnack : l.syncNoPeers);
  }
}
