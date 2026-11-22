import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:nm_flat/core/data/ops/op_record.dart';
import 'package:nm_flat/core/sync/validator.dart';

class FakeView implements ValidationView {
  FakeView(this.devices, this.rows);

  final Map<String, MemberInfo> devices;
  final Map<String, Map<String, Object?>> rows;

  static const _fields = <String, Set<String>>{
    'items': {'name', 'done', 'qty_milli', 'deleted'},
    'homes': {'name', 'vault_id', 'deleted'},
    'members': {'full_name', 'role', 'deleted'},
    'pay_rules': {'amount_paise'},
    'visits': {'in_at', 'out_at', 'staff_id', 'deleted'},
    'expenses': {'amount_paise', 'source', 'added_by', 'deleted'},
    'bills': {'name', 'deleted'},
    'backup_status': {
      'member_id',
      'frequency',
      'recovery_capable',
      'off_phone',
      'dests_json',
      'deleted',
    },
  };

  @override
  Future<MemberInfo?> memberForDevice(String deviceId) async => devices[deviceId];

  @override
  Future<Map<String, Object?>?> row(String tbl, String id) async =>
      rows['$tbl/$id'];

  @override
  Future<String?> creatingChangeId(String tbl, String id) async =>
      rows.containsKey('$tbl/$id') ? 'c0' : null;

  @override
  Set<String> fieldsOf(String tbl) => _fields[tbl] ?? const {};
}

const _now = 1763600000000;
const _hMs = 3600000;

String _h(int ms) => '${ms.toString().padLeft(13, '0')}.0000.x';

OpRecord _op(
  String dev,
  String member,
  String tbl,
  String id,
  String field,
  Object? value, {
  String kind = 'set',
  int? delta,
  int at = _now,
  String changeId = 'c1',
  int seq = 1,
}) => OpRecord(
  opId: '$dev:$seq',
  homeId: 'h1',
  deviceId: dev,
  seq: seq,
  hlc: _h(at),
  authorMemberId: member,
  changeId: changeId,
  tbl: tbl,
  entityId: id,
  kind: kind,
  field: field,
  valueJson: kind == 'inc' ? null : jsonEncode(value),
  delta: delta,
);

FakeView _makeView() => FakeView(
  {
    'dA': const MemberInfo(memberId: 'A', role: 'admin', status: 'active'),
    'dM': const MemberInfo(memberId: 'M', role: 'member', status: 'active'),
    'dR': MemberInfo(
      memberId: 'R',
      role: 'member',
      status: 'removed',
      endedHlc: _h(500),
    ),
  },
  {
    'homes/h1': {'id': 'h1', 'name': 'Home', 'vault_id': 'v1'},
    'members/A': {'id': 'A', 'full_name': 'Admin'},
    'members/M': {'id': 'M', 'full_name': 'Member'},
    'visits/v1': {
      'id': 'v1',
      'in_at': _now - 49 * _hMs,
      'out_at': _now - 41 * _hMs,
      'staff_id': 's1',
    },
    'visits/v2': {'id': 'v2', 'in_at': _now - 2 * _hMs, 'staff_id': 's1'},
    'expenses/e1': {'id': 'e1', 'added_by': 'A', 'source': 'manual', 'amount_paise': 100},
    'expenses/e2': {'id': 'e2', 'added_by': 'M', 'source': 'manual', 'amount_paise': 100},
    'bills/b1': {'id': 'b1', 'created_by': 'A'},
    'bills/b2': {'id': 'b2', 'created_by': 'M'},
    'items/i1': {'id': 'i1', 'qty_milli': 1000},
  },
);

Future<Decision> _check(FakeView view, OpRecord op, [List<OpRecord>? change]) =>
    const Validator().check(op, change ?? [op], view, nowMs: _now);

