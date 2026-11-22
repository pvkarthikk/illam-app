import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/reminder_rules.dart';

const _mon = '2026-11-23';
const _sun = '2026-11-22';

ReminderInputs _inputs({
  String today = _mon,
  DateTime? now,
  List<StaffInfo> staff = const [],
  Map<String, List<DateTime>> visitStartsToday = const {},
  Set<String> onLeaveToday = const {},
  int dueCount = 0,
  List<String> dueTitles = const [],
  List<BillInfo> bills = const [],
  bool iAddedSpendToday = true,
  bool arrivalOn = true,
  bool digestOn = true,
  bool billOn = true,
  bool eveningOn = true,
}) => ReminderInputs(
  today: today,
  now: now ?? DateTime(2026, 11, 23, 8, 10),
  staff: staff,
  visitStartsToday: visitStartsToday,
  onLeaveToday: onLeaveToday,
  dueCount: dueCount,
  dueTitles: dueTitles,
  bills: bills,
  iAddedSpendToday: iAddedSpendToday,
  arrivalOn: arrivalOn,
  digestOn: digestOn,
  billOn: billOn,
  eveningOn: eveningOn,
);

const _lakshmi = StaffInfo(
  id: 's1',
  name: 'Lakshmi',
  startDate: '2026-08-01',
  active: true,
  workDays: [1, 2, 3, 4, 5, 6],
  expectedTimes: ['09:00'],
);

void main() {
  test('Lakshmi Monday schedules arrival at 09:15', () {
    final res = planToday(_inputs(staff: const [_lakshmi]));
    expect(res.length, 1);
    final r = res.single;
    expect(r.kind, ReminderKind.arrival);
    expect(r.key, 'arrival:s1:$_mon:0900');
    expect(r.at, DateTime(2026, 11, 23, 9, 15));
    expect(r.data['time'], '09:00');
  });

  test('visit started at 06:30 still plans 09:15 arrival', () {
    final res = planToday(
      _inputs(
        staff: const [_lakshmi],
        visitStartsToday: {
          's1': [DateTime(2026, 11, 23, 6, 30)],
        },
      ),
    );
    expect(res.length, 1);
  });

  test('visit started at 08:05 skips arrival', () {
    final res = planToday(
      _inputs(
        staff: const [_lakshmi],
        visitStartsToday: {
          's1': [DateTime(2026, 11, 23, 8, 5)],
        },
      ),
    );
    expect(res, isEmpty);
  });

  test('on leave skips arrival', () {
    final res = planToday(
      _inputs(staff: const [_lakshmi], onLeaveToday: const {'s1'}),
    );
    expect(res, isEmpty);
  });

  test('Sunday skips Mon-Sat staff', () {
    final res = planToday(
      _inputs(today: _sun, now: DateTime(2026, 11, 22, 8, 10), staff: const [_lakshmi]),
    );
    expect(res, isEmpty);
  });

  test('Selvi twice a day plans two arrivals sorted by time', () {
    const selvi = StaffInfo(
      id: 's2',
      name: 'Selvi',
      startDate: '2026-08-01',
      active: true,
      workDays: [1, 2, 3, 4, 5, 6],
      expectedTimes: ['18:00', '07:30'],
    );
    final res = planToday(_inputs(staff: const [selvi]));
    expect(res.length, 2);
    expect(res[0].at, DateTime(2026, 11, 23, 7, 45));
    expect(res[1].at, DateTime(2026, 11, 23, 18, 15));
  });

  test('ended yesterday or arrivalOn false plans nothing', () {
    const ended = StaffInfo(
      id: 's1',
      name: 'Lakshmi',
      startDate: '2026-08-01',
      endDate: '2026-11-22',
      active: true,
      workDays: [1, 2, 3, 4, 5, 6],
      expectedTimes: ['09:00'],
    );
    expect(planToday(_inputs(staff: const [ended])), isEmpty);
    expect(
      planToday(_inputs(staff: const [_lakshmi], arrivalOn: false)),
      isEmpty,
    );
  });

  test('digest plans at 08:00 only when dueCount > 0', () {
    expect(planToday(_inputs(dueCount: 0)), isEmpty);
    final res = planToday(
      _inputs(dueCount: 3, dueTitles: const ['A', 'B', 'C']),
    );
    expect(res.length, 1);
    expect(res.single.kind, ReminderKind.digest);
    expect(res.single.at, DateTime(2026, 11, 23, 8, 0));
    expect(res.single.data['count'], 3);
  });

  test('bill rules respect active, remind, paid, dueDate, firstDueMonth', () {
    BillInfo bill({
      String dueDate = _mon,
      String firstDueMonth = '2026-08',
      bool paid = false,
      bool remind = true,
      bool active = true,
    }) => BillInfo(
      id: 'b1',
      name: 'Electricity',
      method: 'upi',
      dueDate: dueDate,
      firstDueMonth: firstDueMonth,
      usualPaise: 198000,
      active: active,
      remind: remind,
      paidThisMonth: paid,
    );

    final dueToday = planToday(_inputs(bills: [bill()]));
    expect(dueToday.length, 1);
    expect(dueToday.single.kind, ReminderKind.bill);
    expect(dueToday.single.at, DateTime(2026, 11, 23, 10, 0));

    expect(planToday(_inputs(bills: [bill(paid: true)])), isEmpty);
    expect(planToday(_inputs(bills: [bill(dueDate: '2026-11-24')])), isEmpty);
    expect(planToday(_inputs(bills: [bill(firstDueMonth: '2026-12')])), isEmpty);
  });

  test('evening plans at 21:00 only when switch on and no spend today', () {
    final res = planToday(_inputs(iAddedSpendToday: false, eveningOn: true));
    expect(res.length, 1);
    expect(res.single.kind, ReminderKind.evening);
    expect(res.single.at, DateTime(2026, 11, 23, 21, 0));

    expect(planToday(_inputs(iAddedSpendToday: true, eveningOn: true)), isEmpty);
    expect(planToday(_inputs(iAddedSpendToday: false, eveningOn: false)), isEmpty);
  });

  test('stillValid checks quiet hours and updated planToday', () {
    final digest = planToday(_inputs(dueCount: 2, dueTitles: const ['A', 'B'])).single;
    expect(
      stillValid(
        digest,
        _inputs(now: DateTime(2026, 11, 23, 22, 30), dueCount: 2),
      ),
      isFalse,
    );
    expect(
      stillValid(
        digest,
        _inputs(now: DateTime(2026, 11, 23, 8, 10), dueCount: 2),
      ),
      isTrue,
    );

    final arrival = planToday(_inputs(staff: const [_lakshmi])).single;
    expect(
      stillValid(
        arrival,
        _inputs(
          staff: const [_lakshmi],
          visitStartsToday: {
            's1': [DateTime(2026, 11, 23, 9, 5)],
          },
        ),
      ),
      isFalse,
    );
  });
}
