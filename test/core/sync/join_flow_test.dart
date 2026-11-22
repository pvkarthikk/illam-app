import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/crypto/bytes.dart';
import 'package:nm_flat/core/crypto/device_keys.dart';
import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';
import 'package:nm_flat/core/sync/join/active_invite.dart';
import 'package:nm_flat/core/sync/join/join_guest.dart';
import 'package:nm_flat/core/sync/join/join_host.dart';
import 'package:nm_flat/core/sync/net/framed_connection.dart';
import 'package:nm_flat/core/sync/net/secure_channel.dart';
import 'package:nm_flat/core/sync/protocol/join_messages.dart';
import 'package:nm_flat/core/sync/sync_store.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';

class FakeAdmitter implements JoinAdmitter {
  @override
  Future<int> admit(
    SecureChannel ch,
    JoinRequest r,
    String role,
    String via,
    void Function(int sent, int total) progress,
  ) async {
    await ch.send({'t': 'ops', 'batch': <Object>[]});
    await ch.send({'t': 'done'});
    await ch.receive();
    return 0;
  }
}

class FakeReceiver implements JoinReceiver {
  @override
  Future<int> receive(
    SecureChannel ch,
    String homeId,
    String? expectedHomeId,
    void Function(int got, int total) progress,
  ) async {
    await ch.receive(); // ops
    await ch.receive(); // done
    progress(1, 1);
    await ch.send({'t': 'ack'});
    return 1;
  }
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('ActiveInvite tracks failures and expiry, DeviceKeys.deviceIdFor matches', () async {
    final created = DateTime(2026, 11, 20, 9);
    final inv = ActiveInvite.create('47-mango-river-tulip', now: created);
    expect(inv.isOpen(created.add(const Duration(minutes: 9))), isTrue);
    expect(inv.isOpen(created.add(const Duration(minutes: 11))), isFalse);

    inv.registerFailure();
    inv.registerFailure();
    expect(inv.status, InviteStatus.open);
    inv.registerFailure();
    expect(inv.status, InviteStatus.void_);
    expect(inv.isOpen(created), isFalse);

    final keys = await DeviceKeys.fromSeeds(
      List.filled(32, 1),
      List.filled(32, 2),
    );
    expect(await DeviceKeys.deviceIdFor(keys.signPub), keys.deviceId);
  });

  test('SyncStore.allOpsWire returns applied ops ordered by seq', () async {
    final db = NestDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final prefs = await DevicePrefs.inMemory();
    final clock = FixedClock(DateTime(2026, 11, 20, 9));
    final writer = ChangeWriter(
      db,
      CollectionRegistry.build(db),
      HlcClock(clock, prefs),
      prefs,
    );

    await writer.write('one', (c) {
      c.create('items', {'name': 'Milk', 'list': 'grocery'});
    }, homeId: 'H1');
    await writer.write('two', (c) {
      c.create('items', {'name': 'Bread', 'list': 'grocery'});
    }, homeId: 'H1');

    final wire = await SyncStore(db).allOpsWire('H1');
    final opsCount = (await db.select(db.ops).get()).length;
    expect(wire.length, opsCount);
    for (var i = 1; i < wire.length; i++) {
      expect(
        (wire[i]['seq'] as int),
        greaterThan(wire[i - 1]['seq'] as int),
      );
    }
  });

  group('flow', () {
    Future<
      ({
        List<JoinEvent> events,
        String? seenName,
        List<String> hostEmojis,
      })
    >
    run(
      ActiveInvite invite,
      String phrase, {
      String? decision = 'member',
      int version = 1,
      DateTime? hostNow,
    }) async {
      final (a, b) = FramedConnection.memoryPair();
      String? seenName;
      var hostEmojis = <String>[];
      final events = <JoinEvent>[];

      final keys = await DeviceKeys.fromSeeds(
        List.filled(32, 1),
        List.filled(32, 2),
      );
      final me = JoinRequest(
        name: 'Priya',
        model: 'Pixel',
        deviceId: keys.deviceId,
        signPub: keys.signPubB64,
        agreePub: b64(keys.agreePub),
      );

      final host = JoinHost(
        invite: invite,
        homeId: 'NM-TEST0001',
        homeName: 'Test Home',
        inviterName: 'Anand',
        admitter: FakeAdmitter(),
        now: hostNow != null ? () => hostNow : null,
        onRequest: (r, emojis) async {
          seenName = r.name;
          hostEmojis = emojis;
          return decision;
        },
      );
      final guest = JoinGuest(me, FakeReceiver(), version: version);
      final np = JoinPhrase.nameplate(phrase);
      final secret = JoinSecret(
        mode: 'phrase',
        password: JoinPhrase.password(phrase),
        context: JoinPhrase.context(np),
        nameplate: np,
      );

      await Future.wait([
        host.handle(b),
        guest.run(a, secret, events.add),
      ]);
      return (events: events, seenName: seenName, hostEmojis: hostEmojis);
    }

    test('right phrase succeeds with matching SAS and updates invite to used', () async {
      final inv = ActiveInvite.create('47-mango-river-tulip');
      final res = await run(inv, '47-mango-river-tulip');

      final codeOk = res.events.whereType<JoinCodeOk>().single;
      expect(codeOk.homeName, 'Test Home');
      expect(codeOk.inviterName, 'Anand');
      expect(codeOk.homeId, 'NM-TEST0001');

      final sas = res.events.whereType<JoinSas>().single;
      expect(sas.emojis, res.hostEmojis);

      expect(res.events.whereType<JoinApproved>().single.role, 'member');
      expect(res.events.whereType<JoinDone>(), hasLength(1));
      expect(res.seenName, 'Priya');
      expect(inv.status, InviteStatus.used);
    });

    test('3 wrong phrases void the invite, 4th with right phrase fails expired', () async {
      final inv = ActiveInvite.create('47-mango-river-tulip');
      for (var i = 0; i < 3; i++) {
        final r = await run(inv, '47-mango-river-zebra');
        expect(r.events.whereType<JoinFailed>().single.failure, JoinFailure.wrongCode);
      }
      expect(inv.status, InviteStatus.void_);
      final fourth = await run(inv, '47-mango-river-tulip');
      expect(
        fourth.events.whereType<JoinFailed>().single.failure,
        JoinFailure.expired,
      );
    });

    test('denied request emits JoinFailure.declined', () async {
      final inv = ActiveInvite.create('47-mango-river-tulip');
      final res = await run(inv, '47-mango-river-tulip', decision: null);
      expect(
        res.events.whereType<JoinFailed>().single.failure,
        JoinFailure.declined,
      );
    });

    test('expired invite emits JoinFailure.expired', () async {
      final now = DateTime(2026, 11, 20, 9, 15);
      final inv = ActiveInvite.create(
        '47-mango-river-tulip',
        now: now.subtract(const Duration(minutes: 11)),
      );
      final res = await run(inv, '47-mango-river-tulip', hostNow: now);
      expect(
        res.events.whereType<JoinFailed>().single.failure,
        JoinFailure.expired,
      );
    });

    test('mismatched protocol version emits JoinFailure.version', () async {
      final inv = ActiveInvite.create('47-mango-river-tulip');
      final res = await run(inv, '47-mango-river-tulip', version: 2);
      expect(
        res.events.whereType<JoinFailed>().single.failure,
        JoinFailure.version,
      );
    });
  });
}
