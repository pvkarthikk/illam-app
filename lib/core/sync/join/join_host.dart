import 'dart:async';
import 'dart:convert';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/crypto/sas.dart';
import 'package:nm_flat/core/crypto/spake2.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';
import 'package:nm_flat/core/sync/join/active_invite.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/protocol/join_messages.dart';

typedef OnJoinRequest =
    Future<String?> Function(JoinRequest r, List<String> emojis);

abstract class JoinAdmitter {
  Future<int> admit(
    SecureChannel ch,
    JoinRequest r,
    String role,
    String via,
    void Function(int sent, int total) progress,
  );
}

/// Runs the inviter side of a single incoming join connection.
class JoinHost {
  JoinHost({
    required this.invite,
    required this.homeId,
    required this.homeName,
    required this.inviterName,
    required this.onRequest,
    required this.admitter,
    this.onProgress,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final ActiveInvite invite;
  final String homeId;
  final String homeName;
  final String inviterName;
  final OnJoinRequest onRequest;
  final JoinAdmitter admitter;
  final void Function(int sent, int total)? onProgress;
  final DateTime Function() now;

  Future<JoinRequest?> handle(FramedConnection conn) async {
    var acquiredBusy = false;
    SecureChannel? ch;
    try {
      ch = await SecureChannel.handshake(conn, initiator: false);
      final hello = await ch.receive();
      if (hello['v'] != kProtocolVersion) {
        await ch.send({'t': 'error', 'code': 'version'});
        return null;
      }
      if (!invite.isOpen(now())) {
        await ch.send({'t': 'error', 'code': 'expired'});
        return null;
      }
      if (invite.busy) {
        await ch.send({'t': 'error', 'code': 'busy'});
        return null;
      }

      invite.busy = true;
      acquiredBusy = true;
      final mode = (hello['mode'] as String?) ?? 'phrase';
      await ch.send({'t': 'hello', 'v': kProtocolVersion});

      final pw = mode == 'qr'
          ? invite.qrSecret
          : JoinPhrase.password(invite.phrase);
      final ctx = mode == 'qr'
          ? 'illam-join-v1|$homeId'
          : JoinPhrase.context(invite.nameplate);

      final sp = Spake2.b(
        w: Spake2.passwordToW(pw, ctx),
        idA: idJoiner,
        idB: idInviter,
        aad: concatBytes([utf8.encode(ctx), ch.transcript]),
      );
      final pB = await sp.startAsync();
      final p1 = await ch.receive();
      final keys = await sp.finishAsync(unb64(p1['pA'] as String));
      await ch.send({
        't': 'pake2',
        'pB': b64(pB),
        'cB': b64(keys.myConfirm),
      });

      List<int> cA;
      try {
        final p3 = await ch.receive(timeout: const Duration(seconds: 30));
        cA = unb64(p3['cA'] as String);
      } on Object {
        invite.registerFailure();
        return null;
      }
      if (!constantTimeEquals(cA, keys.peerConfirm)) {
        invite.registerFailure();
        return null;
      }

      await ch.rekey(keys.ke);
      await ch.send({
        't': 'inviter',
        'homeId': homeId,
        'homeName': homeName,
        'inviterName': inviterName,
      });

      final commitMsg = await ch.receive();
      final commitBytes = unb64(commitMsg['c'] as String);
      final nI = randomBytes(32);
      await ch.send({'t': 'nonceI', 'n': b64(nI)});
      final revealMsg = await ch.receive();
      final nJ = unb64(revealMsg['n'] as String);
      if (!constantTimeEquals(await sha256Of(nJ), commitBytes)) {
        return null;
      }
      final emojis = await sasFor(keys.ke, ch.transcript, nI, nJ);

      final reqMsg = await ch.receive();
      final r = JoinRequest.fromJson(reqMsg);
      final derivedId = await DeviceKeys.deviceIdFor(unb64(r.signPub));
      if (r.deviceId != derivedId) return null;

      var left = false;
      final gone = conn.closed.then<String?>((_) {
        left = true;
        return null;
      });
      String? role;
      try {
        role = await Future.any<String?>([
          onRequest(r, emojis),
          gone,
        ]).timeout(const Duration(minutes: 3));
      } on TimeoutException {
        role = null;
      }
      if (left) return null;
      if (role == null) {
        await ch.send({'t': 'denied'});
        invite.status = InviteStatus.void_;
        return null;
      }

      await ch.send({'t': 'approved', 'role': role});
      await admitter.admit(ch, r, role, mode, onProgress ?? (_, _) {});
      invite.status = InviteStatus.used;
      return r;
    } on Object {
      return null;
    } finally {
      if (acquiredBusy) invite.busy = false;
      if (ch != null) {
        await ch.close();
      } else {
        await conn.close();
      }
    }
  }
}
