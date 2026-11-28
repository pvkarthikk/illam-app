import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/dates.dart';

class StaffRepo {
  StaffRepo(this.db, this.changes, this.clock);

  final NestDatabase db;
  final ChangeWriter changes;
  final Clock clock;
  final Map<String, Future<ChangeResult>> _markingIn = {};

  Stream<List<StaffData>> watchActive(String homeId) =>
      (db.select(db.staff)
            ..where(
              (s) =>
                  s.homeId.equals(homeId) &
                  s.deleted.equals(false) &
                  s.active.equals(true),
            )
            ..orderBy([(s) => OrderingTerm(expression: s.name)]))
          .watch();

  Stream<List<StaffData>> watchFormer(String homeId) =>
      (db.select(db.staff)
            ..where(
              (s) =>
                  s.homeId.equals(homeId) &
                  s.deleted.equals(false) &
                  s.active.equals(false),
            )
            ..orderBy([(s) => OrderingTerm(expression: s.name)]))
          .watch();

  Stream<StaffData?> watchOne(String id) => (db.select(
    db.staff,
  )..where((s) => s.id.equals(id) & s.deleted.equals(false))).watchSingleOrNull();

  Stream<List<Visit>> watchVisits(String staffId, String from, String to) =>
      (db.select(db.visits)
            ..where(
              (v) =>
                  v.staffId.equals(staffId) &
                  v.deleted.equals(false) &
                  v.date.isBiggerOrEqualValue(from) &
                  v.date.isSmallerOrEqualValue(to),
            )
            ..orderBy([(v) => OrderingTerm(expression: v.inAt)]))
          .watch()
          .distinct(const ListEquality<Visit>().equals);

  Stream<List<Visit>> watchVisitsOn(String homeId, String date) =>
      (db.select(db.visits)
            ..where(
              (v) =>
                  v.homeId.equals(homeId) &
                  v.deleted.equals(false) &
                  v.date.equals(date),
            )
            ..orderBy([(v) => OrderingTerm(expression: v.inAt)]))
          .watch();

  Stream<List<Visit>> watchOpenVisits(String homeId) =>
      (db.select(db.visits)
            ..where(
              (v) =>
                  v.homeId.equals(homeId) &
                  v.deleted.equals(false) &
                  v.outAt.isNull(),
            )
            ..orderBy([(v) => OrderingTerm(expression: v.inAt)]))
          .watch();

  Stream<List<Leave>> watchLeaves(String staffId, String from, String to) =>
      (db.select(db.leaves)..where(
            (l) =>
                l.staffId.equals(staffId) &
                l.deleted.equals(false) &
                l.date.isBiggerOrEqualValue(from) &
                l.date.isSmallerOrEqualValue(to),
          ))
          .watch()
          .distinct(const ListEquality<Leave>().equals);

  Stream<List<Leave>> watchLeavesOn(String homeId, String date) =>
      (db.select(db.leaves)..where(
            (l) =>
                l.homeId.equals(homeId) &
                l.deleted.equals(false) &
                l.date.equals(date),
          ))
          .watch();

  Future<ChangeResult> markIn(String staffId, String memberId) {
    final existing = _markingIn[staffId];
    if (existing != null) return existing;
    final f = _markIn(staffId, memberId).whenComplete(() {
      _markingIn.remove(staffId);
    });
    _markingIn[staffId] = f;
    return f;
  }

  Future<ChangeResult> _markIn(String staffId, String memberId) async {
    final today = Dates.today(clock);
    final now = clock.nowMs;
    final leaveId = '${staffId}_$today';
    final hasLeave =
        await (db.select(db.leaves)
              ..where((l) => l.id.equals(leaveId) & l.deleted.equals(false))
              ..limit(1))
            .getSingleOrNull() !=
        null;
    final hasOpen =
        await (db.select(db.visits)
              ..where(
                (v) =>
                    v.staffId.equals(staffId) &
                    v.date.equals(today) &
                    v.deleted.equals(false) &
                    v.outAt.isNull(),
              )
              ..limit(1))
            .getSingleOrNull() !=
        null;

    return changes.write('Marked in', (c) {
      if (!hasOpen) {
        c.create('visits', {
          'staff_id': staffId,
          'date': today,
          'in_at': now,
          'in_by': memberId,
        });
      }
      if (hasLeave) {
        c.delete('leaves', leaveId);
      }
    });
  }

  Future<ChangeResult> markOut(Visit open, String memberId) {
    final now = clock.nowMs;
    final out = max(now, (open.inAt ?? now) + 60000);
    return changes.write('Marked out', (c) {
      c.setAll('visits', open.id, {'out_at': out, 'out_by': memberId});
    });
  }

