import 'dart:async';
import 'dart:convert';

import 'package:nm_flat/core/crypto/aead.dart';
import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/protocol/messages.dart';
import 'package:nm_flat/core/sync/session/sync_context.dart';
import 'package:nm_flat/core/sync/version_vector.dart';

/// Symmetric peer sync state machine running over a [SecureChannel].
class SyncSession {
  SyncSession(
    this.ch,
    this.ctx, {
    required this.dialled,
    this.onAuthed,
  });

  final SecureChannel ch;
  final SyncContext ctx;
  final bool dialled;
  final bool Function(SyncSession s)? onAuthed;

  String? peerDeviceId;
  int skewMs = 0;
  int peerVersion = kSyncProtocolVersion;
  final Completer<void> ready = Completer<void>();

  VersionVector? _sent;
  final Set<String> _theirMemberOps = <String>{};
  bool _closed = false;
  Future<void> _sendChain = Future<void>.value();

  Future<void> run() async {
    try {
      await ch.send(
        HelloMsg(
          v: kSyncProtocolVersion,
          homeId: ctx.homeId,
          deviceId: ctx.myDeviceId,
          now: ctx.nowMs(),
        ).toJson(),
      );

      final helloRaw = await ch.receive(timeout: const Duration(seconds: 10));
      if (helloRaw['t'] != 'hello') {
        await _bye('hello');
        return;
      }
      final hello = HelloMsg.fromJson(helloRaw);
      peerVersion = hello.v;
      if (hello.homeId != ctx.homeId || hello.v != kSyncProtocolVersion) {
        await _bye('hello');
        return;
      }
      skewMs = hello.now - ctx.nowMs();

      final mine = dialled ? 'I' : 'R';
      final theirs = dialled ? 'R' : 'I';
      final sig = await ctx.signAuth(
        concatBytes([ch.transcript, utf8.encode(mine)]),
      );
      await ch.send(AuthMsg(deviceId: ctx.myDeviceId, sig: sig).toJson());

      final authRaw = await ch.receive(timeout: const Duration(seconds: 10));
      if (authRaw['t'] != 'auth') {
        await _bye('auth');
        return;
      }
      final auth = AuthMsg.fromJson(authRaw);
      peerDeviceId = auth.deviceId;

      final ok = await ctx.verifyPeer(
        auth.deviceId,
        concatBytes([ch.transcript, utf8.encode(theirs)]),
        auth.sig,
      );
      if (!ok) {
        await _bye('auth');
        return;
      }

      if (onAuthed != null && !onAuthed!(this)) {
        await _bye('duplicate');
        return;
      }

      await ctx.noteSeen(auth.deviceId);

      final vec = await ctx.myVector();
      final mIds = await ctx.memberOpIds();
      await ch.send(
        HaveMsg(vector: vec.toJson(), memberOpIds: mIds).toJson(),
      );

      await _loop();
    } on TimeoutException {
      await _closeQuietly();
    } on ConnectionClosed {
      await _closeQuietly();
    } on AeadError {
      await _closeQuietly();
    } on Object {
      await _closeQuietly();
    }
  }

  Future<void> _loop() async {
    while (!_closed) {
      final msg = await ch.receive(timeout: const Duration(minutes: 30));
      switch (msg['t']) {
        case 'have':
          final h = HaveMsg.fromJson(msg);
          _theirMemberOps
            ..clear()
            ..addAll(h.memberOpIds);
          await _sendMissing(VersionVector.fromJson(h.vector));

        case 'memberOps':
          final m = MemberOpsMsg.fromJson(msg);
          await ctx.ingest(memberOps: m.ops);

        case 'ops':
          final o = OpsMsg.fromJson(msg);
          await ctx.ingest(ops: o.batch);

        case 'opsDone':
          final vec = await ctx.myVector();
          final count = (await ctx.memberOpIds()).length;
          await ch.send(
            AckMsg(vector: vec.toJson(), memberOps: count).toJson(),
          );

        case 'ack':
          final a = AckMsg.fromJson(msg);
          final v = VersionVector.fromJson(a.vector);
          _sent = (_sent ?? v).merge(v);
          await ctx.saveAck(
            peerDeviceId!,
            v,
            a.memberOps,
            skewMs,
            peerVersion,
          );
          if (!ready.isCompleted) ready.complete();

        case 'bye':
          _closed = true;
          await ch.close();
          return;
      }
    }
  }

  Future<void> push() async {
    final sent = _sent;
    if (sent == null || _closed) return;
    await _sendMissing(sent);
  }

  Future<void> _sendMissing(VersionVector theirs) {
    final op = _sendChain.then((_) async {
      if (_closed) return;
      final mo = await ctx.memberOpsWire(except: _theirMemberOps);
      if (mo.isNotEmpty) {
        if (_closed) return;
        await ch.send(MemberOpsMsg(ops: mo).toJson());
        for (final m in mo) {
          _theirMemberOps.add((m['opId'] as String?) ?? '');
        }
      }

      final ops = await ctx.opsAfter(theirs);
      for (var i = 0; i < ops.length; i += 200) {
        if (_closed) return;
        final end = (i + 200 < ops.length) ? i + 200 : ops.length;
        await ch.send(OpsMsg(batch: ops.sublist(i, end)).toJson());
      }

      if (_closed) return;
      await ch.send(const OpsDoneMsg().toJson());
      _sent = theirs.merge(await ctx.myVector());
    });
    _sendChain = op.catchError((_) {});
    return op;
  }

  Future<void> _bye(String reason) async {
    if (_closed) return;
    _closed = true;
    try {
      await ch.send(ByeMsg(reason: reason).toJson());
    } on Object {
      // Ignore send errors while disconnecting.
    }
    await ch.close();
  }

  Future<void> _closeQuietly() async {
    if (_closed) return;
    _closed = true;
    try {
      await ch.close();
    } on Object {
      // Ignore close errors.
    }
  }

  Future<void> close() => _bye('close');
}
