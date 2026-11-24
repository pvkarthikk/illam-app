import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/word_list.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/join/active_invite.dart';
import 'package:nm_flat/core/sync/join/admission.dart';
import 'package:nm_flat/core/sync/join/join_host.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/lan_join.dart';
import 'package:nm_flat/core/sync/net/local_ip.dart';
import 'package:nm_flat/core/sync/protocol/join_messages.dart';
import 'package:nm_flat/core/sync/sync_store.dart';

enum InviteStage { waiting, request, copying, done, expired }

class InviteUi {
  const InviteUi({
    this.invite,
    this.stage = InviteStage.waiting,
    this.request,
    this.emojis = const [],
    this.pct = 0,
    this.joinedName,
    this.port,
    this.ip,
    this.showSecondAdminTip = false,
  });

  final ActiveInvite? invite;
  final InviteStage stage;
  final JoinRequest? request;
  final List<String> emojis;
  final int pct;
  final String? joinedName;
  final int? port;
  final String? ip;
  final bool showSecondAdminTip;

  InviteUi copyWith({
    ActiveInvite? invite,
    InviteStage? stage,
    JoinRequest? request,
    bool clearRequest = false,
    List<String>? emojis,
    int? pct,
    String? joinedName,
    int? port,
    String? ip,
    bool? showSecondAdminTip,
  }) => InviteUi(
    invite: invite ?? this.invite,
    stage: stage ?? this.stage,
    request: clearRequest ? null : (request ?? this.request),
    emojis: emojis ?? this.emojis,
    pct: pct ?? this.pct,
    joinedName: joinedName ?? this.joinedName,
    port: port ?? this.port,
    ip: ip ?? this.ip,
    showSecondAdminTip: showSecondAdminTip ?? this.showSecondAdminTip,
  );
}

final inviteControllerProvider =
    NotifierProvider<InviteController, InviteUi>(InviteController.new);

class InviteController extends Notifier<InviteUi> {
  LanJoinServer? _server;
  Completer<String?>? _decision;
  bool _disposed = false;
  int _gen = 0;

  @override
  InviteUi build() {
    ref.onDispose(() {
      _disposed = true;
      pause();
    });
    return const InviteUi();
  }

  Future<void> start() async {
    final now = DateTime.now();
    var inv = state.invite;
    if (_server != null && inv != null && inv.isOpen(now)) return;
    final gen = ++_gen;

    if (inv == null || !inv.isOpen(now)) {
      final wordList = await ref.read(wordListProvider.future);
      inv = ActiveInvite.create(
        JoinPhrase.generate(wordList.words, Random.secure()),
      );
    }
    if (_disposed || gen != _gen) return;

    await _server?.stop();
    _server = null;

    final srv = await LanJoinServer.start(
      nameplate: inv.nameplate,
      onClient: (s) => unawaited(_serve(FramedConnection.socket(s))),
    );
    if (_disposed || gen != _gen) {
      await srv.stop();
      return;
    }
    _server = srv;
    final ip = await localWifiIp();
    if (_disposed || gen != _gen) return;
    state = InviteUi(
      invite: inv,
      stage: InviteStage.waiting,
      port: srv.port,
      ip: ip,
    );
  }

  Future<void> _serve(FramedConnection conn) async {
    final inv = state.invite;
    if (inv == null) {
      await conn.close();
      return;
    }
    final home = ref.read(currentHomeProvider).value;
    final homeId = home?.id ?? ref.read(prefsProvider).currentHomeId ?? '';
    final homeName = home?.name ?? '';
    final me = ref.read(myMemberProvider).value;
    final inviterName = (me?.firstName != null && me!.firstName!.isNotEmpty)
        ? me.firstName!
        : (me?.fullName ?? '');

    final db = ref.read(dbProvider);
    var mine = false;
    final host = JoinHost(
      invite: inv,
      homeId: homeId,
      homeName: homeName,
      inviterName: inviterName,
      onRequest: (r, emojis) {
        mine = true;
        return _onRequest(r, emojis);
      },
      admitter: HostAdmitter(
        db,
        ref.read(secureStoreProvider),
        ref.read(membershipLogProvider),
        SyncStore(db),
        homeId,
      ),
      onProgress: (sent, total) {
        if (_disposed) return;
        state = state.copyWith(pct: total == 0 ? 100 : sent * 100 ~/ total);
      },
    );

    final res = await host.handle(conn);
    if (_disposed) return;
    if (res == null && !mine) return;

    if (res != null) {
      var showTip = false;
      final adminRow = await db
          .customSelect(
            "SELECT COUNT(*) AS n FROM members WHERE home_id = ? AND deleted = 0 AND status = 'active' AND role = 'admin'",
            variables: [Variable.withString(homeId)],
          )
          .getSingle();
      final adminCount = adminRow.data['n'] as int;
      final prefs = ref.read(prefsProvider);
      final tipKey = 'inviteTipsShown_$homeId';
      if (adminCount == 1 && !prefs.getFlag(tipKey)) {
        await prefs.setFlag(tipKey, true);
        showTip = true;
      }
      if (_disposed) return;
      state = state.copyWith(
        stage: InviteStage.done,
        joinedName: res.name,
        showSecondAdminTip: showTip,
      );
    } else {
      final currentInv = state.invite;
      final stillOpen =
          currentInv != null && currentInv.isOpen(DateTime.now());
      state = state.copyWith(
        stage: stillOpen ? InviteStage.waiting : InviteStage.expired,
        clearRequest: true,
      );
    }
  }

  Future<String?> _onRequest(JoinRequest r, List<String> emojis) {
    final c = Completer<String?>();
    _decision = c;
    state = state.copyWith(
      stage: InviteStage.request,
      request: r,
      emojis: emojis,
    );
    return c.future;
  }

  void allow(String role) {
    state = state.copyWith(stage: InviteStage.copying, pct: 0);
    if (_decision != null && !_decision!.isCompleted) {
      _decision!.complete(role);
    }
    _decision = null;
  }

  Future<void> deny() async {
    if (_decision != null && !_decision!.isCompleted) {
      _decision!.complete(null);
    }
    _decision = null;
    await newInvite();
  }

  void expireNow() {
    if (state.stage == InviteStage.waiting) {
      state = state.copyWith(stage: InviteStage.expired);
    }
  }

  Future<void> pause() async {
    _gen++;
    if (_decision != null && !_decision!.isCompleted) {
      _decision!.complete(null);
    }
    _decision = null;
    await _server?.stop();
    _server = null;
  }

  Future<void> newInvite() async {
    await _server?.stop();
    _server = null;
    state = const InviteUi();
    await start();
  }
}
