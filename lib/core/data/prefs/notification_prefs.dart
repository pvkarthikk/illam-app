import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/providers.dart';

class NotificationPrefs {
  const NotificationPrefs({
    required this.arrival,
    required this.digest,
    required this.billDue,
    required this.evening,
    required this.backup,
  });

  final bool arrival;
  final bool digest;
  final bool billDue;
  final bool evening;
  final bool backup;

  NotificationPrefs copyWith({
    bool? arrival,
    bool? digest,
    bool? billDue,
    bool? evening,
    bool? backup,
  }) => NotificationPrefs(
    arrival: arrival ?? this.arrival,
    digest: digest ?? this.digest,
    billDue: billDue ?? this.billDue,
    evening: evening ?? this.evening,
    backup: backup ?? this.backup,
  );
}

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() {
    final prefs = ref.read(prefsProvider);
    return NotificationPrefs(
      arrival: prefs.notifArrival,
      digest: prefs.notifDigest,
      billDue: prefs.notifBillDue,
      evening: prefs.notifEvening,
      backup: prefs.notifBackup,
    );
  }

  Future<void> set(String kind, bool v) async {
    state = switch (kind) {
      'notifArrival' => state.copyWith(arrival: v),
      'notifDigest' => state.copyWith(digest: v),
      'notifBillDue' => state.copyWith(billDue: v),
      'notifEvening' => state.copyWith(evening: v),
      'notifBackup' => state.copyWith(backup: v),
      _ => state,
    };
    await ref.read(prefsProvider).setNotif(kind, v);
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
      NotificationPrefsController.new,
    );
