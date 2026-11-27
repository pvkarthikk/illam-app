import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/backup/backup_codec.dart';
import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_schedule.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/backup/restore_service.dart';
import 'package:nm_flat/core/backup/separate_copy.dart';
import 'package:nm_flat/core/backup/snapshot.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/membership_replay.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';

class FoundBackup {
  const FoundBackup(this.file, this.header);

  final RemoteBackupFile file;
  final BackupHeader header;
}

class RestoreUi {
  const RestoreUi({
    this.dest,
    this.found = const [],
    this.loading = false,
    this.selected,
    this.error,
    this.step = 0,
    this.snapshot,
    this.password,
    this.outcome,
    this.deadAtMs,
    this.navigatedHomeId,
  });

  final DestinationConfig? dest;
  final List<FoundBackup> found;
  final bool loading;
  final String? selected;
  final String? error;
  final int step;
  final Snapshot? snapshot;
  final String? password;
  final RestoreOutcome? outcome;
  final int? deadAtMs;
  final String? navigatedHomeId;

  RestoreUi copyWith({
    DestinationConfig? dest,
    List<FoundBackup>? found,
    bool? loading,
    String? selected,
    bool clearSelected = false,
    String? error,
    bool clearError = false,
    int? step,
    Snapshot? snapshot,
    bool clearSnapshot = false,
    String? password,
    bool clearPassword = false,
    RestoreOutcome? outcome,
    bool clearOutcome = false,
    int? deadAtMs,
    bool clearDeadAtMs = false,
    String? navigatedHomeId,
    bool clearNavigatedHomeId = false,
  }) => RestoreUi(
    dest: dest ?? this.dest,
    found: found ?? this.found,
    loading: loading ?? this.loading,
    selected: clearSelected ? null : (selected ?? this.selected),
    error: clearError ? null : (error ?? this.error),
    step: step ?? this.step,
    snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
    password: clearPassword ? null : (password ?? this.password),
    outcome: clearOutcome ? null : (outcome ?? this.outcome),
    deadAtMs: clearDeadAtMs ? null : (deadAtMs ?? this.deadAtMs),
    navigatedHomeId: clearNavigatedHomeId
        ? null
        : (navigatedHomeId ?? this.navigatedHomeId),
  );
}

class RestoreController extends Notifier<RestoreUi> {
  @override
  RestoreUi build() => const RestoreUi();

  void reset() => state = const RestoreUi();

  Future<void> setDestination(DestinationConfig c) async {
    state = RestoreUi(dest: c);
    await load();
  }

  void selectFile(String name) => state = state.copyWith(selected: name);

  Future<void> load() async {
    final destCfg = state.dest;
    if (destCfg == null) return;
    state = state.copyWith(
      loading: true,
      clearError: true,
      clearSnapshot: true,
      clearPassword: true,
      clearOutcome: true,
      clearDeadAtMs: true,
      clearNavigatedHomeId: true,
      found: const [],
      clearSelected: true,
    );

    try {
      final dest = await destinationFor(destCfg, ref.read(secureStoreProvider));
      final files = await dest.list();
      Future<FoundBackup?> readOne(RemoteBackupFile f) async {
        try {
          final head = await dest.readHead(f.name, maxHeaderLength);
          final parsed = parseHeader(
            head,
            fileLength: f.size > 0 ? f.size : null,
          );
          return FoundBackup(f, parsed.header);
        } on Object {
          // Skip non-backups, newer formats, or unreadable headers.
          return null;
        }
      }

      final entries = <FoundBackup>[];
      for (var i = 0; i < files.length; i += 4) {
        final end = i + 4 < files.length ? i + 4 : files.length;
        final batch = await Future.wait([
          for (var j = i; j < end; j++) readOne(files[j]),
        ]);
        for (final entry in batch) {
          if (entry != null) entries.add(entry);
        }
      }
      entries.sort((a, b) => b.header.createdAt.compareTo(a.header.createdAt));
      state = state.copyWith(
        loading: false,
        found: entries,
        selected: entries.isEmpty ? null : entries.first.file.name,
      );
    } on DestinationException {
      state = state.copyWith(loading: false, error: 'restoreDownloadFail');
    } on Object {
      state = state.copyWith(loading: false, error: 'restoreDownloadFail');
    }
  }

