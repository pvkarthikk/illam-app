import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_runner.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';
import 'package:nm_flat/features/backup/backup_setup_parts.dart';
import 'package:nm_flat/features/onboarding/restore_controller.dart';

final backupConfigProvider = FutureProvider<BackupConfig?>((ref) async {
  final homeId = ref.watch(currentHomeIdProvider).value;
  if (homeId == null) return null;
  return ref.read(backupConfigStoreProvider).load(homeId);
});

enum ConnectNext { askPassword, ranBackup, restore }

class BackupUi {
  const BackupUi({
    this.running = false,
    this.pct = 0,
    this.connectBusy = false,
    this.connectError,
    this.localCopy = false,
  });

  final bool running;
  final int pct;
  final bool connectBusy;
  final String? connectError;
  final bool localCopy;

  BackupUi copyWith({
    bool? running,
    int? pct,
    bool? connectBusy,
    String? connectError,
    bool clearConnectError = false,
    bool? localCopy,
  }) => BackupUi(
    running: running ?? this.running,
    pct: pct ?? this.pct,
    connectBusy: connectBusy ?? this.connectBusy,
    connectError: clearConnectError
        ? null
        : (connectError ?? this.connectError),
    localCopy: localCopy ?? this.localCopy,
  );
}

class BackupController extends Notifier<BackupUi> {
  @override
  BackupUi build() => const BackupUi();

  void setConnectState({
    bool? busy,
    String? error,
    bool clearError = false,
    bool? localCopy,
  }) {
    state = state.copyWith(
      connectBusy: busy,
      connectError: error,
      clearConnectError: clearError,
      localCopy: localCopy,
    );
  }

  Future<ConnectNext> onConnected(
    DestinationConfig c,
    ConnectMode mode,
  ) async {
    if (mode == ConnectMode.restore) {
      await ref.read(restoreControllerProvider.notifier).setDestination(c);
      return ConnectNext.restore;
    }

    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId ??
        '';
    final store = ref.read(backupConfigStoreProvider);
    final config = await store.load(homeId);

    if (mode == ConnectMode.reauth) {
      final idx = config.destinations.indexWhere((d) => d.destId == c.destId);
      if (idx >= 0) {
        config.destinations[idx] = c;
      } else if (config.destinations.length < BackupConfig.maxDestinations) {
        config.destinations.add(c);
      }
      await store.save(homeId, config);
      ref.invalidate(backupConfigProvider);
      await runNow();
      return ConnectNext.ranBackup;
    }

    if (config.destinations.length < BackupConfig.maxDestinations) {
      config.destinations.add(c);
    }
    await store.save(homeId, config);
    ref.invalidate(backupConfigProvider);

    final pw = config.password;
    if (pw == null || pw.isEmpty) {
      return ConnectNext.askPassword;
    }
    await runNow();
    return ConnectNext.ranBackup;
  }

  Future<void> _showProgress(String homeId, String homeName, int pct) async {
    try {
      final l = enLocalizations();
      await plugin.show(
        id: stableId('backup.progress.$homeId'),
        title: l.backupProgressNotif(homeName),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'backup',
            l.notifChannelBackup,
            icon: 'ic_stat_nest',
            onlyAlertOnce: true,
            ongoing: true,
            silent: true,
            showProgress: true,
            maxProgress: 100,
            progress: pct.clamp(0, 100),
          ),
        ),
      );
    } on Object {
      // Notification plugin absent in headless tests.
    }
  }

  Future<void> _cancelProgress(String homeId) async {
    try {
      await plugin.cancel(id: stableId('backup.progress.$homeId'));
    } on Object {
      // Notification plugin absent in headless tests.
    }
  }

  Future<BackupRunResult> runNow() async {
    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId ??
        '';
    if (homeId.isEmpty) return BackupRunResult.notSetUp;

    final homeName = ref.read(currentHomeProvider).value?.name ?? '';
    state = state.copyWith(running: true, pct: 0);
    unawaited(_showProgress(homeId, homeName, 0));

    try {
      return await BackupRunner(ref.read).run(
        homeId,
        manual: true,
        onProgress: (pct) {
          state = state.copyWith(pct: pct);
          unawaited(_showProgress(homeId, homeName, pct));
        },
      );
    } finally {
      await _cancelProgress(homeId);
      state = state.copyWith(running: false);
      ref.invalidate(backupConfigProvider);
      ref.invalidate(recoveryKitsViewProvider);
      ref.invalidate(myKitDeadProvider);
    }
  }
}

final backupControllerProvider =
    NotifierProvider<BackupController, BackupUi>(BackupController.new);

class KitView {
  const KitView({
    required this.pub,
    required this.memberId,
    required this.name,
    required this.model,
    required this.role,
    required this.madeAt,
    required this.thisPhone,
  });

  final String pub;
  final String memberId;
  final String name;
  final String model;
  final String role;
  final int madeAt;
  final bool thisPhone;
}

final recoveryKitsViewProvider = FutureProvider<List<KitView>>((ref) async {
  final homeId = ref.watch(currentHomeIdProvider).value;
  if (homeId == null) return const [];
  final r = await ref.read(membershipLogProvider).replayAndProject(homeId);
  final myDeviceId = ref.read(prefsProvider).deviceId;

  final out = <KitView>[];
  for (final kit in r.liveKits.values) {
    final m = r.members[kit.memberId];
    final d = r.devices[kit.deviceId];
    final full = m?.name ?? '';
    final name = full.isEmpty ? '' : Names.firstName(full);
    out.add(
      KitView(
        pub: kit.pub,
        memberId: kit.memberId,
        name: name,
        model: d?.model ?? '',
        role: m?.role ?? 'member',
        madeAt: hlcWall(kit.addedHlc),
        thisPhone: kit.deviceId == myDeviceId,
      ),
    );
  }
  out.sort((a, b) => b.madeAt.compareTo(a.madeAt));
  return out;
});

final myKitDeadProvider = FutureProvider<bool>((ref) async {
  final homeId = ref.watch(currentHomeIdProvider).value;
  final cfg = await ref.watch(backupConfigProvider.future);
  if (homeId == null || cfg == null || cfg.kit == null) return false;
  final pub = cfg.kit!['pub'];
  if (pub is! String || pub.isEmpty) return false;
  final r = await ref.read(membershipLogProvider).replayState(homeId);
  return !r.liveKits.containsKey(pub);
});
