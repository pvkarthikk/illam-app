import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/avatar_colors.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/sync/incoming.dart';
import 'package:nm_flat/core/sync/join/join_guest.dart';
import 'package:nm_flat/core/sync/join/join_host.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/protocol/join_messages.dart';
import 'package:nm_flat/core/sync/sync_store.dart';

/// Inviter-side admission handler: wraps home key, logs `addMember`, streams ops.
class HostAdmitter implements JoinAdmitter {
  HostAdmitter(
    this.db,
    this.secure,
    this.membershipLog,
    this.syncStore,
    this.homeId,
  );

  final NestDatabase db;
  final SecureStore secure;
  final MembershipLog membershipLog;
  final SyncStore syncStore;
  final String homeId;

  @override
  Future<int> admit(
    SecureChannel ch,
    JoinRequest r,
    String role,
    String via,
    void Function(int sent, int total) progress,
  ) async {
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(homeId))).getSingle();
    final keyId = home.homeKeyId ?? 'genesis';
    final rawKey = await secure.read(SecureKeys.homeKey(homeId, keyId));
    if (rawKey == null) throw StateError('no home key');
    final homeKey = base64Decode(rawKey);
    final wrapped = await SealedBox.seal(unb64(r.agreePub), homeKey);

    final activeMembers =
        await (db.select(db.members)..where(
              (m) =>
                  m.homeId.equals(homeId) &
                  m.deleted.equals(false) &
                  m.status.equals('active'),
            ))
            .get();
    final usedColors = {
      for (final m in activeMembers)
        if (m.color != null) m.color!,
    };

    final res = await membershipLog.append(homeId, 'addMember', {
      'memberId': r.deviceId,
      'name': r.name,
      'color': AvatarColors.pick(r.deviceId, usedColors),
      'role': role,
      'via': via,
      'device': {
        'deviceId': r.deviceId,
        'signPub': r.signPub,
        'agreePub': r.agreePub,
        'model': r.model,
      },
      'wrappedKey': b64(wrapped),
      'keyId': keyId,
    });
    if (res.effect != 'applied') {
      throw StateError('addMember ${res.reason}');
    }

    final ops = await syncStore.allOpsWire(homeId);
    await ch.send({
      't': 'admit',
      'homeId': homeId,
      'memberOps': await membershipLog.allWire(homeId),
      'total': ops.length,
    });

    for (var i = 0; i < ops.length; i += 200) {
      final end = (i + 200 < ops.length) ? i + 200 : ops.length;
      await ch.send({'t': 'ops', 'batch': ops.sublist(i, end)});
      progress(end, ops.length);
    }

    await ch.send({'t': 'done'});
    final ack = await ch.receive(timeout: const Duration(seconds: 60));
    if (ack['t'] != 'ack') throw StateError('expected ack');
    return ops.length;
  }
}

/// Joiner-side data receiver: verifies genesis, unseals home key, ingests ops.
class GuestReceiver implements JoinReceiver {
  GuestReceiver(
    this.db,
    this.secure,
    this.prefs,
    this.keys,
    this.membershipLog,
    this.incoming,
  );

  final NestDatabase db;
  final SecureStore secure;
  final DevicePrefs prefs;
  final DeviceKeys keys;
  final MembershipLog membershipLog;
  final IncomingPipeline incoming;

  @override
  Future<int> receive(
    SecureChannel ch,
    String homeId,
    String? expectedHomeId,
    void Function(int got, int total) progress,
  ) async {
    final a = await ch.receive(timeout: const Duration(seconds: 60));
    if (a['t'] != 'admit') throw StateError('expected admit');
    final memberOps = [
      for (final m in a['memberOps'] as List) Map<String, Object?>.from(m as Map),
    ];
    final total = (a['total'] as num).toInt();

    final gen = memberOps.firstWhere((m) => m['type'] == 'genesis');
    final genPayload = Map<String, Object?>.from(gen['payload'] as Map);
    final genesisJson = genPayload['genesisJson'] as String;
    final computedId = await HomeIds.fromGenesis(genesisJson);
    if (computedId != homeId ||
        (expectedHomeId != null && computedId != expectedHomeId)) {
      throw StateError('bad genesis');
    }

    await membershipLog.addWireOps(homeId, memberOps);
    final activeDev =
        await (db.select(db.memberDevices)..where(
              (d) =>
                  d.deviceId.equals(keys.deviceId) &
                  d.homeId.equals(homeId) &
                  d.active.equals(true),
            ))
            .getSingleOrNull();
    if (activeDev == null) throw StateError('not admitted');

    final myAdd = memberOps.lastWhere(
      (m) =>
          m['type'] == 'addMember' &&
          (m['payload'] as Map)['memberId'] == keys.deviceId,
    );
    final myPayload = Map<String, Object?>.from(myAdd['payload'] as Map);
    final homeKey = await SealedBox.open(
      await keys.agreeKeyPair(),
      unb64(myPayload['wrappedKey'] as String),
    );
    final keyId = (myPayload['keyId'] as String?) ?? 'genesis';
    await secure.write(
      SecureKeys.homeKey(homeId, keyId),
      base64Encode(homeKey),
    );

    await prefs.setMemberId(keys.deviceId);
    await prefs.setSetupIncompleteHomeId(homeId);
    await prefs.setSetupPct(0);
    var got = 0;

    while (true) {
      final m = await ch.receive(timeout: const Duration(seconds: 60));
      final t = m['t'];
      if (t == 'ops') {
        final batch = [
          for (final o in m['batch'] as List) Map<String, Object?>.from(o as Map),
        ];
        await incoming.ingest(homeId, ops: batch);
        got += batch.length;
        progress(got, total);
        await prefs.setSetupPct(total == 0 ? 100 : got * 100 ~/ total);
      } else if (t == 'done') {
        await ch.send({'t': 'ack'});
        await prefs.setSetupIncompleteHomeId(null);
        return got;
      } else {
        throw StateError('unexpected msg $t');
      }
    }
  }
}
