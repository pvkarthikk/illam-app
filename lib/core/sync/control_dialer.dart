import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/sign.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/net/byte_link.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/lan_sync.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/net/tcp_byte_link.dart';
import 'package:nm_flat/core/sync/protocol/messages.dart';
import 'package:nm_flat/core/time/clock.dart';

/// Delivers queued `leave` / `deleteHome` control ops even after local home erasure.
class ControlDialer {
  ControlDialer({
    required this.keys,
    required this.controlStore,
    required this.clock,
  });

  final Future<DeviceKeys> keys;
  final ControlStore controlStore;
  final Clock clock;

  /// Sends one signed member op over [link], waits up to 20s for its ack, and marks it acked.
  Future<bool> deliverOverLink(
    ByteLink link, {
    required String homeId,
    required String opId,
    required Map<String, Object?> op,
    required DialInfo dial,
  }) async {
    FramedConnection? conn;
    try {
      conn = FramedConnection.link(link);
      final ch = await SecureChannel.handshake(conn, initiator: true);
      final k = await keys;

      await ch.send(
        HelloMsg(
          v: kSyncProtocolVersion,
          homeId: homeId,
          deviceId: k.deviceId,
          now: clock.nowMs,
        ).toJson(),
      );

      final helloRaw = await ch.receive(timeout: const Duration(seconds: 10));
      if (helloRaw['t'] != 'hello') return false;
      final hello = HelloMsg.fromJson(helloRaw);
      if (hello.homeId != homeId || hello.v != kSyncProtocolVersion) {
        return false;
      }

      final sig = await Signer.sign(
        await k.signKeyPair(),
        SignDomain.auth,
        concatBytes([ch.transcript, utf8.encode('I')]),
      );
      await ch.send(AuthMsg(deviceId: k.deviceId, sig: sig).toJson());

      final authRaw = await ch.receive(timeout: const Duration(seconds: 10));
      if (authRaw['t'] != 'auth') return false;
      final auth = AuthMsg.fromJson(authRaw);
      final signPub = dial.signPubs[auth.deviceId];
      if (!dial.deviceIds.contains(auth.deviceId) || signPub == null) {
        await _sendBye(ch, 'auth');
        return false;
      }
      final verified = await Signer.verify(
        decodeKey(signPub),
        SignDomain.auth,
        concatBytes([ch.transcript, utf8.encode('R')]),
        auth.sig,
      );
      if (!verified) {
        await _sendBye(ch, 'auth');
        return false;
      }

      await ch.send(MemberOpsMsg(ops: [op]).toJson());
      await ch.send(const OpsDoneMsg().toJson());

      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (true) {
        final left = deadline.difference(DateTime.now());
        if (left <= Duration.zero) return false;
        final msg = await ch.receive(timeout: left);
        if (msg['t'] == 'ack') {
          final ack = AckMsg.fromJson(msg);
          if (ack.memberOpIds.contains(opId)) {
            await controlStore.markAcked(opId);
            await _sendBye(ch, 'done');
            return true;
          }
        } else if (msg['t'] == 'bye') {
          return false;
        }
      }
    } on Object {
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      } else {
        await link.close();
      }
    }
  }

  Future<void> _sendBye(SecureChannel ch, String reason) async {
    try {
      await ch.send(ByeMsg(reason: reason).toJson());
    } on Object {
      // Ignore send errors on disconnect.
    }
  }

  /// Finds family phones via mDNS `lanTag`s in [DialInfo] and delivers queued control ops.
  Future<void> runOnce() async {
    final items =
        <({String homeId, String opId, Map<String, Object?> op, DialInfo dial})>[];
    final seenOpIds = <String>{};

    for (final e in await controlStore.allPendingOutbox()) {
      if (e.opJson.isEmpty || !seenOpIds.add(e.opId)) continue;
      final map = Map<String, Object?>.from(jsonDecode(e.opJson) as Map);
      items.add((homeId: e.homeId, opId: e.opId, op: map, dial: e.dial));
    }
    for (final t in await controlStore.tombstonesToPass()) {
      final raw = t.opJson;
      if (raw == null || raw.isEmpty) continue;
      final map = Map<String, Object?>.from(jsonDecode(raw) as Map);
      final opId = (map['opId'] as String?) ?? '';
      if (opId.isEmpty || !seenOpIds.add(opId)) continue;
      items.add((homeId: t.homeId, opId: opId, op: map, dial: t.dial));
    }
    if (items.isEmpty) return;

    final nowUtc = clock.now().toUtc();
    final allTags = <String>{};
    for (final item in items) {
      for (final b64Key in item.dial.homeKeysB64) {
        if (b64Key.isEmpty) continue;
        allTags.addAll(await lanTagsFor(base64Decode(b64Key), nowUtc));
      }
    }
    if (allTags.isEmpty) return;

    final endpoints = <String, ({String host, int port})>{};
    final lan = LanSyncService();
    try {
      await lan.discover(allTags, (host, port) {
        endpoints['$host:$port'] = (host: host, port: port);
      });
      await Future<void>.delayed(const Duration(seconds: 3));
    } on Object {
      // mDNS discovery unavailable in background/headless environments.
    } finally {
      await lan.stop();
    }

    if (endpoints.isEmpty) return;

    for (final item in items) {
      if (item.dial.deviceIds.isEmpty) continue;
      for (final ep in endpoints.values) {
        try {
          final sock = await Socket.connect(
            ep.host,
            ep.port,
            timeout: const Duration(seconds: 5),
          );
          final delivered = await deliverOverLink(
            TcpByteLink(sock),
            homeId: item.homeId,
            opId: item.opId,
            op: item.op,
            dial: item.dial,
          );
          if (delivered) break;
        } on Object {
          // Try next discovered endpoint.
        }
      }
    }
  }
}

final controlDialerProvider = Provider<ControlDialer>(
  (ref) => ControlDialer(
    keys: ref.watch(deviceKeysProvider.future),
    controlStore: ref.watch(controlStoreProvider),
    clock: ref.watch(clockProvider),
  ),
);
