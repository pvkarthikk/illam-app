import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/backup/recovery_kits.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/home_key_ring.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_eraser.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/protocol/op_wire.dart';
import 'package:nm_flat/core/util/device_model.dart';

/// Complete portable snapshot of one home's membership, keys, and non-quarantined ops.
class Snapshot {
  const Snapshot({
    required this.homeId,
    required this.homeName,
    required this.vaultId,
    required this.createdAt,
    required this.by,
    required this.ops,
    required this.memberOps,
    required this.homeKeys,
    this.recoveryKit,
  });

  factory Snapshot.fromJson(Map<String, Object?> m) {
    try {
      if (m['format'] != 1) {
        throw const BackupFormatException(BackupError.damaged);
      }
      final homeId = m['homeId'];
      final homeName = m['homeName'];
      final vaultId = m['vaultId'];
      final createdAt = m['createdAt'];
      final by = m['by'];
      final ops = m['ops'];
      final memberOps = m['memberOps'];
      final homeKeys = m['homeKeys'];
      final recoveryKit = m['recoveryKit'];

      if (homeId is! String ||
          homeName is! String ||
          vaultId is! String ||
          createdAt is! int ||
          by is! Map ||
          ops is! List ||
          memberOps is! List ||
          homeKeys is! List ||
          (recoveryKit != null && recoveryKit is! Map)) {
        throw const BackupFormatException(BackupError.damaged);
      }

      return Snapshot(
        homeId: homeId,
        homeName: homeName,
        vaultId: vaultId,
        createdAt: createdAt,
        by: Map<String, Object?>.from(by),
        ops: [for (final o in ops) Map<String, Object?>.from(o as Map)],
        memberOps: [
          for (final mo in memberOps) Map<String, Object?>.from(mo as Map),
        ],
        homeKeys: [
          for (final k in homeKeys) Map<String, Object?>.from(k as Map),
        ],
        recoveryKit: recoveryKit == null
            ? null
            : Map<String, Object?>.from(recoveryKit as Map),
      );
    } on BackupFormatException {
      rethrow;
    } on Object {
      throw const BackupFormatException(BackupError.damaged);
    }
  }

  static Snapshot fromBytes(Uint8List b) {
    try {
      final decoded = jsonDecode(utf8.decode(b));
      if (decoded is! Map) {
        throw const BackupFormatException(BackupError.damaged);
      }
      return Snapshot.fromJson(Map<String, Object?>.from(decoded));
    } on BackupFormatException {
      rethrow;
    } on Object {
      throw const BackupFormatException(BackupError.damaged);
    }
  }

  final String homeId;
  final String homeName;
  final String vaultId;
  final int createdAt;
  final Map<String, Object?> by;
  final List<Map<String, Object?>> ops;
  final List<Map<String, Object?>> memberOps;
  final List<Map<String, Object?>> homeKeys;
  final Map<String, Object?>? recoveryKit;

  Map<String, Object?> toJson() => {
    'format': 1,
    'homeId': homeId,
    'homeName': homeName,
    'vaultId': vaultId,
    'createdAt': createdAt,
    'by': by,
    'ops': ops,
    'memberOps': memberOps,
    'homeKeys': homeKeys,
    'recoveryKit': recoveryKit,
  };

  Uint8List toBytes() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));
}

/// Builds a [Snapshot] from local database state, [HomeKeyRing], and [RecoveryKits].
class SnapshotBuilder {
  SnapshotBuilder(
    this.db,
    this.log,
    this.keyRing,
    this.prefs,
    this.keys,
    this.configs,
    this.kits,
  );

  final NestDatabase db;
  final MembershipLog log;
  final HomeKeyRing keyRing;
  final DevicePrefs prefs;
  final Future<DeviceKeys> keys;
  final BackupConfigStore configs;
  final RecoveryKits kits;

