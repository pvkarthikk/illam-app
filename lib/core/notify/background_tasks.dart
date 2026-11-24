import 'dart:convert';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/core/backup/backup_schedule.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/db/db_key.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/prefs/notification_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/domain/bills.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/reminder_rules.dart';
import 'package:nm_flat/core/domain/routine_state.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/notify/notification_actions.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/background_sync.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse r) async {
  DartPluginRegistrant.ensureInitialized();
  final container = await openBackgroundContainer();
  try {
    if (container.read(prefsProvider).currentHomeId != null) {
      await handleNotificationAction(container.read, r);
    }
  } finally {
    await container.read(dbProvider).close();
    container.dispose();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    final container = await openBackgroundContainer();
    try {
      switch (task) {
        case 'nm.plan':
          await planAndEnqueue(container.read);
        case 'nm.show':
          await showIfStillValid(
            container.read,
            inputData ?? const <String, dynamic>{},
          );
        case 'nm.sync':
          await runBackgroundSync(container.read);
        case backupTaskName:
          return await runBackupTask(
            container.read,
            inputData ?? const <String, dynamic>{},
          );
      }
      return true;
    } finally {
      await container.read(dbProvider).close();
      container.dispose();
    }
  });
}

Future<ProviderContainer> openBackgroundContainer() async {
  await initializeDateFormatting();
  final prefs = await DevicePrefs.open();
  await prefs.reload();
  final secure = FlutterSecureStore();
  final keyHex = await DbKey.loadOrCreate(secure);
  final container = ProviderContainer(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(NestDatabase.open(keyHex: keyHex)),
      secureStoreProvider.overrideWithValue(secure),
    ],
  );
  await container.read(currentHomeIdProvider.future);
  return container;
}

Future<ReminderInputs?> loadReminderInputs(Reader read) async {
  final homeId = await read(currentHomeIdProvider.future);
  if (homeId == null) return null;

  final clock = read(clockProvider);
  final now = clock.now();
  final today = Dates.today(clock);

  final staffRows = await read(activeStaffProvider.future);
  final visits = await read(visitsTodayProvider.future);
  final leaves = await read(leavesTodayProvider.future);
  final routines = await read(routinesProvider.future);
  final todos = await read(todosProvider.future);
  final bills = await read(billsProvider.future);
  final month = Dates.month(today);
  final monthExpenses = await read(monthExpensesProvider(month).future);
  await read(monthExpensesProvider(prevMonth(month)).future);
  final statuses = await read(billStatusesProvider.future);

  final visitStarts = <String, List<DateTime>>{};
  for (final v in visits) {
    final sid = v.staffId;
    final inAt = v.inAt;
    if (sid != null && inAt != null) {
      (visitStarts[sid] ??= []).add(DateTime.fromMillisecondsSinceEpoch(inAt));
    }
  }

  final onLeaveToday = <String>{
    for (final l in leaves)
      if (l.staffId != null) l.staffId!,
  };

  final dueTitles = <String>[
    for (final r in routines)
      if (routineState(
            lastDone: r.lastDone,
            everyDays: r.everyDays,
            today: today,
          ).left <=
          0)
        r.name,
    for (final t in todos)
      if (!t.done && t.due.isNotEmpty && Dates.daysBetween(t.due, today) >= 0)
        t.title,
  ];
  final dueCount = dueTitles.length;

  final statusById = {for (final (b, st) in statuses) b.id: st};
  final billInfos = <BillInfo>[
    for (final b in bills)
      if (statusById[b.id] case final st?)
        BillInfo(
          id: b.id,
          name: b.name,
          method: b.method,
          dueDate: st.dueDate,
          firstDueMonth: b.firstDueMonth,
          usualPaise: b.usualAmountPaise,
          active: b.active,
          remind: b.remind,
          paidThisMonth: st.kind == BillDue.paid,
        ),
  ];

  final me = read(myMemberIdProvider);
  final iAddedSpendToday = monthExpenses.any(
    (e) => e.addedBy == me && e.date == today,
  );
  final notif = read(notificationPrefsProvider);
  final workDaysByStaff = <String, List<int>>{};
  for (final s in staffRows) {
    final ruleRows = await read(salaryRulesProvider(s.id).future);
    final days = workDaysForMonth(
      [for (final r in ruleRows) rulesFromRow(r)],
      month,
    );
    if (days != null) workDaysByStaff[s.id] = days;
  }

  return ReminderInputs(
    today: today,
    now: now,
    staff: [
      for (final s in staffRows)
        StaffInfo(
          id: s.id,
          name: s.name ?? '',
          startDate: s.startDate ?? '',
          endDate: s.endDate,
          active: s.active,
          workDays: workDaysByStaff[s.id] ?? parseWorkDays(s.workDays),
          expectedTimes: parseTimes(s.expectedTimes),
        ),
    ],
    visitStartsToday: visitStarts,
    onLeaveToday: onLeaveToday,
    dueCount: dueCount,
    dueTitles: dueTitles,
    bills: billInfos,
    iAddedSpendToday: iAddedSpendToday,
    arrivalOn: notif.arrival,
    digestOn: notif.digest,
    billOn: notif.billDue,
    eveningOn: notif.evening,
  );
}

Future<void> planAndEnqueue(Reader read) async {
  await read(prefsProvider).reload();
  final inputs = await loadReminderInputs(read);
  if (inputs == null) return;

  final prefs = read(prefsProvider);
  for (final r in planToday(inputs)) {
    if (prefs.wasNotifShown(r.key)) continue;
    final delay = r.at.difference(inputs.now);
    if (delay < const Duration(minutes: -30)) continue;
    await Workmanager().registerOneOffTask(
      'nm.show.${r.key}',
      'nm.show',
      inputData: {'key': r.key},
      initialDelay: delay.isNegative ? Duration.zero : delay,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      tag: 'nm.show',
    );
  }

  final active = await plugin.getActiveNotifications();
  for (final n in active) {
    final payload = n.payload;
    final id = n.id;
    if (payload == null || id == null) continue;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['kind'] == ReminderKind.arrival.name) {
        final key = data['key'] as String? ?? '';
        final probe = PlannedReminder(
          key,
          ReminderKind.arrival,
          inputs.now,
          const {},
        );
        if (!stillValid(probe, inputs)) {
          await plugin.cancel(id: id);
        }
      }
    } catch (_) {}
  }
}

Future<void> showIfStillValid(Reader read, Map<String, dynamic> input) async {
  await read(prefsProvider).reload();
  final inputs = await loadReminderInputs(read);
  if (inputs == null) return;
  final key = input['key'] as String?;
  if (key == null) return;

  final r = planToday(inputs).where((p) => p.key == key).firstOrNull;
  if (r == null) return;
  final prefs = read(prefsProvider);
  if (!stillValid(r, inputs) || prefs.wasNotifShown(r.key)) return;

  await showReminder(r, enLocalizations());
  await prefs.markNotifShown(r.key, inputs.today);
}

Future<int> runRemindersNow(Reader read) async {
  await read(prefsProvider).clearNotifShown();
  final inputs = await loadReminderInputs(read);
  if (inputs == null) return 0;

  final prefs = read(prefsProvider);
  final l10n = enLocalizations();
  var shown = 0;
  for (final r in planToday(inputs)) {
    if (!stillValid(r, inputs)) continue;
    await showReminder(r, l10n);
    await prefs.markNotifShown(r.key, inputs.today);
    shown++;
  }
  return shown;
}
