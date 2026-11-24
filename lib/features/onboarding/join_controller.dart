import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/join/admission.dart';
import 'package:nm_flat/core/sync/join/join_guest.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/lan_join.dart';
import 'package:nm_flat/core/sync/protocol/join_messages.dart';
import 'package:nm_flat/core/util/device_model.dart';

enum JoinStepState { todo, active, done, fail }

class JoinUi {
  const JoinUi({
    this.name = '',
    this.secret,
    this.ticket,
    this.debugPort,
    this.find = JoinStepState.todo,
    this.code = JoinStepState.todo,
    this.approve = JoinStepState.todo,
    this.copy = JoinStepState.todo,
    this.inviterName,
    this.homeName,
    this.homeId,
    this.emojis = const [],
    this.role = 'member',
    this.pct = 0,
    this.count = 0,
    this.failure,
    this.running = false,
    this.others = const [],
  });

  final String name;
  final JoinSecret? secret;
  final JoinTicket? ticket;
  final int? debugPort;
  final JoinStepState find;
  final JoinStepState code;
  final JoinStepState approve;
  final JoinStepState copy;
  final String? inviterName;
  final String? homeName;
  final String? homeId;
  final List<String> emojis;
  final String role;
  final int pct;
  final int count;
  final JoinFailure? failure;
  final bool running;
  final List<({String name, String color})> others;

  JoinUi copyWith({
    String? name,
    JoinSecret? secret,
    JoinTicket? ticket,
    bool clearTicket = false,
    int? debugPort,
    bool clearDebugPort = false,
    JoinStepState? find,
    JoinStepState? code,
    JoinStepState? approve,
    JoinStepState? copy,
    String? inviterName,
    String? homeName,
    String? homeId,
    List<String>? emojis,
    String? role,
    int? pct,
    int? count,
    JoinFailure? failure,
    bool clearFailure = false,
    bool? running,
    List<({String name, String color})>? others,
  }) => JoinUi(
    name: name ?? this.name,
    secret: secret ?? this.secret,
    ticket: clearTicket ? null : (ticket ?? this.ticket),
    debugPort: clearDebugPort ? null : (debugPort ?? this.debugPort),
    find: find ?? this.find,
    code: code ?? this.code,
    approve: approve ?? this.approve,
    copy: copy ?? this.copy,
    inviterName: inviterName ?? this.inviterName,
    homeName: homeName ?? this.homeName,
    homeId: homeId ?? this.homeId,
    emojis: emojis ?? this.emojis,
    role: role ?? this.role,
    pct: pct ?? this.pct,
    count: count ?? this.count,
    failure: clearFailure ? null : (failure ?? this.failure),
    running: running ?? this.running,
    others: others ?? this.others,
  );
}

final joinControllerProvider = NotifierProvider<JoinController, JoinUi>(
  JoinController.new,
);

class JoinController extends Notifier<JoinUi> {
  FramedConnection? _conn;
  bool _cancelled = false;
  int _run = 0;

  @override
  JoinUi build() => const JoinUi();

  void setName(String raw) {
    state = state.copyWith(name: Names.titleCase(raw));
  }

  void usePhrase(String phrase, {int? debugPort}) {
    final np = JoinPhrase.nameplate(phrase);
    state = state.copyWith(
      secret: JoinSecret(
        mode: 'phrase',
        password: JoinPhrase.password(phrase),
        context: JoinPhrase.context(np),
        nameplate: np,
      ),
      clearTicket: true,
      debugPort: debugPort,
      clearDebugPort: debugPort == null,
    );
  }

  void useTicket(JoinTicket t) {
    state = state.copyWith(
      secret: JoinSecret(
        mode: 'qr',
        password: t.secret,
        context: 'nestmojo-join-v1|${t.homeId}',
        nameplate: t.nameplate,
        expectedHomeId: t.homeId,
      ),
      ticket: t,
      clearDebugPort: true,
    );
  }

