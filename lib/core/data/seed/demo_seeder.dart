import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/device_model.dart';
import 'package:nm_flat/core/util/hash_id.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/debug/data_lab_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class DemoSeeder {
  DemoSeeder(this.ref);
  final Ref ref;

  /// Each phase adds ONE private method and ONE line here, in this order. Every method is idempotent.
  Future<void> load() async {
    await _seedHomeAndMembers(); // must stay first (creates the home if missing)
    await _seedStaff();
    await _seedPay();
    await _seedItems();
    await _seedTasks();
    await _seedMeals();
    await _seedMoney();
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
    final home = await (db.select(
      db.homes,
    )..where((h) => h.id.equals(homeId))).getSingleOrNull();
    final log = ref.read(membershipLogProvider);
    await log.ensureGenesis(homeId, home?.genesisJson);

    final existing = await (db.select(
      db.members,
    )..where((m) => m.id.equals('demo-priya'))).getSingleOrNull();
    if (existing != null) return;

    await log.addDemoMember(
      homeId: homeId,
      memberId: 'demo-priya',
      fullName: 'Priya Anand',
      color: '#34508A',
      role: 'admin',
      model: 'Galaxy S23',
      via: 'qr',
      seed: 'demo-priya',
    );
    await log.addDemoMember(
      homeId: homeId,
      memberId: 'demo-arjun',
      fullName: 'Arjun Anand',
      color: '#B0412A',
      role: 'member',
      model: 'Redmi Note 13',
      via: 'phrase',
      seed: 'demo-arjun',
    );
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

  Future<void> _seedPay() async {
    final prefs = ref.read(prefsProvider);
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = ref.read(dbProvider);
    final staffRows = await (db.select(
      db.staff,
    )..where((s) => s.homeId.equals(homeId) & s.deleted.equals(false))).get();

    StaffData? lakshmi;
    StaffData? selvi;
    for (final s in staffRows) {
      if (s.name == 'Lakshmi') lakshmi = s;
      if (s.name == 'Selvi') selvi = s;
    }
    if (lakshmi == null || selvi == null) return;

    final existing =
        await (db.select(db.payRules)
              ..where(
                (r) =>
                    r.staffId.equals(lakshmi!.id) & r.deleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    final clock = ref.read(clockProvider);
    final today = Dates.today(clock);
    final thisMonth = Dates.month(today);
    final lastMonth = Dates.addMonths(thisMonth, -1);
    final me = prefs.memberId ?? prefs.deviceId;
    final lakshmiStart = lakshmi.startDate ?? today;
    final selviStart = selvi.startDate ?? today;

    final lakshmiRule = PayRulesData(
      effectiveMonth: Dates.month(lakshmiStart),
      workDays: const [1, 2, 3, 4, 5, 6],
      type: PayType.hourly,
      ratePerHourPaise: 9000,
      roundingMin: 15,
      minHoursPerVisit: 1,
    );
    final selviRule = PayRulesData(
      effectiveMonth: Dates.month(selviStart),
      workDays: const [1, 2, 3, 4, 5, 6],
      type: PayType.monthly,
      amountPerMonthPaise: 700000,
      paidLeavesPerMonth: 2,
    );

    final lakshmiVisits = <PayVisit>[];
    final selviVisits = <PayVisit>[];

    await ref.read(changesProvider).write('Demo data', (c) {
      c.create('pay_rules', {
        'staff_id': lakshmi!.id,
        'effective_month': lakshmiRule.effectiveMonth,
        'work_days': '1,2,3,4,5,6',
        'pay_type': 'hourly',
        'rate_per_hour_paise': 9000,
        'rounding_min': 15,
        'min_hours_per_visit': 1,
      });
      c.create('pay_rules', {
        'staff_id': selvi!.id,
        'effective_month': selviRule.effectiveMonth,
        'work_days': '1,2,3,4,5,6',
        'pay_type': 'monthly',
        'amount_per_month_paise': 700000,
        'paid_leaves_per_month': 2,
      });
      c.create('pay_adjustments', {
        'staff_id': lakshmi.id,
        'month': thisMonth,
        'kind': 'extra',
        'amount_paise': 20000,
        'note': 'Balcony deep clean',
      });
      c.create('pay_adjustments', {
        'staff_id': lakshmi.id,
        'month': thisMonth,
        'kind': 'advance',
        'amount_paise': 50000,
        'note': 'Advance',
      });

      final daysInLastMonth = Dates.daysInMonth(lastMonth);
      for (var day = 1; day <= daysInLastMonth; day++) {
        final d = '$lastMonth-${day.toString().padLeft(2, '0')}';
        if (Dates.weekdayIso(d) == DateTime.sunday) continue;
        final n = Dates.parse(d).day;
        if (n % 9 != 4) {
          final inM = 540 + (n * 7) % 22;
          final outM = inM + 135 + (n * 13) % 35;
          final inAt = Dates.msAt(d, inM);
          final outAt = Dates.msAt(d, outM);
          c.create('visits', {
            'staff_id': lakshmi.id,
            'date': d,
            'in_at': inAt,
            'out_at': outAt,
            'in_by': me,
            'out_by': me,
          });
          lakshmiVisits.add(PayVisit(d, inAt, outAt));
        }
        if (n % 11 != 6) {
          final in1 = 445 + (n * 3) % 12;
          final out1 = 515 + (n * 5) % 15;
          final in1At = Dates.msAt(d, in1);
          final out1At = Dates.msAt(d, out1);
          c.create('visits', {
            'staff_id': selvi.id,
            'date': d,
            'in_at': in1At,
            'out_at': out1At,
            'in_by': me,
            'out_by': me,
          });
          selviVisits.add(PayVisit(d, in1At, out1At));

          final in2 = 1080 + (n * 4) % 15;
          final out2 = 1145 + (n * 7) % 20;
          final in2At = Dates.msAt(d, in2);
          final out2At = Dates.msAt(d, out2);
          c.create('visits', {
            'staff_id': selvi.id,
            'date': d,
            'in_at': in2At,
            'out_at': out2At,
            'in_by': me,
            'out_by': me,
          });
          selviVisits.add(PayVisit(d, in2At, out2At));
        }
      }
    }, homeId: homeId);

    final rLakshmi = computePayroll(
      PayrollInput(
        month: lastMonth,
        today: today,
        startDate: lakshmiStart,
        rules: [lakshmiRule],
        visits: lakshmiVisits,
        leaveDates: const {},
        adjustments: const [],
      ),
    );
    final rSelvi = computePayroll(
      PayrollInput(
        month: lastMonth,
        today: today,
        startDate: selviStart,
        rules: [selviRule],
        visits: selviVisits,
        leaveDates: const {},
        adjustments: const [],
      ),
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    final lastMonthName = Formatters.monthName(lastMonth);
    final salaryRepo = ref.read(salaryRepoProvider);
    await salaryRepo.markPaid(
      staffId: lakshmi.id,
      month: lastMonth,
      r: rLakshmi,
      method: 'upi',
      merchantText: l10n.salaryExpenseMerchant('Lakshmi', lastMonthName),
      today: today,
      date: Dates.monthStart(thisMonth),
    );
    await salaryRepo.markPaid(
      staffId: selvi.id,
      month: lastMonth,
      r: rSelvi,
      method: 'cash',
      merchantText: l10n.salaryExpenseMerchant('Selvi', lastMonthName),
      today: today,
      date: Dates.monthStart(thisMonth),
    );
  }

  Future<void> _seedItems() async {
    final prefs = ref.read(prefsProvider);
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = ref.read(dbProvider);
    final existing =
        await (db.select(db.items)
              ..where(
                (i) =>
                    i.homeId.equals(homeId) &
                    i.name.equals('Milk') &
                    i.done.equals(false) &
                    i.deleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    final now = ref.read(clockProvider).nowMs;
    final me = prefs.memberId ?? prefs.deviceId;
    const hour = 3600000;
    final changes = ref.read(changesProvider);

    const grocery = [
      ('Milk', 2000, 'L', 'zepto', 'Dairy', false),
      ('Curd', 400000, 'g', 'zepto', 'Dairy', false),
      ('Coriander', 1000, 'bunch', 'zepto', 'Vegetables', false),
      ('Paneer', 200000, 'g', 'zepto', 'Dairy', true),
      ('Tomatoes', 1000, 'kg', 'offline', 'Vegetables', false),
      ('Onions', 2000, 'kg', 'offline', 'Vegetables', false),
      ('Bananas', 1000, 'dozen', 'offline', 'Fruits', false),
      ('Toor dal', 1000, 'kg', 'bigbasket', 'Staples', false),
      ('Basmati rice', 5000, 'kg', 'bigbasket', 'Staples', false),
      ('Dishwash liquid', 1000, '', 'blinkit', 'Cleaning', false),
    ];
    const groceryBought = [
      ('Eggs', 'zepto'),
      ('Bread', 'blinkit'),
      ('Atta 5kg', 'bigbasket'),
      ('Ghee', 'bigbasket'),
      ('Detergent', 'amazon'),
      ('Green chillies', 'offline'),
    ];
    const groceryUsual = [('Milk', 'zepto'), ('Curd', 'zepto')];

    await changes.write('Demo data', (c) {
      for (final (name, qtyMilli, unit, ch, cat, done) in grocery) {
        final id = c.create('items', {
          'list': 'grocery',
          'name': name,
          'name_key': itemNameKey(name),
          'unit': unit,
          'channel': ch,
          'category': cat,
          if (done) ...{'done': true, 'done_at': now, 'done_by': me},
        });
        c.inc('items', id, 'qty_milli', qtyMilli);
      }
      for (var i = 0; i < groceryBought.length; i++) {
        final (name, ch) = groceryBought[i];
        final key = itemNameKey(name);
        final histId = itemHistoryId('grocery', key);
        c.setAll('item_history', histId, {
          'deleted': false,
          'list': 'grocery',
          'name': name,
          'name_key': key,
          'usual_channel': ch,
          'last_bought_at': now - i * hour,
        });
        c.inc('item_history', histId, 'times_bought', 1);
      }
      for (final (name, ch) in groceryUsual) {
        final key = itemNameKey(name);
        final histId = itemHistoryId('grocery', key);
        c.setAll('item_history', histId, {
          'deleted': false,
          'list': 'grocery',
          'name': name,
          'name_key': key,
          'usual_channel': ch,
        });
      }
    }, homeId: homeId);

    const shopping = [
      ('Arjun’s school shoes', 1000, 'flipkart', 'Kids'),
      ('Water purifier filter', 1000, 'amazon', 'Home'),
      ('HDMI cable 2m', 1000, 'amazon', 'Electronics'),
      ('Cotton bedsheet set', 2000, 'meesho', 'Home'),
      ('LED bulbs 9W', 4000, 'offline', 'Hardware'),
    ];
    const shoppingBought = [
      ('AA batteries', 'amazon'),
      ('Phone charger', 'amazon'),
      ('Kitchen towels', 'amazon'),
    ];

    await changes.write('Demo data', (c) {
      for (final (name, qtyMilli, ch, cat) in shopping) {
        final id = c.create('items', {
          'list': 'shopping',
          'name': name,
          'name_key': itemNameKey(name),
          'unit': '',
          'channel': ch,
          'category': cat,
        });
        c.inc('items', id, 'qty_milli', qtyMilli);
      }
      for (var i = 0; i < shoppingBought.length; i++) {
        final (name, ch) = shoppingBought[i];
        final key = itemNameKey(name);
        final histId = itemHistoryId('shopping', key);
        c.setAll('item_history', histId, {
          'deleted': false,
          'list': 'shopping',
          'name': name,
          'name_key': key,
          'usual_channel': ch,
          'last_bought_at': now - i * hour,
        });
        c.inc('item_history', histId, 'times_bought', 1);
      }
    }, homeId: homeId);
  }

  Future<void> _seedTasks() async {
    final prefs = ref.read(prefsProvider);
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = ref.read(dbProvider);
    final existing =
        await (db.select(db.routines)
              ..where(
                (r) =>
                    r.homeId.equals(homeId) &
                    r.name.equals('Clean bathrooms') &
                    r.deleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    final clock = ref.read(clockProvider);
    final today = Dates.today(clock);
    final now = clock.nowMs;
    final me = ref.read(myMemberIdProvider);

    final memberRows = await (db.select(
      db.members,
    )..where((m) => m.homeId.equals(homeId) & m.deleted.equals(false))).get();
    final staffRows = await (db.select(
      db.staff,
    )..where((s) => s.homeId.equals(homeId) & s.deleted.equals(false))).get();

    String? memberIdFor(String first) {
      for (final m in memberRows) {
        if (m.firstName == first) return m.id;
      }
      return null;
    }

    String? staffIdFor(String name) {
      for (final s in staffRows) {
        if (s.name == name) return s.id;
      }
      return null;
    }

    final priyaId = memberIdFor('Priya');
    final arjunId = memberIdFor('Arjun');
    final lakshmiId = staffIdFor('Lakshmi');

    final routines = <(String, String, int, String, String?, int)>[
      ('Sweep & mop floors', 'Whole house', 1, 'staff', lakshmiId, -1),
      ('Wash utensils', 'Kitchen', 1, 'staff', lakshmiId, -1),
      ('Clean bathrooms', 'Bathrooms', 3, 'staff', lakshmiId, -4),
      ('Change bedsheets', 'Bedrooms', 7, 'member', priyaId, -5),
      ('Fridge clean-out', 'Kitchen', 14, 'member', me, -16),
      ('Dust fans & windows', 'Living room', 15, 'staff', lakshmiId, -6),
      ('Water the plants', 'Balcony', 2, 'member', arjunId, -1),
      ('Change RO filter', 'Kitchen', 90, 'member', me, -71),
    ];

    final todos = <(String, int, String?, bool)>[
      ('Book cooking gas cylinder', -1, me, false),
      ('Pay electricity bill', 0, me, false),
      ('Return library books', 0, arjunId, false),
      ('Call plumber — kitchen tap leak', 1, me, false),
      ('Book AC service', 2, priyaId, false),
      ('Parent–teacher meeting', 4, priyaId, false),
      ('Renew home insurance', -2, me, true),
    ];

    await ref.read(changesProvider).write('Demo data', (c) {
      for (final (name, room, everyDays, type, who, offset) in routines) {
        if (who == null || who.isEmpty) continue;
        c.create('routines', {
          'name': name,
          'room': room,
          'every_days': everyDays,
          'assignee_type': type,
          'assignee': who,
          'last_done': Dates.addDays(today, offset),
        });
      }
      for (final (title, offset, who, done) in todos) {
        if (who == null || who.isEmpty) continue;
        c.create('todos', {
          'title': title,
          'due': Dates.addDays(today, offset),
          'assignee_type': 'member',
          'assignee': who,
          'done': done,
          if (done) ...{'done_at': now, 'done_by': me},
        });
      }
    }, homeId: homeId);
  }

  Future<void> _seedMeals() async {
    final prefs = ref.read(prefsProvider);
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final recipesRepo = ref.read(recipesRepoProvider);
    await recipesRepo.addStarterPack();

    final db = ref.read(dbProvider);
    final existingSlot =
        await (db.select(db.mealSlots)
              ..where((s) => s.homeId.equals(homeId) & s.deleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
    if (existingSlot != null) return;

    final recipeList = await recipesRepo.watchAll().first;
    final byName = {for (final r in recipeList) r.name: r};
    final today = Dates.today(ref.read(clockProvider));
    final monday = Dates.addDays(today, 1 - Dates.weekdayIso(today));
    final mealsRepo = ref.read(mealsRepoProvider);

    const plan = <(int offset, String slot, String recipeName)>[
      (0, 'breakfast', 'Pesarattu'),
      (0, 'lunch', 'Drumstick sambar'),
      (0, 'dinner', 'Paneer butter masala'),
      (1, 'breakfast', 'Aloo paratha'),
      (1, 'lunch', 'Lemon rice'),
      (1, 'dinner', 'Tomato rasam'),
      (2, 'breakfast', 'Rava upma'),
      (2, 'lunch', 'Drumstick sambar'),
      (2, 'dinner', 'Veg pulao'),
      (3, 'breakfast', 'Pesarattu'),
      (3, 'lunch', 'Tomato rasam'),
      (3, 'dinner', 'Paneer butter masala'),
      (4, 'lunch', 'Veg pulao'),
      (4, 'dinner', 'Dal tadka'),
      (5, 'breakfast', 'Aloo paratha'),
    ];

    for (final (offset, slot, name) in plan) {
      final r = byName[name];
      if (r != null) {
        await mealsRepo.planRecipe(Dates.addDays(monday, offset), slot, r);
      }
    }

    final openKeys = await mealsRepo.watchOpenGroceryKeys().first;
    final seen = <String, String>{};
    for (final r in recipeList) {
      for (final ing in r.ingredients) {
        if (ing.nameKey == 'green chillies' ||
            ing.nameKey == 'fresh cream' ||
            openKeys.contains(ing.nameKey)) {
          continue;
        }
        seen.putIfAbsent(ing.nameKey, () => ing.name);
      }
    }
    for (final entry in seen.entries) {
      await mealsRepo.setPantry(entry.value, entry.key, true);
    }
  }

  Future<void> _seedMoney() async {
    final prefs = ref.read(prefsProvider);
    final homeId = prefs.currentHomeId;
    if (homeId == null) return;

    final db = ref.read(dbProvider);
    final existing =
        await (db.select(db.bills)
              ..where(
                (b) =>
                    b.homeId.equals(homeId) &
                    b.name.equals('Milkman') &
                    b.deleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    final today = Dates.today(ref.read(clockProvider));
    final thisMonth = Dates.month(today);
    final lastMonth = Dates.addMonths(thisMonth, -1);
    final firstDue = Dates.addMonths(thisMonth, -3);
    final todayDay = Dates.parse(today).day;
    String dayOfMonth(int n) =>
        '$thisMonth-${min(n, todayDay).toString().padLeft(2, '0')}';

    await ref.read(moneyRepoProvider).setBudget(3200000);

    final expensesRepo = ref.read(expensesRepoProvider);
    await ref.read(changesProvider).write('Demo data', (c) {
      String addBill(
        String name,
        int rupees,
        int dueDay,
        String method,
        String category,
      ) => c.create('bills', {
        'name': name,
        'category': category,
        'usual_amount_paise': rupees * 100,
        'due_day': dueDay,
        'first_due_month': firstDue,
        'method': method,
        'remind': true,
        'active': true,
      });

      final milkId = addBill('Milkman', 1860, 1, 'cash', 'Groceries');
      final elecId = addBill(
        'Electricity (BESCOM)',
        1980,
        5,
        'upi',
        'Utilities',
      );
      addBill('Society maintenance', 3500, 10, 'bank', 'Home care');
      final netId = addBill('Broadband (ACT)', 1062, 12, 'upi', 'Utilities');
      addBill('Newspaper', 420, 28, 'cash', 'Other');

      void addExp({
        required String merchant,
        required int rupees,
        required String date,
        required String method,
        required String source,
        String? category,
        String? orderChannel,
        String? billId,
        String? forMonth,
        String? memberId,
      }) {
        final id = expensesRepo.createIn(
          c,
          NewExpense(
            amountPaise: rupees * 100,
            merchant: merchant,
            category: category ?? guessSpendCategory(merchant, const {}),
            method: method,
            date: date,
            source: source,
            paidBy: memberId,
            forMonth: forMonth,
            billId: billId,
            orderChannel: orderChannel,
          ),
        );
        if (memberId != null) {
          c.set('expenses', id, 'added_by', memberId);
        }
      }

      addExp(
        merchant: 'Milkman',
        rupees: 1860,
        date: dayOfMonth(1),
        method: 'cash',
        source: 'bill',
        billId: milkId,
        forMonth: thisMonth,
      );
      addExp(
        merchant: 'Zepto',
        rupees: 842,
        date: dayOfMonth(2),
        method: 'upi',
        source: 'order',
        orderChannel: 'zepto',
      );
      addExp(
        merchant: 'BigBasket',
        rupees: 2460,
        date: dayOfMonth(3),
        method: 'card',
        source: 'order',
        orderChannel: 'bigbasket',
        memberId: 'demo-priya',
      );
      addExp(
        merchant: 'Electricity (BESCOM)',
        rupees: 1980,
        date: dayOfMonth(5),
        method: 'upi',
        source: 'bill',
        billId: elecId,
        forMonth: thisMonth,
      );
      addExp(
        merchant: 'Amazon',
        rupees: 3299,
        date: dayOfMonth(6),
        method: 'card',
        source: 'order',
        orderChannel: 'amazon',
        memberId: 'demo-priya',
      );
      addExp(
        merchant: 'D-Mart',
        rupees: 1675,
        date: dayOfMonth(9),
        method: 'upi',
        source: 'store',
      );
      addExp(
        merchant: 'Meesho',
        rupees: 649,
        date: dayOfMonth(11),
        method: 'upi',
        source: 'order',
        orderChannel: 'meesho',
        memberId: 'demo-priya',
      );
      addExp(
        merchant: 'Urban Company',
        rupees: 899,
        date: dayOfMonth(12),
        method: 'upi',
        source: 'manual',
        category: 'Home care',
        memberId: 'demo-priya',
      );
      addExp(
        merchant: 'Broadband (ACT)',
        rupees: 1062,
        date: dayOfMonth(12),
        method: 'upi',
        source: 'bill',
        billId: netId,
        forMonth: thisMonth,
      );
      addExp(
        merchant: 'Blinkit',
        rupees: 386,
        date: dayOfMonth(14),
        method: 'upi',
        source: 'order',
        orderChannel: 'blinkit',
      );
      addExp(
        merchant: 'Flipkart',
        rupees: 1149,
        date: dayOfMonth(15),
        method: 'upi',
        source: 'order',
        orderChannel: 'flipkart',
        memberId: 'demo-arjun',
      );
      addExp(
        merchant: 'Swiggy',
        rupees: 624,
        date: dayOfMonth(16),
        method: 'upi',
        source: 'manual',
        category: 'Eating out',
        memberId: 'demo-arjun',
      );

      // Last month (mine, upi, manual)
      addExp(
        merchant: 'BigBasket',
        rupees: 12000,
        date: '$lastMonth-04',
        method: 'upi',
        source: 'manual',
      );
      addExp(
        merchant: 'Amazon',
        rupees: 10000,
        date: '$lastMonth-12',
        method: 'upi',
        source: 'manual',
      );
      addExp(
        merchant: 'Swiggy',
        rupees: 7840,
        date: '$lastMonth-20',
        method: 'upi',
        source: 'manual',
      );
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
