import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/features/account/appearance_controller.dart';

import 'package:nm_flat/l10n/gen/app_localizations.dart';

typedef SyncNotificationSender =
    Future<void> Function({
      required int id,
      required String title,
      required String body,
      required String channelId,
      required String channelName,
      required String payload,
    });

/// Fires OS notifications for remote changes applied during sync ingest.
class SyncReactions {
  SyncReactions(this.db, this.prefs, {this.notify});

  final NestDatabase db;
  final DevicePrefs prefs;
  final SyncNotificationSender? notify;
  final List<OpRecord> _collected = [];

  void onApplied(OpRecord op) => _collected.add(op);

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String payload,
  }) async {
    try {
      final sender = notify;
      if (sender != null) {
        await sender(
          id: id,
          title: title,
          body: body,
          channelId: channelId,
          channelName: channelName,
          payload: payload,
        );
        return;
      }
      await plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            icon: 'ic_stat_nest',
          ),
        ),
        payload: payload,
      );
    } on Object {
      // Notification platform channel may be unavailable in tests.
    }
  }

  Future<String> _memberDisplayName(String memberId) async {
    if (memberId.isEmpty) return '';
    final member = await (db.select(
      db.members,
    )..where((m) => m.id.equals(memberId))).getSingleOrNull();
    if (member == null) return '';
    final first = member.firstName?.trim() ?? '';
    if (first.isNotEmpty) return first;
    return member.fullName?.trim() ?? '';
  }

  Future<void> flush() async {
    final ops = [..._collected];
    _collected.clear();
    if (ops.isEmpty) return;

    final me = prefs.memberId;
    if (me == null || prefs.setupIncompleteHomeId != null) return;
    final l = lookupUserLocalizations(prefs);

    final notifiedAssigned = <String>{};
    final notifiedCompleted = <String>{};

    for (final op in ops) {
      if (op.tbl != 'todos') continue;
      if (op.field == 'assignee') {
        await _maybeNotifyAssigned(op, me, l, notifiedAssigned);
      } else if (op.field == 'done') {
        await _maybeNotifyCompleted(op, me, l, notifiedCompleted);
      }
    }
  }

  Future<void> _maybeNotifyAssigned(
    OpRecord op,
    String me,
    AppLocalizations l,
    Set<String> seen,
  ) async {
    final val = op.valueJson != null ? jsonDecode(op.valueJson!) : null;
    if (val != me || op.authorMemberId == me) return;
    if (!seen.add(op.entityId)) return;

    final todo = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(op.entityId))).getSingleOrNull();
    if (todo == null ||
        todo.deleted ||
        todo.done ||
        todo.assigneeType != 'member' ||
        todo.assignee != me) {
      return;
    }

    final authorName = await _memberDisplayName(op.authorMemberId);
    await _show(
      id: stableId('todo.${op.entityId}'),
      title: l.notifTodoAssignedTitle,
      body: l.notifTodoAssignedBody(todo.title, authorName),
      channelId: 'tasks',
      channelName: l.notifChannelTasks,
      payload: jsonEncode({'route': '/tasks'}),
    );
  }

  Future<void> _maybeNotifyCompleted(
    OpRecord op,
    String me,
    AppLocalizations l,
    Set<String> seen,
  ) async {
    final val = op.valueJson != null ? jsonDecode(op.valueJson!) : null;
    if (val != true || op.authorMemberId == me) return;
    if (!seen.add(op.entityId)) return;

    final todo = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(op.entityId))).getSingleOrNull();
    if (todo == null ||
        todo.deleted ||
        !todo.done ||
        todo.assigneeType != 'member' ||
        todo.assignee != me) {
      return;
    }
    if (todo.doneBy == me) return;

    final completerId = (todo.doneBy != null && todo.doneBy!.isNotEmpty)
        ? todo.doneBy!
        : op.authorMemberId;
    final completerName = await _memberDisplayName(completerId);
    final body = completerName.isNotEmpty
        ? l.notifTodoDoneBody(todo.title, completerName)
        : todo.title;

    await _show(
      id: stableId('todo_done.${op.entityId}'),
      title: l.notifTodoDoneTitle,
      body: body,
      channelId: 'tasks',
      channelName: l.notifChannelTasks,
      payload: jsonEncode({'route': '/tasks'}),
    );
  }

  Future<void> memberJoined(String memberId, String name) async {
    if (memberId == prefs.memberId) return;
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(homeId))).getSingleOrNull();
    final homeName = home?.name ?? '';
    final l = lookupUserLocalizations(prefs);

    await _show(
      id: stableId('joined.$memberId'),
      title: l.notifJoinedTitle(name, homeName),
      body: l.notifJoinedBody,
      channelId: 'home',
      channelName: l.notifChannelHome,
      payload: jsonEncode({'route': '/home'}),
    );
  }
}