  Future<Snapshot> build(
    String homeId, {
    required int createdAt,
    required bool includeKit,
  }) async {
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(homeId))).getSingleOrNull();
    final opRows = await (db.select(
      db.ops,
    )..where((o) => o.homeId.equals(homeId) & o.status.equals('quarantined').not())).get();
    final memberOps = await log.allWire(homeId);
    final ring = await keyRing.all(homeId);
    final k = await keys;
    final myMemberId = prefs.memberId ?? k.deviceId;
    final memberRow = await (db.select(
      db.members,
    )..where((m) => m.id.equals(myMemberId) & m.homeId.equals(homeId)))
        .getSingleOrNull();
    final myName = (memberRow?.firstName != null && memberRow!.firstName!.isNotEmpty)
        ? memberRow.firstName!
        : Names.firstName(memberRow?.fullName ?? '');

    Map<String, Object?>? recKit;
    if (includeKit) {
      final cfg = await configs.load(homeId);
      final kit = cfg.kit;
      if (kit != null && kit['pub'] is String && kit['seed'] is String) {
        recKit = {
          'pub': kit['pub'],
          'seed': kit['seed'],
          'memberId': myMemberId,
          'deviceId': k.deviceId,
        };
      }
    }

    return Snapshot(
      homeId: homeId,
      homeName: home?.name ?? '',
      vaultId: home?.vaultId ?? '',
      createdAt: createdAt,
      by: {
        'deviceId': k.deviceId,
        'memberId': myMemberId,
        'name': myName,
        'model': await deviceModel(),
      },
      ops: [for (final r in opRows) opToWire(OpRecord.fromRow(r))],
      memberOps: memberOps,
      homeKeys: [
        for (final hk in ring.reversed)
          {'keyId': hk.keyId, 'key': base64Encode(hk.bytes)},
      ],
      recoveryKit: recKit,
    );
  }
}

/// Deterministic SHA-256 summary of applied home ops (excluding `backup_status` & `vault_id`) and membership ops.
abstract final class SnapshotHeads {
  static Future<String> compute(NestDatabase db, String homeId) async {
    final opRows = await (db.select(
      db.ops,
    )..where((o) => o.homeId.equals(homeId) & o.status.equals('applied'))).get();
    final maxByDev = <String, int>{};
    for (final r in opRows) {
      if (r.tbl == 'backup_status') continue;
      if (r.tbl == 'homes' && r.field == 'vault_id') continue;
      final prev = maxByDev[r.deviceId] ?? 0;
      if (r.seq > prev) maxByDev[r.deviceId] = r.seq;
    }

    final devLines = [
      for (final e in maxByDev.entries) '${e.key}:${e.value}',
    ]..sort();

    final memRows = await (db.select(
      db.memberOps,
    )..where((m) => m.homeId.equals(homeId))).get();
    final memIds = [for (final r in memRows) r.opId]..sort();

    final joined = [...devLines, ...memIds].join('\n');
    return toHex(await sha256Of(utf8.encode(joined)));
  }
}

/// Verifies and imports a decoded [Snapshot] through [MembershipLog], [IncomingPipeline], and [HomeKeyRing].
class SnapshotImporter {
  SnapshotImporter(this.log, this.incoming, this.keyRing, this.eraser);

  final MembershipLog log;
  final IncomingPipeline incoming;
  final HomeKeyRing keyRing;
  final HomeEraser eraser;

  Future<void> import(Snapshot s, {bool eraseOnFailure = true}) async {
    try {
      Map<String, Object?>? genesis;
      for (final m in s.memberOps) {
        if (m['type'] == 'genesis') {
          genesis = m;
          break;
        }
      }
      final payload = genesis?['payload'] as Map?;
      final gj = payload?['genesisJson'] as String?;
      if (gj == null) {
        throw const BackupFormatException(BackupError.damaged);
      }
      String computedId;
      try {
        computedId = await HomeIds.fromGenesis(gj);
      } on Object {
        throw const BackupFormatException(BackupError.damaged);
      }
      if (computedId != s.homeId) {
        throw const BackupFormatException(BackupError.damaged);
      }

      await log.addWireOps(s.homeId, s.memberOps);
      await incoming.ingest(s.homeId, ops: s.ops);

      for (final k in s.homeKeys) {
        final keyId = k['keyId'] as String;
        final raw = base64Decode(k['key'] as String);
        await keyRing.add(s.homeId, keyId, raw);
      }
    } on Object {
      if (eraseOnFailure) {
        await eraser.erase(s.homeId);
      }
      rethrow;
    }
  }
}
