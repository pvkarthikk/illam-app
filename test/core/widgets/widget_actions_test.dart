import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/widgets/widget_actions.dart';
import 'package:nm_flat/core/widgets/widget_bridge.dart';

class _FakeBridge extends WidgetBridge {
  Map<String, Object?>? lastStaff;
  Map<String, Object?>? lastTodos;
  Map<String, Object?>? lastMoney;
  List<Map<String, Object?>> queue = [];
  final List<String> ackedIds = [];

  @override
  Future<void> updateSnapshots({
    required Map<String, Object?> staff,
    required Map<String, Object?> todos,
    Map<String, Object?>? money,
  }) async {
    lastStaff = staff;
    lastTodos = todos;
    lastMoney = money;
  }

  @override
  Future<List<Map<String, Object?>>> takePendingActions() async =>
      List<Map<String, Object?>>.from(queue);

  @override
  Future<void> ackPendingActions(List<String> ids) async {
    ackedIds.addAll(ids);
    queue.removeWhere((e) => ids.contains(e['id']));
  }
}

Future<ProviderContainer> _openTestContainer(FixedClock clock) async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('H1');
  await prefs.setMemberId('m1');

  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
  );
  await changes.write('Seed home', (c) {
    c.create('homes', {'name': 'Our Home', 'vault_id': 'v1'}, id: 'H1');
    c.create('members', {
      'full_name': 'Anand',
      'first_name': 'Anand',
      'role': 'admin',
      'status': 'active',
    }, id: 'm1');
  });

  final container = ProviderContainer(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(MemorySecureStore()),
      clockProvider.overrideWithValue(clock),
    ],
  );
  addTearDown(container.dispose);
  await container.read(currentHomeIdProvider.future);
  return container;
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('staff_mark_in and staff_mark_out are idempotent and update snapshots', () async {
    final clock = FixedClock(DateTime(2026, 11, 25, 8, 30));
    final c = await _openTestContainer(clock);
    final bridge = _FakeBridge();

    await c.read(staffRepoProvider).addStaff(
      name: 'lakshmi',
      role: 'Cook',
      payType: 'monthly',
      amountPaise: 600000,
      expectedTime: '08:00',
      color: '#4F8A8B',
      today: '2026-11-25',
    );
    final staff = await c.read(staffRepoProvider).watchActive('H1').first;
    final staffId = staff.single.id;

    expect(
      await executeWidgetAction(c.read, {
        'action': 'staff_mark_in',
        'staffId': staffId,
      }),
      isTrue,
    );
    // Double mark-in is a no-op.
    expect(
      await executeWidgetAction(c.read, {
        'action': 'staff_mark_in',
        'staffId': staffId,
      }),
      isFalse,
    );

    await pushWidgetSnapshots(c.read, bridge: bridge);
    final items1 = bridge.lastStaff!['items']! as List;
    final row1 = items1.single as Map<String, Object?>;
    expect(row1['status'], 'in');
    expect(row1['action'], 'mark_out');

    clock.advance(const Duration(minutes: 45));
    expect(
      await executeWidgetAction(c.read, {
        'action': 'staff_mark_out',
        'staffId': staffId,
      }),
      isTrue,
    );
    // Already marked out -> no-op.
    expect(
      await executeWidgetAction(c.read, {
        'action': 'staff_mark_out',
        'staffId': staffId,
      }),
      isFalse,
    );

    await pushWidgetSnapshots(c.read, bridge: bridge);
    final items2 = bridge.lastStaff!['items']! as List;
    final row2 = items2.single as Map<String, Object?>;
    expect(row2['status'], 'done');
    expect(row2['action'], 'mark_in');
    expect(row2['actionLabel'], '+ Visit');
  });

  test('add_todo, complete_todo, and complete_routine drain & push snapshots', () async {
    final clock = FixedClock(DateTime(2026, 11, 25, 9, 0));
    final c = await _openTestContainer(clock);
    final bridge = _FakeBridge();

    await c.read(tasksRepoProvider).createRoutine(
      name: 'Mop kitchen',
      room: 'Kitchen',
      everyDays: 7,
      assigneeType: 'member',
      assignee: 'm1',
      today: '2026-11-25',
    );

    bridge.queue = [
      {'id': 'a1', 'action': 'add_todo', 'title': '  buy filter coffee  '},
      {'id': 'a2', 'action': 'add_todo', 'title': '   '}, // blank ignored & acked
    ];
    expect(await drainPendingWidgetActions(c.read, bridge: bridge), isTrue);
    expect(bridge.ackedIds, ['a1', 'a2']);
    expect(bridge.queue, isEmpty);

    await pushWidgetSnapshots(c.read, bridge: bridge);
    expect(bridge.lastTodos!['totalCount'], 2);
    final items = (bridge.lastTodos!['items']! as List)
        .cast<Map<String, Object?>>();
    expect(items.map((e) => e['title']), ['Buy filter coffee', 'Mop kitchen']);

    final todoId = items[0]['id']! as String;
    final routineId = items[1]['id']! as String;
    expect(
      await executeWidgetAction(c.read, {
        'action': 'complete_todo',
        'itemId': todoId,
      }),
      isTrue,
    );
    expect(
      await executeWidgetAction(c.read, {
        'action': 'complete_routine',
        'itemId': routineId,
      }),
      isTrue,
    );

    await pushWidgetSnapshots(c.read, bridge: bridge);
    expect(bridge.lastTodos!['totalCount'], 0);
    expect(bridge.lastTodos!['items'] as List, isEmpty);
  });

  test('add_spend drains from queue as manual expense and updates money snapshot', () async {
    final clock = FixedClock(DateTime(2026, 11, 25, 11, 0));
    final c = await _openTestContainer(clock);
    final bridge = _FakeBridge();

    bridge.queue = [
      {
        'id': 's1',
        'action': 'add_spend',
        'amountPaise': 24500,
        'merchant': 'Milk Booth',
        'category': 'Groceries',
        'method': 'upi',
        'date': '2026-11-25',
      },
      {
        'id': 's2',
        'action': 'add_spend',
        'amountPaise': 0, // invalid zero amount ignored & acked
        'merchant': 'Invalid',
      },
    ];

    expect(await drainPendingWidgetActions(c.read, bridge: bridge), isTrue);
    expect(bridge.ackedIds, ['s1', 's2']);
    expect(bridge.queue, isEmpty);

    await pushWidgetSnapshots(c.read, bridge: bridge);
    expect(bridge.lastMoney, isNotNull);
    expect(bridge.lastMoney!['hasHome'], isTrue);
    expect(bridge.lastMoney!['monthSpentPaise'], 24500);
    expect(bridge.lastMoney!['monthSpentText'], '₹245');

    final rows = await c.read(moneyRepoProvider).watchExpensesInMonth('2026-11').first;
    expect(rows.length, 1);
    expect(rows.single.merchant, 'Milk Booth');
    expect(rows.single.source, 'manual');
    expect(rows.single.category, 'Groceries');
  });
}
