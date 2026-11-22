import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/bootstrap.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/repo/home_repo.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/sync/membership_log.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

typedef _Env = ({
  NestDatabase db,
  DevicePrefs prefs,
  MemorySecureStore secure,
  FixedClock clock,
  HlcClock hlc,
  ChangeWriter changes,
});

Future<_Env> _env() async {
  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  final secure = MemorySecureStore();
  final clock = FixedClock(DateTime(2026, 11, 20, 9));
  final hlc = HlcClock(clock, prefs);
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    hlc,
    prefs,
  );
  return (
    db: db,
    prefs: prefs,
    secure: secure,
    clock: clock,
    hlc: hlc,
    changes: changes,
  );
}

void main() {
  group('Bootstrap', () {
    test('first run wipes once and switches to key deviceId', () async {
      final e = await _env();
      await e.changes.write(
        't',
        (c) => c.create('dev_notes', {'title': 'x'}),
        homeId: 'devlab',
      );
      expect(await e.db.select(e.db.devNotes).get(), hasLength(1));
      expect(e.prefs.deviceIdKind, 'random');

      final keys = await Bootstrap.ensureIdentity(
        secure: e.secure,
        prefs: e.prefs,
        db: e.db,
      );
      expect(await e.db.select(e.db.devNotes).get(), isEmpty);
      expect(e.prefs.deviceIdKind, 'key');
      expect(e.prefs.deviceId, keys.deviceId);

      await e.changes.write(
        't',
        (c) => c.create('dev_notes', {'title': 'y'}),
        homeId: 'devlab',
      );
      await Bootstrap.ensureIdentity(
        secure: e.secure,
        prefs: e.prefs,
        db: e.db,
      );
      expect(await e.db.select(e.db.devNotes).get(), hasLength(1));
    });
  });

  group('HomeRepo', () {
    test('createHome writes home, admin member, keys and prefs', () async {
      final e = await _env();
      final keys = await DeviceKeys.ensure(e.secure);
      final log = MembershipLog(
        e.db,
        Future.value(keys),
        e.hlc,
        e.clock,
        modelOf: () async => 'Test',
      );
      final repo = HomeRepo(
        e.db,
        e.changes,
        e.prefs,
        e.secure,
        e.clock,
        membershipLog: log,
      );

      final id = await repo.createHome(
        creatorName: 'anand kumar',
        homeName: 'Anand Home',
        keys: keys,
        createdAt: e.clock.nowMs,
        nonceB64: 'AAECAwQFBgcICQoLDA0ODw==',
        model: 'Test',
      );

      expect(RegExp(r'^NM-[A-Z2-7]{8}$').hasMatch(id), isTrue);

      final home = await (e.db.select(
        e.db.homes,
      )..where((h) => h.id.equals(id))).getSingle();
      expect(home.name, 'Anand Home');
      expect(home.genesisJson, isNotNull);
      expect(home.homeKeyId, 'genesis');

      final member = await (e.db.select(
        e.db.members,
      )..where((m) => m.id.equals(keys.deviceId))).getSingle();
      expect(member.fullName, 'Anand Kumar');
      expect(member.firstName, 'Anand');
      expect(member.role, 'admin');
      expect(member.status, 'active');
      expect(member.joinedVia, 'created');

      expect(e.prefs.currentHomeId, id);
      expect(e.prefs.memberId, keys.deviceId);
      expect(await e.secure.read('home.$id.key.genesis'), isNotNull);

      final ops = await e.db.select(e.db.ops).get();
      expect(ops, isNotEmpty);
      expect(ops.every((o) => o.homeId == id), isTrue);

      expect(await repo.watchMembers(id).first, hasLength(1));
      expect(await repo.watchHome(id).first, isNotNull);
    });
  });
}
