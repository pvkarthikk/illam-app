import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/data/ops/op_record.dart';

void main() {
  test('OpRecord round-trips set and inc ops through toJson/fromJson', () {
    const setOp = OpRecord(
      opId: 'dev1:1',
      homeId: 'home-1',
      deviceId: 'dev1',
      seq: 1,
      hlc: '0000000001000.0000.dev1',
      authorMemberId: 'mem-1',
      changeId: 'chg-1',
      tbl: 'dev_notes',
      entityId: 'note-1',
      kind: 'set',
      field: 'title',
      valueJson: '"Milk"',
    );
    const incOp = OpRecord(
      opId: 'dev1:2',
      homeId: 'home-1',
      deviceId: 'dev1',
      seq: 2,
      hlc: '0000000001000.0001.dev1',
      authorMemberId: 'mem-1',
      changeId: 'chg-1',
      tbl: 'dev_notes',
      entityId: 'note-1',
      kind: 'inc',
      field: 'taps',
      delta: 1,
    );

    expect(OpRecord.fromJson(setOp.toJson()).toJson(), setOp.toJson());
    expect(OpRecord.fromJson(incOp.toJson()).toJson(), incOp.toJson());
  });
}
