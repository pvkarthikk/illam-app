import 'dart:convert';

import 'package:nm_flat/core/data/db/database.dart';

class MemberInfo {
  const MemberInfo(this.name, this.isAdmin);

  final String name;
  final bool isAdmin;
}

class RowSummary {
  const RowSummary(
    this.deviceId,
    this.memberId,
    this.name,
    this.providerKind,
    this.lastSuccessAt,
  );

  final String deviceId;
  final String memberId;
  final String name;
  final String providerKind;
  final int lastSuccessAt;
}

enum HealthState { ok, none, onlyOnPhone, noRecoveryReady, stale }

const int _dayMs = 24 * 60 * 60 * 1000;

int _intervalMs(String frequency) => switch (frequency) {
  'daily' => _dayMs,
  'monthly' => 30 * _dayMs,
  _ => 7 * _dayMs,
};

({String kind, int at})? _newestSuccess(
  String destsJson, {
  bool offPhoneOnly = false,
}) {
  try {
    final decoded = jsonDecode(destsJson);
    if (decoded is! List) return null;
    String? bestKind;
    int? bestAt;
    for (final raw in decoded) {
      if (raw is! Map) continue;
      if (offPhoneOnly && raw['offPhone'] == false) continue;
      final at = raw['lastSuccessAt'];
      final kind = raw['providerKind'];
      if (at is! int || at <= 0) continue;
      if (bestAt == null || at > bestAt) {
        bestAt = at;
        bestKind = kind is String && kind.isNotEmpty ? kind : 'folder';
      }
    }
    if (bestAt == null || bestKind == null) return null;
    return (kind: bestKind, at: bestAt);
  } on Object {
    return null;
  }
}

/// Pure summary of all phones' `backup_status` rows for the Home & members card.
class BackupHealth {
  const BackupHealth({
    required this.state,
    this.okRow,
    this.staleDays = 0,
    this.noAdminHint = false,
    this.mine,
    this.others = const [],
  });

  final HealthState state;
  final RowSummary? okRow;
  final int staleDays;
  final bool noAdminHint;
  final RowSummary? mine;
  final List<RowSummary> others;

  static BackupHealth compute(
    List<BackupStatusRow> rows,
    Map<String, MemberInfo> activeMembers,
    String myDeviceId,
    int nowMs,
  ) {
    final successful =
        <({BackupStatusRow row, MemberInfo member, RowSummary summary})>[];
    for (final row in rows) {
      if (row.deleted) continue;
      final member = activeMembers[row.memberId];
      if (member == null) continue;
      final newest = _newestSuccess(row.destsJson, offPhoneOnly: row.offPhone);
      if (newest == null) continue;
      successful.add((
        row: row,
        member: member,
        summary: RowSummary(
          row.id,
          row.memberId,
          member.name,
          newest.kind,
          newest.at,
        ),
      ));
    }

    RowSummary? mine;
    final others = <RowSummary>[];
    for (final item in successful) {
      if (item.summary.deviceId == myDeviceId) {
        mine = item.summary;
      } else {
        others.add(item.summary);
      }
    }
    others.sort((a, b) => b.lastSuccessAt.compareTo(a.lastSuccessAt));

    if (successful.isEmpty) {
      return BackupHealth(
        state: HealthState.none,
        mine: mine,
        others: others,
      );
    }

    final noAdminHint = !successful.any((s) => s.member.isAdmin);

    final both = [
      for (final s in successful)
        if (s.row.recoveryCapable && s.row.offPhone) s,
    ]..sort((a, b) => b.summary.lastSuccessAt.compareTo(a.summary.lastSuccessAt));

    final freshOk = [
      for (final s in both)
        if (s.summary.lastSuccessAt >= nowMs - 2 * _intervalMs(s.row.frequency))
          s,
    ];

    if (freshOk.isNotEmpty) {
      return BackupHealth(
        state: HealthState.ok,
        okRow: freshOk.first.summary,
        noAdminHint: noAdminHint,
        mine: mine,
        others: others,
      );
    }

    if (!successful.any((s) => s.row.offPhone)) {
      return BackupHealth(
        state: HealthState.onlyOnPhone,
        noAdminHint: noAdminHint,
        mine: mine,
        others: others,
      );
    }

    if (both.isEmpty) {
      return BackupHealth(
        state: HealthState.noRecoveryReady,
        noAdminHint: noAdminHint,
        mine: mine,
        others: others,
      );
    }

    final staleDays = (nowMs - both.first.summary.lastSuccessAt) ~/ _dayMs;
    return BackupHealth(
      state: HealthState.stale,
      staleDays: staleDays,
      noAdminHint: noAdminHint,
      mine: mine,
      others: others,
    );
  }
}
