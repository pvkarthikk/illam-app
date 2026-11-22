import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/local_membership_service.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/data/wipe.dart';
import 'package:nm_flat/core/providers.dart';

class FakeWiper extends PhoneWiper {
  FakeWiper(NestDatabase db, DevicePrefs prefs)
    : super(db, prefs, MemorySecureStore());

  int calls = 0;

  @override
  Future<void> wipeHome() async {
    calls++;
  }
}

Future<
  ({
    NestDatabase db,
    DevicePrefs prefs,
    FakeWiper wiper,
    LocalMembershipService service,
    LocalMembershipService arjunService,
    String todoId,
  })
>
_setup() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-TEST');
  await prefs.setMemberId('me');

  final container = ProviderContainer(
    overrides: [
      dbProvider.overrideWithValue(db),
      prefsProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(MemorySecureStore()),
    ],
  );
  addTearDown(container.dispose);

  final changes = container.read(changesProvider);
  final tasks = container.read(tasksRepoProvider);
  final wiper = FakeWiper(db, prefs);

  late String todoId;
  await changes.write('Seed membership test', (c) {
    c.create('homes', {'name': 'Test Home'}, id: 'NM-TEST');
    c.create('members', {
      'full_name': 'Anand Kumar',
      'first_name': 'Anand',
      'role': 'admin',
      'status': 'active',
    }, id: 'me');
    c.create('members', {
      'full_name': 'Arjun Anand',
      'first_name': 'Arjun',
      'role': 'member',
      'status': 'active',
    }, id: 'arjun');
    todoId = c.create('todos', {
      'title': 'Pay bill',
      'due': '2026-11-25',
      'assignee_type': 'member',
      'assignee': 'arjun',
      'done': false,
    });
  });

  final service = LocalMembershipService(
    db,
    changes,
    tasks,
    wiper,
    'NM-TEST',
    'me',
  );
  final arjunService = LocalMembershipService(
    db,
    changes,
    tasks,
    wiper,
    'NM-TEST',
    'arjun',
  );
  return (
    db: db,
    prefs: prefs,
    wiper: wiper,
    service: service,
    arjunService: arjunService,
    todoId: todoId,
  );
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('sole admin cannot step down', () async {
    final env = await _setup();
    final res = await env.service.setRole('me', 'member');
    expect(res.applied, isFalse);
    expect(res.reasonKey, 'homeLastAdmin');
  });

  test('admin can step down once another admin exists', () async {
    final env = await _setup();
    expect((await env.service.setRole('arjun', 'admin')).applied, isTrue);
    expect((await env.service.setRole('me', 'member')).applied, isTrue);
  });

  test('non-admin cannot change another member role', () async {
    final env = await _setup();
    final res = await env.arjunService.setRole('me', 'member');
    expect(res.applied, isFalse);
    expect(res.reasonKey, 'homeOnlyAdminsRoles');
  });

  test('removeMember marks removed and reassigns open work in one change', () async {
    final env = await _setup();
    final res = await env.service.removeMember('arjun');
    expect(res.applied, isTrue);

    final members = await env.db.select(env.db.members).get();
    final arjun = members.singleWhere((m) => m.id == 'arjun');
    expect(arjun.status, 'removed');

    final todo = await (env.db.select(
      env.db.todos,
    )..where((t) => t.id.equals(env.todoId))).getSingle();
    expect(todo.assignee, 'me');
    expect(todo.assigneeType, 'member');

    final ops = await (env.db.select(
      env.db.ops,
    )..where((o) => o.changeId.equals(res.change!.changeId))).get();
    final matchingIds = {'arjun', env.todoId};
    final relatedOps = ops.where((o) => matchingIds.contains(o.entityId)).toList();
    expect(relatedOps, isNotEmpty);
    expect(relatedOps.map((o) => o.changeId).toSet(), {res.change?.changeId});
  });

  test('leaveHome refuses sole admin with others and wipes after removal', () async {
    final env = await _setup();
    final refused = await env.service.leaveHome();
    expect(refused.applied, isFalse);
    expect(refused.reasonKey, 'homeChooseAdmin');
    expect(env.wiper.calls, 0);

    await env.service.removeMember('arjun');
    final left = await env.service.leaveHome();
    expect(left.applied, isTrue);
    expect(env.wiper.calls, 1);
  });

  test('renameHome validates length and updates home name', () async {
    final env = await _setup();
    final invalid = await env.service.renameHome('   ');
    expect(invalid.applied, isFalse);
    expect(invalid.reasonKey, 'homeNameLength');

    final ok = await env.service.renameHome('  Our flat  ');
    expect(ok.applied, isTrue);
    final home = await (env.db.select(
      env.db.homes,
    )..where((h) => h.id.equals('NM-TEST'))).getSingle();
    expect(home.name, 'Our flat');
  });
}
