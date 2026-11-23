import 'dart:convert';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/kdf.dart';
import 'package:nm_flat/core/crypto/sas.dart';
import 'package:nm_flat/core/crypto/spake2.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/protocol/join_messages.dart';

enum JoinFailure { notFound, wrongCode, expired, declined, version, interrupted }

sealed class JoinEvent {
  const JoinEvent();
}

class JoinCodeOk extends JoinEvent {
  const JoinCodeOk(this.homeName, this.inviterName, this.homeId);

  final String homeName;
  final String inviterName;
  final String homeId;
}

class JoinSas extends JoinEvent {
  const JoinSas(this.emojis);

  final List<String> emojis;
}

class JoinApproved extends JoinEvent {
  const JoinApproved(this.role);

  final String role;
}

class JoinProgress extends JoinEvent {
  const JoinProgress(this.got, this.total);

  final int got;
  final int total;
}

class JoinDone extends JoinEvent {
  const JoinDone(this.count, this.homeId, this.homeName);

  final int count;
  final String homeId;
  final String homeName;
}

class JoinFailed extends JoinEvent {
  const JoinFailed(this.failure);

  final JoinFailure failure;
}

class JoinSecret {
  const JoinSecret({
    required this.mode,
    required this.password,
    required this.context,
    required this.nameplate,
    this.expectedHomeId,
  });

  final String mode;
  final List<int> password;
  final String context;
  final String nameplate;
  final String? expectedHomeId;
}

abstract class JoinReceiver {
  Future<int> receive(
    SecureChannel ch,
    String homeId,
    String? expectedHomeId,
    void Function(int got, int total) progress,
  );
}

/// Runs the joiner side of the encrypted PAKE + SAS admission protocol.
class JoinGuest {
  JoinGuest(this.me, this.receiver, {this.version = kProtocolVersion});

  final JoinRequest me;
  final JoinReceiver receiver;
  final int version;

  Future<void> run(
    FramedConnection conn,
    JoinSecret s,
    void Function(JoinEvent) emit,
  ) async {
    final SecureChannel ch;
    try {
      ch = await SecureChannel.handshake(conn, initiator: true);
    } on Object {
      await conn.close();
      emit(const JoinFailed(JoinFailure.notFound));
      return;
    }

    var approved = false;
    try {
      await ch.send({'t': 'hello', 'v': version, 'mode': s.mode});
      final hello = await ch.receive();
      if (hello['t'] == 'error') {
        final code = hello['code'];
        emit(
          JoinFailed(
            code == 'version' ? JoinFailure.version : JoinFailure.expired,
          ),
        );
        return;
      }

      final sp = Spake2.a(
        w: Spake2.passwordToW(s.password, s.context),
        idA: idJoiner,
        idB: idInviter,
        aad: concatBytes([utf8.encode(s.context), ch.transcript]),
      );
      await ch.send({'t': 'pake1', 'pA': b64(await sp.startAsync())});

      final p2 = await ch.receive();
      final keys = await sp.finishAsync(unb64(p2['pB'] as String));
      final cB = unb64(p2['cB'] as String);
      if (!constantTimeEquals(cB, keys.peerConfirm)) {
        emit(const JoinFailed(JoinFailure.wrongCode));
        return;
      }

      await ch.send({'t': 'pake3', 'cA': b64(keys.myConfirm)});
      await ch.rekey(keys.ke);

      final inv = await ch.receive();
      final homeId = inv['homeId'] as String;
      final homeName = inv['homeName'] as String;
      final inviterName = inv['inviterName'] as String;
      if (s.expectedHomeId != null && s.expectedHomeId != homeId) {
        emit(const JoinFailed(JoinFailure.wrongCode));
        return;
      }
      emit(JoinCodeOk(homeName, inviterName, homeId));

      final nJ = randomBytes(32);
      await ch.send({'t': 'commit', 'c': b64(await sha256Of(nJ))});
      final niMsg = await ch.receive();
      final nI = unb64(niMsg['n'] as String);
      await ch.send({'t': 'reveal', 'n': b64(nJ)});
      emit(JoinSas(await sasFor(keys.ke, ch.transcript, nI, nJ)));

      await ch.send({'t': 'request', ...me.toJson()});
      final resp = await ch.receive(timeout: const Duration(minutes: 4));
      if (resp['t'] != 'approved') {
        emit(const JoinFailed(JoinFailure.declined));
        return;
      }

      approved = true;
      emit(JoinApproved(resp['role'] as String));

      final n = await receiver.receive(
        ch,
        homeId,
        s.expectedHomeId,
        (got, total) => emit(JoinProgress(got, total)),
      );
      emit(JoinDone(n, homeId, homeName));
    } on Object {
      emit(JoinFailed(approved ? JoinFailure.interrupted : JoinFailure.notFound));
    } finally {
      await ch.close();
    }
  }
}
