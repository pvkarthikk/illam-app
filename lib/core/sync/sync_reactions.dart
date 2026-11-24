import 'dart:convert';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Fires OS notifications for remote changes applied during sync ingest.
class SyncReactions {
  SyncReactions(this.db, this.prefs);

  final NestDatabase db;
  final DevicePrefs prefs;
  final List<OpRecord> _collected = [];

  void onApplied(OpRecord op) => _collected.add(op);

  Future<void> flush() async {
    final ops = [..._collected];
    _collected.clear();
    if (ops.isEmpty) return;

    final me = prefs.memberId;
    if (me == null) return;
    final l = lookupAppLocalizations(const Locale('en'));

    for (final op in ops) {
      if (op.tbl != 'todos' || op.field != 'assignee') continue;
      final val = op.valueJson != null ? jsonDecode(op.valueJson!) : null;
      if (val != me || op.authorMemberId == me) continue;

      final todo = await (db.select(
        db.todos,
      )..where((t) => t.id.equals(op.entityId))).getSingleOrNull();
      if (todo == null ||
          todo.deleted ||
          todo.done ||
          todo.assigneeType != 'member' ||
          todo.assignee != me) {
        continue;
      }

      final author = await (db.select(
        db.members,
      )..where((m) => m.id.equals(op.authorMemberId))).getSingleOrNull();
      final authorName =
          (author?.firstName != null && author!.firstName!.isNotEmpty)
          ? author.firstName!
          : (author?.fullName ?? '');

      try {
        await plugin.show(
          id: stableId('todo.${op.entityId}'),
          title: l.notifTodoAssignedTitle,
          body: l.notifTodoAssignedBody(todo.title, authorName),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'tasks',
              l.notifChannelTasks,
              icon: 'ic_stat_nest',
            ),
          ),
          payload: jsonEncode({'route': '/tasks'}),
        );
      } on Object {
        // Notification platform channel may be unavailable in tests.
      }
    }
  }

  Future<void> memberJoined(String memberId, String name) async {
    if (memberId == prefs.memberId) return;
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(homeId))).getSingleOrNull();
    final homeName = home?.name ?? '';
    final l = lookupAppLocalizations(const Locale('en'));

    try {
      await plugin.show(
        id: stableId('joined.$memberId'),
        title: l.notifJoinedTitle(name, homeName),
        body: l.notifJoinedBody,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'home',
            l.notifChannelHome,
            icon: 'ic_stat_nest',
          ),
        ),
        payload: jsonEncode({'route': '/home'}),
      );
    } on Object {
      // Notification platform channel may be unavailable in tests.
    }
  }
}
