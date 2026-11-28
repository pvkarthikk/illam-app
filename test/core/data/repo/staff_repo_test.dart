import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/staff_repo.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

typedef _Env = ({
  NestDatabase db,
  DevicePrefs prefs,
  FixedClock clock,
  StaffRepo repo,
});

Future<_Env> _env() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-TEST');
  await prefs.setMemberId('mem-1');
  final clock = FixedClock(DateTime(2026, 11, 20, 9, 0));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
  );
  return (
    db: db,
    prefs: prefs,
    clock: clock,
    repo: StaffRepo(db, changes, clock),
  );
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('markIn clears today leave in one change and undo restores both', () async {
    final e = await _env();
    await e.repo.setLeave(
      staffId: 's1',
      date: '2026-11-20',
      on: true,
      memberId: 'mem-1',
    );
    final res = await e.repo.markIn('s1', 'mem-1');

    final visits = await e.db.select(e.db.visits).get();
    final leaves = await e.db.select(e.db.leaves).get();
    expect(visits.length, 1);
    expect(visits.single.deleted, isFalse);
    expect(leaves.single.deleted, isTrue);

    final ops = await (e.db.select(
      e.db.ops,
    )..where((o) => o.changeId.equals(res.changeId))).get();
    expect(ops.map((o) => o.tbl).toSet(), {'visits', 'leaves'});

    await res.undo!.run();
    final visitsAfter = await e.db.select(e.db.visits).get();
    final leavesAfter = await e.db.select(e.db.leaves).get();
    expect(visitsAfter.single.deleted, isTrue);
    expect(leavesAfter.single.deleted, isFalse);
  });

  test('markOut at same ms advances outAt by 60000 ms', () async {
    final e = await _env();
    await e.repo.markIn('s1', 'mem-1');
    final open = await e.db.select(e.db.visits).getSingle();
    await e.repo.markOut(open, 'mem-1');
    final updated = await e.db.select(e.db.visits).getSingle();
    expect(updated.outAt, open.inAt! + 60000);
  });

  test('setLeave on twice keeps single row with id staffId_date', () async {
    final e = await _env();
    await e.repo.setLeave(
      staffId: 's1',
      date: '2026-11-20',
      on: true,
      memberId: 'mem-1',
    );
    await e.repo.setLeave(
      staffId: 's1',
      date: '2026-11-20',
      on: true,
      memberId: 'mem-1',
    );
    final leaves = await e.db.select(e.db.leaves).get();
    expect(leaves.length, 1);
    expect(leaves.single.id, 's1_2026-11-20');
  });

  test('addStaff title-cases name and removeStaff can be undone', () async {
    final e = await _env();
    await e.repo.addStaff(
      name: ' kamala ',
      role: 'House help',
      payType: 'monthly',
      amountPaise: 600000,
      expectedTime: '09:00',
      color: '#4F8A8B',
      today: '2026-11-20',
    );
    final staff = await e.db.select(e.db.staff).getSingle();
    expect(staff.name, 'Kamala');
    expect(staff.active, isTrue);

    final rem = await e.repo.removeStaff(staff.id, '2026-11-20');
    final afterRem = await e.db.select(e.db.staff).getSingle();
    expect(afterRem.active, isFalse);
    expect(afterRem.endDate, '2026-11-20');

    await rem.undo!.run();
    final afterUndo = await e.db.select(e.db.staff).getSingle();
    expect(afterUndo.active, isTrue);
  });

  test(
    'two markIn calls leave one visit both concurrently and sequentially',
    () async {
      final e = await _env();
      await Future.wait([
        e.repo.markIn('s1', 'mem-1'),
        e.repo.markIn('s1', 'mem-1'),
      ]);
      final s1Visits = await (e.db.select(
        e.db.visits,
      )..where((v) => v.staffId.equals('s1'))).get();
      expect(s1Visits.length, 1);

      await e.repo.markIn('s2', 'mem-1');
      await e.repo.markIn('s2', 'mem-1');
      final s2Visits = await (e.db.select(
        e.db.visits,
      )..where((v) => v.staffId.equals('s2'))).get();
      expect(s2Visits.length, 1);
    },
  );

  test('addStaff creates multiple distinct active helpers and pay rules', () async {
    final e = await _env();
    await e.repo.addStaff(
      name: 'kamala',
      role: 'House help',
      payType: 'monthly',
      amountPaise: 600000,
      expectedTime: '09:00',
      color: '#4F8A8B',
      today: '2026-11-20',
    );
    await e.repo.addStaff(
      name: 'lakshmi',
      role: 'Cook',
      payType: 'monthly',
      amountPaise: 700000,
      expectedTime: '08:00',
      color: '#8A5A2B',
      today: '2026-11-20',
    );

    final active = await e.repo.watchActive('NM-TEST').first;
    expect(active.map((s) => s.name).toList(), ['Kamala', 'Lakshmi']);
    expect(active.map((s) => s.id).toSet().length, 2);

    final rules = await e.db.select(e.db.payRules).get();
    expect(rules.length, 2);
    expect(rules.map((r) => r.staffId).toSet(), active.map((s) => s.id).toSet());
  });

  test('setLeave records paid flag, toggles informed <-> paid with Undo, and markIn restores paid leave on undo', () async {
    final e = await _env();
    await e.repo.setLeave(
      staffId: 's1',
      date: '2026-11-20',
      on: true,
      paid: false,
      memberId: 'mem-1',
    );
    var leave = await e.db.select(e.db.leaves).getSingle();
    expect(leave.paid, isFalse);
    expect(leave.deleted, isFalse);

    final toPaid = await e.repo.setLeave(
      staffId: 's1',
      date: '2026-11-20',
      on: true,
      paid: true,
      memberId: 'mem-1',
    );
    leave = await e.db.select(e.db.leaves).getSingle();
    expect(leave.id, 's1_2026-11-20');
    expect(leave.paid, isTrue);

    await toPaid.undo!.run();
    leave = await e.db.select(e.db.leaves).getSingle();
    expect(leave.paid, isFalse);

    await e.repo.setLeave(
      staffId: 's1',
      date: '2026-11-20',
      on: true,
      paid: true,
      memberId: 'mem-1',
    );
    final markInRes = await e.repo.markIn('s1', 'mem-1');
    leave = await e.db.select(e.db.leaves).getSingle();
    expect(leave.deleted, isTrue);

    await markInRes.undo!.run();
    leave = await e.db.select(e.db.leaves).getSingle();
    expect(leave.deleted, isFalse);
    expect(leave.paid, isTrue);
  });
}
