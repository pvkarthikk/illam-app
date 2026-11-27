import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/core/data/prefs/key_value_store.dart';
import 'package:nm_flat/core/domain/money_widget_snapshot.dart';
import 'package:nm_flat/core/domain/widget_snapshot.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/widgets/widget_actions.dart';
import 'package:nm_flat/core/widgets/widget_bridge.dart';

/// Headless entrypoint invoked by Android AppWidgets when the app is closed.
Future<void> runWidgetBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  ProviderContainer? container;
  var anyWrote = false;
  try {
    final store = await SharedPrefsStore.create();
    if (store.getString('currentHomeId') == null) {
      final pending = await WidgetBridge.instance.takePendingActions();
      await WidgetBridge.instance.ackPendingActions([
        for (final a in pending)
          if (a['id'] is String && (a['id'] as String).isNotEmpty)
            a['id']! as String,
      ]);
      final today = Dates.today(SystemClock());
      await WidgetBridge.instance.updateSnapshots(
        staff: StaffWidgetSnapshot.noHome(date: today).toJson(),
        todos: TodoWidgetSnapshot.noHome(date: today).toJson(),
        money: MoneyWidgetSnapshot.noHome(date: today).toJson(),
      );
      return;
    }

    container = await openBackgroundContainer();
    for (var pass = 0; pass < 5; pass++) {
      final wrote = await drainPendingWidgetActions(container.read);
      if (wrote) anyWrote = true;
      final remaining = await WidgetBridge.instance.takePendingActions();
      if (remaining.isEmpty) break;
    }
    await pushWidgetSnapshots(container.read);
    if (anyWrote) {
      try {
        await Workmanager().registerOneOffTask(
          'nm.sync.once',
          'nm.sync',
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      } on Object {
        // Ignore if WorkManager cannot be scheduled from headless isolate.
      }
    }
  } on Object {
    // Ignore bootstrap failures so native runner can finish cleanly.
  } finally {
    if (container != null) {
      try {
        await container.read(dbProvider).close();
      } on Object {
        // Ignore DB close error.
      }
      container.dispose();
    }
    await WidgetBridge.instance.notifyBackgroundDone();
  }
}
