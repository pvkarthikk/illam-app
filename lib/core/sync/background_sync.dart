import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/control_dialer.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

const _threeDaysMs = 3 * 24 * 60 * 60 * 1000;

/// Runs one background sync pass, nudges after 3 days offline, and dials queued control ops.
Future<void> runBackgroundSync(Reader read) async {
  await _syncHomeAndNudge(read);
  try {
    await read(controlDialerProvider).runOnce();
  } on Object {
    // Retry next run.
  }
}

Future<void> _syncHomeAndNudge(Reader read) async {
  try {
    await read(syncEngineProvider).runOnce(budget: const Duration(seconds: 30));
    try {
      await read(remoteSyncEngineProvider).syncNow();
    } on Object {
      // Best-effort remote sync in background.
    }

    final prefs = read(prefsProvider);
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = read(dbProvider);
    final keys = await read(deviceKeysProvider.future);
    final activeDevices = await (db.select(
      db.memberDevices,
    )..where((d) => d.homeId.equals(homeId) & d.active.equals(true))).get();
    final hasOtherDevices = activeDevices.any(
      (d) => d.deviceId != keys.deviceId,
    );
    if (!hasOtherDevices) return;

    final peers = await SyncStore(db).peers(homeId);
    var newestSyncAt = 0;
    for (final p in peers) {
      if (p.lastSyncAt > newestSyncAt) newestSyncAt = p.lastSyncAt;
    }

    int? earliestOtherAddedAt;
    for (final d in activeDevices) {
      if (d.deviceId == keys.deviceId) {
        if (d.addedAt > newestSyncAt) newestSyncAt = d.addedAt;
      } else {
        if (earliestOtherAddedAt == null || d.addedAt < earliestOtherAddedAt) {
          earliestOtherAddedAt = d.addedAt;
        }
      }
    }
    if (earliestOtherAddedAt != null && earliestOtherAddedAt > newestSyncAt) {
      newestSyncAt = earliestOtherAddedAt;
    }

    final now = read(clockProvider).nowMs;
    if (now - newestSyncAt <= _threeDaysMs) return;
    if (now - prefs.lastOutOfSyncNoticeAt <= _threeDaysMs) return;

    final l = lookupAppLocalizations(const Locale('en'));
    await plugin.show(
      id: stableId('outOfSync'),
      title: l.notifAppName,
      body: l.notifOutOfSync,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'home',
          l.notifChannelHome,
          icon: 'ic_stat_nest',
        ),
      ),
      payload: jsonEncode({'route': '/home'}),
    );
    await prefs.setLastOutOfSyncNoticeAt(now);
  } on Object {
    // Never crash the WorkManager background worker.
  }
}
