import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';

import 'package:nm_flat/core/domain/reminder_rules.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/notify/notification_actions.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';
import 'package:nm_flat/l10n/gen/app_localizations_en.dart';

final plugin = FlutterLocalNotificationsPlugin();

typedef Reader = T Function<T>(ProviderListenable<T> provider);

AndroidFlutterLocalNotificationsPlugin? androidNotificationsPlugin() {
  try {
    return plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  } catch (_) {
    return null;
  }
}

int stableId(String key) {
  var h = 0x811c9dc5;
  for (final c in key.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0x7fffffff;
  }
  return h;
}

Future<void> initNotifications({
  required void Function(NotificationResponse) onResponse,
}) async {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('ic_stat_nest'),
  );
  await plugin.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: onResponse,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final android = androidNotificationsPlugin();
  if (android == null) return;

  final AppLocalizations l10n = AppLocalizationsEn();
  final channels = [
    AndroidNotificationChannel(
      'staff',
      l10n.notifChannelStaff,
      importance: Importance.defaultImportance,
    ),
    AndroidNotificationChannel(
      'tasks',
      l10n.notifChannelTasks,
      importance: Importance.defaultImportance,
    ),
    AndroidNotificationChannel(
      'money',
      l10n.notifChannelMoney,
      importance: Importance.defaultImportance,
    ),
    AndroidNotificationChannel(
      'backup',
      l10n.notifChannelBackup,
      importance: Importance.defaultImportance,
    ),
    AndroidNotificationChannel(
      'home',
      l10n.notifChannelHome,
      importance: Importance.defaultImportance,
    ),
  ];
  for (final ch in channels) {
    await android.createNotificationChannel(ch);
  }
}

Future<void> showReminder(PlannedReminder r, AppLocalizations l10n) async {
  final String channelId;
  final String channelName;
  final String body;
  final String route;
  final List<AndroidNotificationAction> actions;

  switch (r.kind) {
    case ReminderKind.arrival:
      channelId = 'staff';
      channelName = l10n.notifChannelStaff;
      final name = r.data['name'] as String? ?? '';
      final hhmm = r.data['time'] as String? ?? '09:00';
      final parts = hhmm.split(':');
      final h = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 9) : 9;
      final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      final day = Dates.parse('2026-01-01');
      final timeLabel = Formatters.time12(
        DateTime(day.year, day.month, day.day, h, m),
      );
      body = l10n.notifArrivalBody(name, timeLabel);
      route = Routes.today;
      actions = [
        AndroidNotificationAction('mark_in', l10n.notifMarkInNow),
        AndroidNotificationAction('leave_today', l10n.notifOnLeaveToday),
      ];
    case ReminderKind.digest:
      channelId = 'tasks';
      channelName = l10n.notifChannelTasks;
      final count = r.data['count'] as int? ?? 0;
      final list =
          (r.data['titles'] as List?)?.whereType<String>().toList() ??
          const <String>[];
      body = l10n.notifDigestBody(count, list.take(2).join(', '));
      route = Routes.tasks;
      actions = const [];
    case ReminderKind.bill:
      channelId = 'money';
      channelName = l10n.notifChannelMoney;
      final billName = r.data['name'] as String? ?? '';
      final usual = r.data['usual'] as int? ?? 0;
      final formatted = Money.format(usual);
      body = l10n.notifBillBody(billName, formatted);
      route = Routes.money;
      actions = [
        AndroidNotificationAction('bill_paid', l10n.notifPaidAmount(formatted)),
        AndroidNotificationAction(
          'open',
          l10n.notifOpen,
          showsUserInterface: true,
        ),
      ];
    case ReminderKind.evening:
      channelId = 'money';
      channelName = l10n.notifChannelMoney;
      body = l10n.notifEveningBody;
      route = '${Routes.money}?add=1';
      actions = const [];
  }

  final payload = jsonEncode(<String, Object?>{
    ...r.data,
    'key': r.key,
    'kind': r.kind.name,
    'route': route,
  });

  await plugin.show(
    id: stableId(r.key),
    title: l10n.notifAppName,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        icon: 'ic_stat_nest',
        actions: actions,
      ),
    ),
    payload: payload,
  );
}

class NotificationRouter {
  NotificationRouter._();

  static final instance = NotificationRouter._();

  GoRouter? router;
  Reader? read;
  String? pendingRoute;

  void attach(GoRouter r, Reader reader) {
    router = r;
    read = reader;
    final pending = pendingRoute;
    if (pending != null) {
      pendingRoute = null;
      r.go(pending);
    }
  }

  void handle(NotificationResponse resp) {
    final raw = resp.payload;
    if (raw == null || raw.isEmpty) return;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    if (resp.actionId == null || resp.actionId == 'open') {
      final route = data['route'] as String?;
      if (route == null || route.isEmpty) return;
      if (router != null) {
        router!.go(route);
      } else {
        pendingRoute = route;
      }
      return;
    }

    final r = read;
    if (r != null) {
      unawaited(handleNotificationAction(r, resp));
    }
  }
}

AppLocalizations enLocalizations() => lookupAppLocalizations(const Locale('en'));
