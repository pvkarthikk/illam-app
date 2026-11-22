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
  NoticeMsg? receivedNotice;
  final Completer<void> ready = Completer<void>();

  VersionVector? _sent;
  VersionVector? _theirsLastHave;
  bool _sentDataOps = false;
  final Set<String> _theirMemberOps = <String>{};
  final List<String> _receivedMemberOpIds = <String>[];
  bool _controlOnly = false;
  ({String reason, String? byName})? _pendingErase;
  bool _closed = false;
  Future<void> _sendChain = Future<void>.value();

  ControlSyncContext? get _ctrl =>
      ctx is ControlSyncContext ? ctx as ControlSyncContext : null;

  RestoreSyncContext? get _restore =>
      ctx is RestoreSyncContext ? ctx as RestoreSyncContext : null;

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
      await ch.send(
        AuthMsg(
          deviceId: ctx.myDeviceId,
          sig: sig,
          signPub: _restore?.mySignPubB64,
        ).toJson(),
      );

      final authRaw = await ch.receive(timeout: const Duration(seconds: 10));
      if (authRaw['t'] != 'auth') {
        await _bye('auth');
        return;
      }
      final auth = AuthMsg.fromJson(authRaw);
      peerDeviceId = auth.deviceId;

      final restore = _restore;
      final authBody = concatBytes([ch.transcript, utf8.encode(theirs)]);
      final ok = restore != null
          ? await restore.verifyPeerWithPub(
              auth.deviceId,
              authBody,
              auth.sig,
              auth.signPub,
            )
          : await ctx.verifyPeer(auth.deviceId, authBody, auth.sig);
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
    } finally {
      final erase = _pendingErase;
      final ctrl = _ctrl;
      if (erase != null && ctrl != null) {
        await ctrl.eraseMyHome(erase.reason, byName: erase.byName);
      }
    }
  }

  Future<void> _loop() async {
    while (!_closed) {
      final msg = await ch.receive(timeout: const Duration(minutes: 30));
      switch (msg['t']) {
        case 'have':
          final h = HaveMsg.fromJson(msg);
          _theirsLastHave = VersionVector.fromJson(h.vector);
          _theirMemberOps
            ..clear()
            ..addAll(h.memberOpIds);
          await _sendMissing(_theirsLastHave!);

        case 'memberOps':
          final m = MemberOpsMsg.fromJson(msg);
          for (final op in m.ops) {
            final opId = op['opId'] as String?;
            if (opId != null && !_receivedMemberOpIds.contains(opId)) {
              _receivedMemberOpIds.add(opId);
            }
          }
          final wasControl = _controlOnly;
          await ctx.ingest(memberOps: m.ops);
          final sit = await _refreshSituation();
          if (wasControl && !_controlOnly && !_sentDataOps && sit != null && sit.isFull) {
            await _sendMissing(_theirsLastHave ?? const VersionVector({}));
          }

        case 'ops':
          final o = OpsMsg.fromJson(msg);
          final ctrl = _ctrl;
          if (ctrl != null && (await ctrl.isHomeErased() || !_shouldAcceptOps())) {
            continue;
          }
          await ctx.ingest(ops: o.batch);

        case 'opsDone':
          await _sendChain;
          if (_closed) return;
          final sit = await _refreshSituation();
          if (sit != null &&
              !sit.peerActive &&
              sit.peerNoticeKind == 'recoverDead') {
            await _trySend(
              NoticeMsg(
                kind: 'recoverDead',
                opId: sit.peerNoticeOpId ?? '',
                reason: sit.peerNoticeReason,
                at: sit.peerNoticeAt,
              ).toJson(),
            );
            await _bye('control');
            return;
          }
          final vec = await ctx.myVector();
          final count = (await ctx.memberOpIds()).length;
          await _trySend(
            AckMsg(
              vector: vec.toJson(),
              memberOps: count,
              memberOpIds: List<String>.from(_receivedMemberOpIds),
            ).toJson(),
          );
          if (sit != null && !sit.peerActive) {
            await _trySend(
              NoticeMsg(
                kind: sit.peerNoticeKind ?? 'removed',
                opId: sit.peerNoticeOpId ?? '',
                reason: sit.peerNoticeReason,
                at: sit.peerNoticeAt,
              ).toJson(),
            );
            await _bye('control');
            return;
          }

        case 'ack':
          final a = AckMsg.fromJson(msg);
          final v = VersionVector.fromJson(a.vector);
          _sent = (_sent ?? v).merge(v);
          final ctrl = _ctrl;
          if (ctrl != null) {
            final leftAcked = await ctrl.onAckMemberOpIds(a.memberOpIds);
            if (leftAcked) {
              _pendingErase = (reason: 'left', byName: null);
            }
          }
          await ctx.saveAck(
            peerDeviceId!,
            v,
            a.memberOps,
            skewMs,
            peerVersion,
          );
          if (!_controlOnly) {
            await _restore?.onFullAck();
          }
          if (!ready.isCompleted) ready.complete();

        case 'notice':
          receivedNotice = NoticeMsg.fromJson(msg);
          if (receivedNotice!.kind == 'recoverDead') {
            await _restore?.onRecoverDead(
              receivedNotice!.reason ?? 'revoked',
              receivedNotice!.at ?? ctx.nowMs(),
            );
          }
          await _refreshSituation();

        case 'bye':
          _closed = true;
          await ch.close();
          return;
      }
    }
  }

  bool _shouldAcceptOps() => !_controlOnly && _pendingErase == null;

  Future<PeerSituation?> _refreshSituation() async {
    final ctrl = _ctrl;
    final peer = peerDeviceId;
    if (ctrl == null || peer == null) return null;
    if (await ctrl.isHomeErased()) {
      _controlOnly = true;
      return null;
    }
    final sit = await ctrl.evaluateSituation(peer);
    _controlOnly = !sit.isFull;
    if (!sit.meActive && sit.myEraseReason != null) {
      _pendingErase ??= (reason: sit.myEraseReason!, byName: sit.myEraseByName);
    }
    return sit;
  }

  Future<void> push() async {
    final sent = _sent;
    if (sent == null || _closed || _controlOnly) return;
    await _sendMissing(sent);
  }

  Future<void> _trySend(Map<String, Object?> msg) async {
    try {
      await ch.send(msg);
    } on ConnectionClosed {
      // Peer already sent bye and closed its stream; keep draining buffered incoming frames.
    }
  }

  Future<void> _sendMissing(VersionVector theirs) {
    final op = _sendChain.then((_) async {
      if (_closed) return;
      final mo = await ctx.memberOpsWire(except: _theirMemberOps);
      if (mo.isNotEmpty) {
        if (_closed) return;
        await _trySend(MemberOpsMsg(ops: mo).toJson());
        for (final m in mo) {
          _theirMemberOps.add((m['opId'] as String?) ?? '');
        }
      }

      final sit = await _refreshSituation();
      if (sit == null || sit.isFull) {
        _sentDataOps = true;
        final ops = await ctx.opsAfter(theirs);
        for (var i = 0; i < ops.length; i += 200) {
          if (_closed || _controlOnly) break;
          final end = (i + 200 < ops.length) ? i + 200 : ops.length;
          await _trySend(OpsMsg(batch: ops.sublist(i, end)).toJson());
        }
        _sent = theirs.merge(await ctx.myVector());
      }

      if (_closed) return;
      await _trySend(const OpsDoneMsg().toJson());
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