void main() {
  test('1: member sets items/i9.done = true (new row) -> accept', () async {
    final d = await _check(
      _makeView(),
      _op('dM', 'M', 'items', 'i9', 'done', true),
    );
    expect(d.verdict, Verdict.accept);
  });

  test('2: member sets homes/h1.name -> quarantine adminOnly', () async {
    final d = await _check(
      _makeView(),
      _op('dM', 'M', 'homes', 'h1', 'name', 'New Home'),
    );
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'adminOnly');
  });

  test('3: admin sets homes/h1.name = 41 chars -> range', () async {
    final d = await _check(
      _makeView(),
      _op('dA', 'A', 'homes', 'h1', 'name', 'a' * 41),
    );
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'range');
  });

  test('4: member edits own vs admin profile -> accept / ownOnly', () async {
    final v = _makeView();
    final own = await _check(
      v,
      _op('dM', 'M', 'members', 'M', 'full_name', 'Me'),
    );
    final other = await _check(
      v,
      _op('dM', 'M', 'members', 'A', 'full_name', 'Other'),
    );
    expect(own.verdict, Verdict.accept);
    expect(other.verdict, Verdict.quarantine);
    expect(other.reason, 'ownOnly');
  });

  test('5: admin sets members/M.role directly -> membershipField', () async {
    final d = await _check(
      _makeView(),
      _op('dA', 'A', 'members', 'M', 'role', 'admin'),
    );
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'membershipField');
  });

  test('6: member sets pay_rules/p1.amount_paise -> adminOnly', () async {
    final d = await _check(
      _makeView(),
      _op('dM', 'M', 'pay_rules', 'p1', 'amount_paise', 1000),
    );
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'adminOnly');
  });

  test('7: member edits v1 (49h old) vs v2 (2h old) -> tooOld / accept', () async {
    final v = _makeView();
    final d1 = await _check(
      v,
      _op('dM', 'M', 'visits', 'v1', 'out_at', _now - 40 * _hMs),
    );
    final d2 = await _check(
      v,
      _op('dM', 'M', 'visits', 'v2', 'out_at', _now - _hMs),
    );
    expect(d1.verdict, Verdict.quarantine);
    expect(d1.reason, 'tooOld');
    expect(d2.verdict, Verdict.accept);
  });

  test('8: admin sets v1.out_at = in_at + 1h -> accept', () async {
    final d = await _check(
      _makeView(),
      _op('dA', 'A', 'visits', 'v1', 'out_at', _now - 48 * _hMs),
    );
    expect(d.verdict, Verdict.accept);
  });

  test('9: admin sets v2.out_at = in_at or in_at + 17h -> range / range', () async {
    final v = _makeView();
    final inAt = _now - 2 * _hMs;
    final dEq = await _check(v, _op('dA', 'A', 'visits', 'v2', 'out_at', inAt));
    final dLong = await _check(
      v,
      _op('dA', 'A', 'visits', 'v2', 'out_at', inAt + 17 * _hMs),
    );
    expect(dEq.verdict, Verdict.quarantine);
    expect(dEq.reason, 'range');
    expect(dLong.verdict, Verdict.quarantine);
    expect(dLong.reason, 'range');
  });

  test('10: member creates expense added_by A -> ownOnly', () async {
    final v = _makeView();
    final chg = [
      _op('dM', 'M', 'expenses', 'e9', 'added_by', 'A', seq: 1),
      _op('dM', 'M', 'expenses', 'e9', 'amount_paise', 100, seq: 2),
      _op('dM', 'M', 'expenses', 'e9', 'source', 'manual', seq: 3),
    ];
    final d = await _check(v, chg[0], chg);
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'ownOnly');
  });

  test('11: member sets e1 vs e2 amount_paise -> ownOnly / accept', () async {
    final v = _makeView();
    final d1 = await _check(
      v,
      _op('dM', 'M', 'expenses', 'e1', 'amount_paise', 200),
    );
    final d2 = await _check(
      v,
      _op('dM', 'M', 'expenses', 'e2', 'amount_paise', 200),
    );
    expect(d1.verdict, Verdict.quarantine);
    expect(d1.reason, 'ownOnly');
    expect(d2.verdict, Verdict.accept);
  });

  test('12: admin sets e2.source = order on existing row -> immutable', () async {
    final d = await _check(
      _makeView(),
      _op('dA', 'A', 'expenses', 'e2', 'source', 'order'),
    );
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'immutable');
  });

  test('13: member creates salary expense -> adminOnly', () async {
    final v = _makeView();
    final chg = [
      _op('dM', 'M', 'expenses', 'e8', 'added_by', 'M', seq: 1),
      _op('dM', 'M', 'expenses', 'e8', 'amount_paise', 100, seq: 2),
      _op('dM', 'M', 'expenses', 'e8', 'source', 'salary', seq: 3),
    ];
    final d = await _check(v, chg[0], chg);
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'adminOnly');
  });

  test('14: member deletes b1 vs b2 -> adminOnly / accept', () async {
    final v = _makeView();
    final d1 = await _check(v, _op('dM', 'M', 'bills', 'b1', 'deleted', true));
    final d2 = await _check(v, _op('dM', 'M', 'bills', 'b2', 'deleted', true));
    expect(d1.verdict, Verdict.quarantine);
    expect(d1.reason, 'adminOnly');
    expect(d2.verdict, Verdict.accept);
  });

  test('15: set on counter vs inc on non-counter -> counterSet / notCounter', () async {
    final v = _makeView();
    final dSet = await _check(
      v,
      _op('dA', 'A', 'items', 'i1', 'qty_milli', 500),
    );
    final dInc = await _check(
      v,
      _op('dA', 'A', 'items', 'i1', 'name', null, kind: 'inc', delta: 1),
    );
    expect(dSet.verdict, Verdict.quarantine);
    expect(dSet.reason, 'counterSet');
    expect(dInc.verdict, Verdict.quarantine);
    expect(dInc.reason, 'notCounter');
  });

  test('16: unknown device and future clock -> pending', () async {
    final v = _makeView();
    final dUnknown = await _check(
      v,
      _op('dX', 'X', 'items', 'i1', 'name', 'Milk'),
    );
    final dFuture = await _check(
      v,
      _op('dM', 'M', 'items', 'i1', 'name', 'Milk', at: _now + 6 * 60000),
    );
    expect(dUnknown.verdict, Verdict.pending);
    expect(dUnknown.reason, 'unknownDevice');
    expect(dFuture.verdict, Verdict.pending);
    expect(dFuture.reason, 'clockAhead');
  });

  test('17: removed device before vs after endedHlc -> accept / notMember', () async {
    final v = _makeView();
    final before = await _check(
      v,
      _op('dR', 'R', 'items', 'i7', 'done', true, at: 400),
    );
    final after = await _check(
      v,
      _op('dR', 'R', 'items', 'i7', 'done', true, at: 600),
    );
    expect(before.verdict, Verdict.accept);
    expect(after.verdict, Verdict.quarantine);
    expect(after.reason, 'notMember');
  });

  test('18: device writes another device backup_status row -> quarantine ownOnly', () async {
    final d = await _check(
      _makeView(),
      _op('dA', 'A', 'backup_status', 'dB', 'frequency', 'daily'),
    );
    expect(d.verdict, Verdict.quarantine);
    expect(d.reason, 'ownOnly');
  });

  test('19: plain member writes own device backup_status row -> accept', () async {
    final d = await _check(
      _makeView(),
      _op('dM', 'M', 'backup_status', 'dM', 'frequency', 'daily'),
    );
    expect(d.verdict, Verdict.accept);
  });
}
