import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/backup_runner.dart';
import 'package:nm_flat/core/data/prefs/notification_prefs.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/backup/backup_texts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

const backupTaskName = 'nm.backup';
const int _dayMs = 24 * 60 * 60 * 1000;

int backupIntervalMs(String frequency) => switch (frequency) {
  'daily' => _dayMs,
  'monthly' => 30 * _dayMs,
  _ => 7 * _dayMs,
};

Duration _frequencyDuration(String frequency) => switch (frequency) {
  'daily' => const Duration(hours: 24),
  'monthly' => const Duration(days: 30),
  _ => const Duration(days: 7),
};

Future<void> scheduleBackup(String homeId, BackupConfig c) async {
  try {
    await Workmanager().registerPeriodicTask(
      'nm.backup.$homeId',
      backupTaskName,
      frequency: _frequencyDuration(c.frequency),
      constraints: Constraints(
        networkType: c.wifiOnly
            ? NetworkType.unmetered
            : NetworkType.notRequired,
        requiresCharging: c.chargingOnly,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
      inputData: {'homeId': homeId},
    );
  } on Object {
    // WorkManager channel absent in headless tests.
  }
}

Future<void> cancelBackup(String homeId) async {
  try {
    await Workmanager().cancelByUniqueName('nm.backup.$homeId');
  } on Object {
    // WorkManager channel absent in headless tests.
  }
}

/// Returns a human-readable failure/staleness reason if [c] needs attention, else `null`.
String? backupAttentionReason(AppLocalizations l, BackupConfig c, int nowMs) {
  if (c.destinations.isEmpty || c.password == null || c.password!.isEmpty) {
    return null;
  }

  int? newestSuccess;
  for (final d in c.destinations) {
    final s = d.lastSuccessAt;
    if (s != null && (newestSuccess == null || s > newestSuccess)) {
      newestSuccess = s;
    }
  }

  final isStale =
      newestSuccess != null &&
      nowMs - newestSuccess > 2 * backupIntervalMs(c.frequency);
  final hasFailingDest = c.destinations.any((d) => d.failures >= 2);
  if (c.consecutiveFailures < 2 && !hasFailingDest && !isStale) return null;

  final failing = [
    for (final d in c.destinations)
      if (d.lastResult != null && d.lastResult != 'ok') d,
  ]..sort((a, b) => (b.lastSuccessAt ?? 0).compareTo(a.lastSuccessAt ?? 0));

  if (failing.isNotEmpty) {
    final d = failing.first;
    final short = providerShort(l, d.kind);
    if (d.lastResult == 'auth') {
      return d.kind == 'folder'
          ? l.backupErrNoPermission
          : l.backupReasonAuth(short);
    }
    if (d.lastResult == 'full') {
      return l.backupReasonFull(short);
    }
    newestSuccess = d.lastSuccessAt;
  }

  if (newestSuccess == null) return l.homeBackupNone;
  final days = max(0, (nowMs - newestSuccess) ~/ _dayMs);
  return l.backupStatusStale(days);
}

Future<void> checkBackupAttention(Reader read, String homeId, int nowMs) async {
  if (!read(notificationPrefsProvider).backup) return;
  final store = read(backupConfigStoreProvider);
  final config = await store.load(homeId);
  if (config.lastAttentionAt != null &&
      nowMs - config.lastAttentionAt! < _dayMs) {
    return;
  }

  final l = lookupAppLocalizations(const Locale('en'));
  final reason = backupAttentionReason(l, config, nowMs);
  if (reason == null) return;

  try {
    await plugin.show(
      id: stableId('backup.$homeId'),
      title: l.notifAppName,
      body: l.backupAttention(reason),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'backup',
          l.notifChannelBackup,
          icon: 'ic_stat_nest',
        ),
      ),
      payload: jsonEncode({'route': Routes.backup}),
    );
  } on Object {
    // Notification plugin channel absent in headless tests.
  }

  config.lastAttentionAt = nowMs;
  await store.save(homeId, config);
}

Future<bool> runBackupTask(Reader read, Map<String, dynamic> input) async {
  final homeId = input['homeId'] as String?;
  if (homeId == null || homeId.isEmpty) return true;
  final res = await BackupRunner(read).run(homeId);
  await checkBackupAttention(read, homeId, read(clockProvider).nowMs);
  return res != BackupRunResult.failed;
}
