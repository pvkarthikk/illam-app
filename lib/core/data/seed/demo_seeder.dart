import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/device_model.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';

class DemoSeeder {
  DemoSeeder(this.ref);
  final Ref ref;

  /// Each phase adds ONE private method and ONE line here, in this order. Every method is idempotent.
  Future<void> load() async {
    await _seedHomeAndMembers(); // must stay first (creates the home if missing)
    await _seedStaff();
    // P05: await _seedPay();
    // P06: await _seedItems();
    // P08: await _seedTasks();
    // P09: await _seedMeals();
    // P10: await _seedMoney();
    await _seedDevNotes();
  }

  Future<void> _seedHomeAndMembers() async {
    final prefs = ref.read(prefsProvider);
    final clock = ref.read(clockProvider);
    if (prefs.currentHomeId == null) {
      final keys = await ref.read(deviceKeysProvider.future);
      await ref
          .read(homeRepoProvider)
          .createHome(
            creatorName: 'Anand Kumar',
            homeName: 'Anand Home',
            keys: keys,
            createdAt: clock.nowMs,
            nonceB64: base64.encode(Ids.randomBytes(16)),
            model: await deviceModel(),
          );
    }
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = ref.read(dbProvider);
    final existing = await (db.select(
      db.members,
    )..where((m) => m.id.equals('demo-priya'))).getSingleOrNull();
    if (existing != null) return;

    final now = clock.nowMs;
    const day = 86400000;
    await ref.read(changesProvider).write('Demo data', (c) {
      c.create('members', {
        'full_name': 'Priya Anand',
        'first_name': 'Priya',
        'role': 'admin',
        'status': 'active',
        'color': '#34508A',
        'device_model': 'Galaxy S23',
        'joined_at': now - 209 * day,
        'joined_via': 'qr',
        'invited_by': prefs.memberId,
      }, id: 'demo-priya');
      c.create('members', {
        'full_name': 'Arjun Anand',
        'first_name': 'Arjun',
        'role': 'member',
        'status': 'active',
        'color': '#B0412A',
        'device_model': 'Redmi Note 13',
        'joined_at': now - 120 * day,
        'joined_via': 'phrase',
        'invited_by': 'demo-priya',
      }, id: 'demo-arjun');
    }, homeId: homeId);
  }

  Future<void> _seedStaff() async {
    final prefs = ref.read(prefsProvider);
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = ref.read(dbProvider);
    final existing =
        await (db.select(db.staff)
              ..where(
                (s) =>
                    s.homeId.equals(homeId) &
                    s.name.equals('Lakshmi') &
                    s.deleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    final clock = ref.read(clockProvider);
    final today = Dates.today(clock);
    final me = ref.read(myMemberIdProvider);
    final start = Dates.monthStart(Dates.addMonths(Dates.month(today), -3));

    await ref.read(changesProvider).write('Demo data', (c) {
      final lakshmiId = c.create('staff', {
        'name': 'Lakshmi',
        'role': 'House help',
        'phone_e164': '+919876544410',
        'color': '#B07A1A',
        'work_days': '1,2,3,4,5,6',
        'expected_times': '09:00',
        'usual_end_time': '11:30',
        'start_date': start,
        'active': true,
        'initial_pay_type': 'hourly',
        'initial_pay_paise': 9000,
      });
      final selviId = c.create('staff', {
        'name': 'Selvi',
        'role': 'Cook',
        'phone_e164': '+919944000721',
        'color': '#7A5AA8',
        'work_days': '1,2,3,4,5,6',
        'expected_times': '07:30,18:00',
        'start_date': start,
        'active': true,
        'initial_pay_type': 'monthly',
        'initial_pay_paise': 700000,
      });

      var d = Dates.monthStart(Dates.month(today));
      while (d.compareTo(today) < 0) {
        if (Dates.weekdayIso(d) != DateTime.sunday) {
          final n = Dates.parse(d).day;
          if (n % 9 != 4) {
            final inM = 540 + (n * 7 % 22);
            final outM = inM + 135 + (n * 13 % 35);
            c.create('visits', {
              'staff_id': lakshmiId,
              'date': d,
              'in_at': Dates.msAt(d, inM),
              'out_at': Dates.msAt(d, outM),
              'in_by': me,
              'out_by': me,
            });
          }
          if (n % 11 != 6) {
            final in1 = 445 + (n * 3 % 12);
            final out1 = 515 + (n * 5 % 15);
            c.create('visits', {
              'staff_id': selviId,
              'date': d,
              'in_at': Dates.msAt(d, in1),
              'out_at': Dates.msAt(d, out1),
              'in_by': me,
              'out_by': me,
            });
            final in2 = 1080 + (n * 4 % 15);
            final out2 = 1145 + (n * 7 % 20);
            c.create('visits', {
              'staff_id': selviId,
              'date': d,
              'in_at': Dates.msAt(d, in2),
              'out_at': Dates.msAt(d, out2),
              'in_by': me,
              'out_by': me,
            });
          }
        }
        d = Dates.addDays(d, 1);
      }

      if (clock.nowMs > Dates.msAt(today, 8 * 60 + 45)) {
        c.create('visits', {
          'staff_id': selviId,
          'date': today,
          'in_at': Dates.msAt(today, 451),
          'out_at': Dates.msAt(today, 524),
          'in_by': me,
          'out_by': me,
        });
      }
    }, homeId: homeId);
  }

  Future<void> _seedDevNotes() async {
    final prefs = ref.read(prefsProvider);
    final home = prefs.currentHomeId ?? labHomeId;
    final db = ref.read(dbProvider);
    final existing =
        await (db.select(db.devNotes)
              ..where((n) => n.homeId.equals(home) & n.deleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    await ref.read(changesProvider).write('Demo data', (c) {
      c.create('dev_notes', {'title': 'Milk 2L'});
      c.create('dev_notes', {'title': 'Call plumber'});
      c.create('dev_notes', {'title': 'Pay rent'});
    }, homeId: home);
  }
}