  Future<ChangeResult> saveVisit({
    String? id,
    required String staffId,
    required int inAt,
    int? outAt,
    required String memberId,
  }) async {
    final date = Dates.dateOfMs(inAt);
    final leaveId = '${staffId}_$date';
    final hasLeave =
        id == null &&
        (await (db.select(db.leaves)
                  ..where((l) => l.id.equals(leaveId) & l.deleted.equals(false))
                  ..limit(1))
                .getSingleOrNull() !=
            null);
    return changes.write('Visit', (c) {
      if (id == null) {
        c.create('visits', {
          'staff_id': staffId,
          'date': date,
          'in_at': inAt,
          'out_at': outAt,
          'in_by': memberId,
          'out_by': outAt != null ? memberId : null,
        });
        if (hasLeave) {
          c.delete('leaves', leaveId);
        }
      } else {
        c.setAll('visits', id, {
          'in_at': inAt,
          'out_at': outAt,
          'date': date,
          if (outAt != null) 'out_by': memberId,
        });
      }
    });
  }

  Future<ChangeResult> removeVisit(String id) =>
      changes.write('Visit', (c) => c.delete('visits', id));

  Future<ChangeResult> setLeave({
    required String staffId,
    required String date,
    required bool on,
    required String memberId,
    bool paid = false,
  }) {
    final leaveId = '${staffId}_$date';
    return changes.write('Leave', (c) {
      if (on) {
        c.create('leaves', {
          'staff_id': staffId,
          'date': date,
          'marked_by': memberId,
          'paid': paid,
        }, id: leaveId);
      } else {
        c.delete('leaves', leaveId);
      }
    });
  }

  Future<ChangeResult> addStaff({
    required String name,
    required String role,
    required String payType,
    required int amountPaise,
    required String expectedTime,
    required String color,
    required String today,
    String? phoneE164,
  }) => changes.write('Added house help', (c) {
    final staffId = c.create('staff', {
      'name': Names.titleCase(name),
      'role': role,
      'phone_e164': phoneE164,
      'color': color,
      'work_days': '1,2,3,4,5,6',
      'expected_times': expectedTime,
      'start_date': today,
      'active': true,
      'initial_pay_type': payType,
      'initial_pay_paise': amountPaise,
    });
    c.create('pay_rules', {
      'staff_id': staffId,
      'effective_month': Dates.month(today),
      'work_days': '1,2,3,4,5,6',
      'pay_type': payType,
      if (payType == 'hourly') ...{
        'rate_per_hour_paise': amountPaise,
        'rounding_min': 15,
        'min_hours_per_visit': 1,
      } else ...{
        'amount_per_month_paise': amountPaise,
        'paid_leaves_per_month': 2,
      },
    });
  });

  Future<ChangeResult> updateDetails(
    String id,
    Map<String, Object?> fields,
  ) async {
    PayRuleRow? rule;
    String? curMonth;
    final rawDays = fields['work_days'];
    final newDays = fields.containsKey('work_days') && rawDays is String
        ? rawDays
        : null;
    if (newDays != null) {
      final month = Dates.month(Dates.today(clock));
      curMonth = month;
      rule =
          await (db.select(db.payRules)
                ..where(
                  (r) =>
                      r.staffId.equals(id) &
                      r.deleted.equals(false) &
                      r.effectiveMonth.isSmallerOrEqualValue(month),
                )
                ..orderBy([
                  (r) => OrderingTerm.desc(r.effectiveMonth),
                  (r) => OrderingTerm.desc(r.createdAt),
                  (r) => OrderingTerm.desc(r.id),
                ])
                ..limit(1))
              .getSingleOrNull();
    }

    return changes.write('Staff details', (c) {
      c.setAll('staff', id, fields);
      if (rule != null &&
          newDays != null &&
          curMonth != null &&
          rule.workDays != newDays) {
        if (rule.effectiveMonth == curMonth) {
          c.set('pay_rules', rule.id, 'work_days', newDays);
        } else {
          c.create('pay_rules', {
            'staff_id': id,
            'effective_month': curMonth,
            'work_days': newDays,
            'pay_type': rule.payType,
            'rate_per_hour_paise': rule.ratePerHourPaise,
            'rounding_min': rule.roundingMin,
            'min_hours_per_visit': rule.minHoursPerVisit,
            'amount_per_month_paise': rule.amountPerMonthPaise,
            'paid_leaves_per_month': rule.paidLeavesPerMonth,
          });
        }
      }
    });
  }

  Future<ChangeResult> removeStaff(
    String id,
    String today, {
    void Function(ChangeBuilder c)? extra,
  }) => changes.write('Removed house help', (c) {
    c.setAll('staff', id, {'active': false, 'end_date': today});
    extra?.call(c);
  });

  Future<ChangeResult> restoreStaff(String id) => changes.write(
    'Staff details',
    (c) => c.setAll('staff', id, {'active': true, 'end_date': null}),
  );
}
