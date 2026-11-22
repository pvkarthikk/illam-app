import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/domain/attendance_calendar.dart';
import 'package:nm_flat/core/time/dates.dart';

int _ms(String date, int hh, int mm) => Dates.msAt(date, hh * 60 + mm);

void main() {
  const today = '2026-11-20';
  const workDays = [1, 2, 3, 4, 5, 6];

  test('cellFor classifies worked intensity and non-worked states', () {
    final c135 = cellFor(
      date: '2026-11-18',
      today: today,
      workDays: workDays,
      startDate: '2026-11-01',
      endDate: null,
      visits: [
        VisitLite(
          id: 'v1',
          date: '2026-11-18',
          inAt: _ms('2026-11-18', 9, 0),
          outAt: _ms('2026-11-18', 11, 15),
        ),
      ],
      leave: false,
      nowMs: _ms(today, 12, 0),
    );
    expect(c135.kind, CellKind.worked);
    expect(c135.intensity, closeTo(0.8125, 1e-6));

    final c300 = cellFor(
      date: '2026-11-17',
      today: today,
      workDays: workDays,
      startDate: '2026-11-01',
      endDate: null,
      visits: [
        VisitLite(
          id: 'v2',
          date: '2026-11-17',
          inAt: _ms('2026-11-17', 9, 0),
          outAt: _ms('2026-11-17', 14, 0),
        ),
      ],
      leave: false,
      nowMs: _ms(today, 12, 0),
    );
    expect(c300.intensity, 1.0);

    expect(
      cellFor(
        date: '2026-11-19',
        today: today,
        workDays: workDays,
        startDate: '2026-11-01',
        endDate: null,
        visits: const [],
        leave: false,
        nowMs: 0,
      ).kind,
      CellKind.absent,
    );
    expect(
      cellFor(
        date: '2026-11-19',
        today: today,
        workDays: workDays,
        startDate: '2026-11-01',
        endDate: null,
        visits: const [],
        leave: true,
        nowMs: 0,
      ).kind,
      CellKind.leave,
    );
    expect(
      cellFor(
        date: '2026-11-19',
        today: today,
        workDays: workDays,
        startDate: '2026-11-01',
        endDate: null,
        visits: [
          VisitLite(
            id: 'v3',
            date: '2026-11-19',
            inAt: _ms('2026-11-19', 9, 0),
            outAt: _ms('2026-11-19', 10, 0),
          ),
        ],
        leave: true,
        nowMs: 0,
      ).kind,
      CellKind.worked,
    );
    expect(
      cellFor(
        date: '2026-11-02',
        today: today,
        workDays: workDays,
        startDate: '2026-11-10',
        endDate: null,
        visits: const [],
        leave: false,
        nowMs: 0,
      ).kind,
      CellKind.beforeStart,
    );
    expect(
      cellFor(
        date: '2026-11-23',
        today: today,
        workDays: workDays,
        startDate: '2026-11-01',
        endDate: null,
        visits: const [],
        leave: false,
        nowMs: 0,
      ).kind,
      CellKind.upcoming,
    );
    expect(
      cellFor(
        date: today,
        today: today,
        workDays: workDays,
        startDate: '2026-11-01',
        endDate: null,
        visits: const [],
        leave: false,
        nowMs: 0,
      ).kind,
      CellKind.notMarkedYet,
    );
    expect(
      cellFor(
        date: '2026-11-15',
        today: today,
        workDays: workDays,
        startDate: '2026-11-01',
        endDate: null,
        visits: const [],
        leave: false,
        nowMs: 0,
      ).kind,
      CellKind.off,
    );
  });

  test('statsFor counts present, absent and hours', () {
    final cells = [
      const DayCell('2026-11-18', CellKind.worked, 135, 0.8, false),
      const DayCell('2026-11-19', CellKind.worked, 142, 0.8, false),
      const DayCell('2026-11-16', CellKind.absent, 0, 0, false),
    ];
    final stats = statsFor(cells, {
      '2026-11-18': [
        VisitLite(
          id: 'a',
          date: '2026-11-18',
          inAt: _ms('2026-11-18', 9, 0),
          outAt: _ms('2026-11-18', 11, 15),
        ),
      ],
      '2026-11-19': [
        VisitLite(
          id: 'b',
          date: '2026-11-19',
          inAt: _ms('2026-11-19', 9, 0),
          outAt: _ms('2026-11-19', 11, 22),
        ),
      ],
    });
    expect(stats.present, 2);
    expect(stats.absent, 1);
    expect(stats.hours.toStringAsFixed(1), '4.6');
  });
}
