import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/core/util/json_util.dart';

import 'in_memory_replica.dart';

Future<List<OpRecord>> _generateOps(Random rnd) async {
  final prefs = await DevicePrefs.inMemory();
  final clock = FixedClock(DateTime(2026, 11, 20, 9));
  final hlcClock = HlcClock(clock, prefs);
  const noteIds = ['n1', 'n2', 'n3'];
  const titles = ['A', 'B', 'C', 'D', 'E'];

  final ops = <OpRecord>[];
  for (var seq = 1; seq <= 30; seq++) {
    clock.advance(Duration(seconds: rnd.nextInt(3)));
    final entityId = noteIds[rnd.nextInt(noteIds.length)];
    final hlc = await hlcClock.next();
    final opId = '${prefs.deviceId}:$seq';
    final kindChoice = rnd.nextInt(3);

    if (kindChoice == 0) {
      ops.add(
        OpRecord(
          opId: opId,
          homeId: 'devlab',
          deviceId: prefs.deviceId,
          seq: seq,
          hlc: hlc,
          authorMemberId: prefs.deviceId,
          changeId: 'chg-$opId',
          tbl: 'dev_notes',
          entityId: entityId,
          kind: 'set',
          field: 'title',
          valueJson: encodeValue(titles[rnd.nextInt(titles.length)]),
        ),
      );
    } else if (kindChoice == 1) {
      ops.add(
        OpRecord(
          opId: opId,
          homeId: 'devlab',
          deviceId: prefs.deviceId,
          seq: seq,
          hlc: hlc,
          authorMemberId: prefs.deviceId,
          changeId: 'chg-$opId',
          tbl: 'dev_notes',
          entityId: entityId,
          kind: 'set',
          field: 'pinned',
          valueJson: encodeValue(rnd.nextBool()),
        ),
      );
    } else {
      ops.add(
        OpRecord(
          opId: opId,
          homeId: 'devlab',
          deviceId: prefs.deviceId,
          seq: seq,
          hlc: hlc,
          authorMemberId: prefs.deviceId,
          changeId: 'chg-$opId',
          tbl: 'dev_notes',
          entityId: entityId,
          kind: 'inc',
          field: 'taps',
          delta: 1 + rnd.nextInt(5),
        ),
      );
    }
  }
  return ops;
}

void main() {
  test('two devices converge identically across all 20 shuffles and re-applies', () async {
    final opsA = await _generateOps(Random(1));
    final opsB = await _generateOps(Random(2));
    final allOps = [...opsA, ...opsB];
    const eq = DeepCollectionEquality();

    final first = InMemoryReplica();
    for (final op in allOps) {
      first.apply(op);
    }

    for (var seed = 0; seed < 20; seed++) {
      final shuffled = [...allOps]..shuffle(Random(seed));
      final replica = InMemoryReplica();
      for (final op in shuffled) {
        replica.apply(op);
      }
      expect(eq.equals(replica.rows, first.rows), isTrue);

      for (final op in shuffled) {
        replica.apply(op);
      }
      expect(eq.equals(replica.rows, first.rows), isTrue);
    }
  });
}