  Future<bool> unlock(String password) async {
    final destCfg = state.dest;
    final name = state.selected;
    if (destCfg == null || name == null) return false;

    state = state.copyWith(
      clearError: true,
      clearSnapshot: true,
      clearPassword: true,
      clearOutcome: true,
      clearDeadAtMs: true,
      clearNavigatedHomeId: true,
      step: 0,
    );

    try {
      final dest = await destinationFor(destCfg, ref.read(secureStoreProvider));
      final bytes = await dest.download(name);
      state = state.copyWith(step: 1);
      final decoded = await BackupCodec.decode(bytes, password);
      final snap = await Snapshot.decode(decoded.json);
      state = state.copyWith(snapshot: snap, password: password, step: 2);
      return true;
    } on DestinationException {
      state = state.copyWith(error: 'restoreDownloadFail');
      return false;
    } on BackupFormatException catch (e) {
      if (e.error == BackupError.wrongPassword) {
        return false;
      }
      state = state.copyWith(error: 'backupDamaged');
      return false;
    } on Object {
      state = state.copyWith(error: 'backupDamaged');
      return false;
    }
  }

  Future<void> runRestore() async {
    final snap = state.snapshot;
    final pw = state.password;
    final dest = state.dest;
    if (snap == null || pw == null || dest == null) return;

    try {
      final outcome = await RestoreService(ref.read).restore(
        snap,
        pw,
        dest,
        onStep: (s) => state = state.copyWith(step: s),
      );
      if (outcome == RestoreOutcome.separateCopy) {
        final newHomeId = await keepAsSeparateCopy();
        state = state.copyWith(
          step: 4,
          outcome: outcome,
          navigatedHomeId: newHomeId,
        );
        return;
      }

      int? deadAtMs;
      if (outcome == RestoreOutcome.deadKit) {
        final kitPub = snap.recoveryKit?['pub'] as String?;
        if (kitPub != null) {
          final replay = await ref
              .read(membershipLogProvider)
              .replayState(snap.homeId);
          final dead = replay.deadReason(kitPub);
          if (dead != null && dead.hlc.isNotEmpty) {
            deadAtMs = hlcWall(dead.hlc);
          }
        }
        deadAtMs ??= ref.read(clockProvider).nowMs;
        await ref
            .read(prefsProvider)
            .setText(
              'recoverDead_${snap.homeId}',
              jsonEncode({'reason': 'deadKit', 'at': deadAtMs}),
            );
      }

      state = state.copyWith(
        step: 4,
        outcome: outcome,
        deadAtMs: deadAtMs,
      );
    } on Object {
      state = state.copyWith(error: 'backupDamaged');
    }
  }

  Future<void> finishRestored({required bool keepBackingUp}) async {
    final snap = state.snapshot;
    final pw = state.password;
    final dest = state.dest;
    if (snap == null) return;
    if (keepBackingUp && dest != null && pw != null && pw.isNotEmpty) {
      final store = ref.read(backupConfigStoreProvider);
      final cfg = await store.load(snap.homeId);
      if (!cfg.destinations.any((d) => d.destId == dest.destId)) {
        cfg.destinations.add(dest);
      }
      cfg.password = pw;
      cfg.passwordSetAt = ref.read(clockProvider).nowMs;
      cfg.frequency = 'weekly';
      cfg.wifiOnly = true;
      cfg.chargingOnly = true;
      cfg.keep = 10;
      await store.save(snap.homeId, cfg);
      await scheduleBackup(snap.homeId, cfg);
    }
    await ref.read(prefsProvider).setCurrentHomeId(snap.homeId);
    state = state.copyWith(navigatedHomeId: snap.homeId);
  }

  Future<void> openAlreadyHere() async {
    final snap = state.snapshot;
    if (snap == null) return;
    await ref.read(prefsProvider).setCurrentHomeId(snap.homeId);
    state = state.copyWith(navigatedHomeId: snap.homeId);
  }

  Future<String> keepAsSeparateCopy() async {
    final snap = state.snapshot!;
    final l = lookupUserLocalizations(ref.read(prefsProvider));
    final dateStr = Formatters.safeDateFormat(
      'd MMM yyyy',
      l.localeName,
    ).format(DateTime.fromMillisecondsSinceEpoch(snap.createdAt));
    final newName = l.restoreSeparateName(snap.homeName, dateStr);
    final fallbackMemberId =
        (snap.recoveryKit?['memberId'] as String?) ??
        (snap.by['memberId'] as String?);
    final fallbackName = snap.by['name'] as String?;
    final newHomeId = await SeparateCopy(ref.read).make(
      snap.homeId,
      newHomeName: newName,
      fallbackMemberId: fallbackMemberId,
      fallbackName: fallbackName,
    );
    state = state.copyWith(navigatedHomeId: newHomeId);
    return newHomeId;
  }

  Future<void> removeDeadRestore() async {
    final snap = state.snapshot;
    if (snap == null) return;
    await ref.read(homeEraserProvider).erase(snap.homeId);
    await ref.read(prefsProvider).setText('recoverDead_${snap.homeId}', null);
    reset();
  }
}

final restoreControllerProvider =
    NotifierProvider<RestoreController, RestoreUi>(RestoreController.new);