  Future<void> start() async {
    if (state.running) return;
    final run = ++_run;
    _cancelled = false;
    state = state.copyWith(
      find: JoinStepState.active,
      code: JoinStepState.todo,
      approve: JoinStepState.todo,
      copy: JoinStepState.todo,
      clearFailure: true,
      running: true,
      pct: 0,
      count: 0,
      emojis: const [],
      others: const [],
    );

    final ticket = state.ticket;
    if (ticket != null &&
        ticket.expiry < DateTime.now().millisecondsSinceEpoch ~/ 1000) {
      state = state.copyWith(
        find: JoinStepState.fail,
        failure: JoinFailure.expired,
        running: false,
      );
      return;
    }

    Socket? sock;
    if (state.debugPort != null) {
      sock = await LanJoinFinder.dial('127.0.0.1', state.debugPort!);
    } else if (ticket != null) {
      sock = await LanJoinFinder.dial(ticket.ip, ticket.port);
      if (run != _run) {
        sock?.destroy();
        return;
      }
      sock ??= await LanJoinFinder.find(ticket.nameplate);
    } else if (state.secret != null) {
      sock = await LanJoinFinder.find(state.secret!.nameplate);
    }

    if (run != _run) {
      sock?.destroy();
      return;
    }

    if (_cancelled) {
      sock?.destroy();
      state = state.copyWith(running: false);
      return;
    }

    if (sock == null) {
      state = state.copyWith(
        find: JoinStepState.fail,
        failure: JoinFailure.notFound,
        running: false,
      );
      return;
    }

    final conn = FramedConnection.socket(sock);
    _conn = conn;
    state = state.copyWith(
      find: JoinStepState.done,
      code: JoinStepState.active,
    );

    try {
      final keys = await ref.read(deviceKeysProvider.future);
      if (run != _run) {
        await conn.close();
        return;
      }
      final model = await deviceModel();
      if (run != _run) {
        await conn.close();
        return;
      }
      final me = JoinRequest(
        name: state.name,
        model: model,
        deviceId: keys.deviceId,
        signPub: keys.signPubB64,
        agreePub: b64(keys.agreePub),
      );
      final receiver = GuestReceiver(
        ref.read(dbProvider),
        ref.read(secureStoreProvider),
        ref.read(prefsProvider),
        keys,
        ref.read(membershipLogProvider),
        ref.read(incomingProvider),
      );
      await JoinGuest(me, receiver).run(conn, state.secret!, (e) {
        if (run == _run) _onEvent(e);
      });
      if (run != _run) {
        await conn.close();
        return;
      }
    } finally {
      if (run == _run) {
        _conn = null;
        state = state.copyWith(running: false);
      }
    }
  }

  void _onEvent(JoinEvent e) {
    switch (e) {
      case JoinCodeOk(:final homeName, :final inviterName, :final homeId):
        state = state.copyWith(
          code: JoinStepState.done,
          approve: JoinStepState.active,
          homeName: homeName,
          inviterName: inviterName,
          homeId: homeId,
        );
      case JoinSas(:final emojis):
        state = state.copyWith(emojis: emojis);
      case JoinApproved(:final role):
        state = state.copyWith(
          approve: JoinStepState.done,
          copy: JoinStepState.active,
          role: role,
        );
      case JoinProgress(:final got, :final total):
        state = state.copyWith(
          pct: total == 0 ? 100 : got * 100 ~/ total,
        );
      case JoinDone(:final count, :final homeId, :final homeName):
        state = state.copyWith(
          copy: JoinStepState.done,
          count: count,
          homeId: homeId,
          homeName: homeName,
        );
        unawaited(_loadOthers(homeId));
      case JoinFailed(:final failure):
        if (_cancelled) return;
        state = state.copyWith(
          find: state.find == JoinStepState.active
              ? JoinStepState.fail
              : state.find,
          code: state.code == JoinStepState.active
              ? JoinStepState.fail
              : state.code,
          approve: state.approve == JoinStepState.active
              ? JoinStepState.fail
              : state.approve,
          copy: state.copy == JoinStepState.active
              ? JoinStepState.fail
              : state.copy,
          failure: failure,
          running: false,
        );
    }
  }

  Future<void> _loadOthers(String homeId) async {
    final db = ref.read(dbProvider);
    final keys = await ref.read(deviceKeysProvider.future);
    final rows =
        await (db.select(db.members)..where(
              (m) => m.homeId.equals(homeId) & m.deleted.equals(false),
            ))
            .get();
    final others = <({String name, String color})>[];
    for (final m in rows) {
      if (m.status != 'active' || m.id == keys.deviceId) continue;
      final label = (m.firstName != null && m.firstName!.isNotEmpty)
          ? m.firstName!
          : (m.fullName ?? '');
      others.add((name: label, color: m.color ?? ''));
    }
    state = state.copyWith(others: others);
  }

  Future<void> cancel() async {
    _run++;
    _cancelled = true;
    await _conn?.close();
    _conn = null;
    state = JoinUi(
      name: state.name,
      secret: state.secret,
      ticket: state.ticket,
      debugPort: state.debugPort,
    );
  }

  Future<void> retry() async {
    _cancelled = false;
    await start();
  }
}
