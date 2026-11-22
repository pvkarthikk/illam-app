import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/time/dates.dart';

int _ms(String date, int hh, int mm) => Dates.msAt(date, hh * 60 + mm);

void main() {
  const fri = '2026-11-20';
  const sun = '2026-11-22';
  const workDays = [1, 2, 3, 4, 5, 6];

  group('staffStatusToday and mergedMinutes', () {
    test('leave overrides open/closed/expected', () {
      expect(
        staffStatusToday(
          today: fri,
          workDays: workDays,
          visitsToday: const [],
          leaveToday: true,
        ),
        isA<StatusLeave>(),
      );
    });

    test('open visit yields StatusIn with inAt', () {
      final inAt = _ms(fri, 9, 5);
      final s = staffStatusToday(
        today: fri,
        workDays: workDays,
        visitsToday: [VisitLite(id: 'v1', date: fri, inAt: inAt)],
        leaveToday: false,
      );
      expect(s, isA<StatusIn>());
      expect((s as StatusIn).sinceMs, inAt);
    });

    test('closed visits sum minutes and report last out', () {
      final out2 = _ms(fri, 19, 0);
      final s = staffStatusToday(
        today: fri,
        workDays: workDays,
        visitsToday: [
          VisitLite(
            id: 'v1',
            date: fri,
            inAt: _ms(fri, 9, 0),
            outAt: _ms(fri, 11, 0),
          ),
          VisitLite(id: 'v2', date: fri, inAt: _ms(fri, 18, 0), outAt: out2),
        ],
        leaveToday: false,
      );
      expect(s, isA<StatusDone>());
      final done = s as StatusDone;
      expect(done.totalMinutes, 180);
      expect(done.lastOutMs, out2);
    });

    test('no visits yields StatusExpected on work day and StatusOff on Sunday', () {
      expect(
        staffStatusToday(
          today: fri,
          workDays: workDays,
          visitsToday: const [],
          leaveToday: false,
        ),
        isA<StatusExpected>(),
      );
      expect(
        staffStatusToday(
          today: sun,
          workDays: workDays,
          visitsToday: const [],
          leaveToday: false,
        ),
        isA<StatusOff>(),
      );
    });

    test('mergedMinutes unions overlapping intervals and ignores open visits', () {
      expect(
        mergedMinutes([
          VisitLite(
            id: 'a',
            date: fri,
            inAt: _ms(fri, 9, 0),
            outAt: _ms(fri, 11, 0),
          ),
          VisitLite(
            id: 'b',
            date: fri,
            inAt: _ms(fri, 10, 30),
            outAt: _ms(fri, 12, 0),
          ),
          VisitLite(id: 'open', date: fri, inAt: _ms(fri, 14, 0)),
        ]),
        180,
      );
      expect(
        mergedMinutes([
          VisitLite(
            id: 'a',
            date: fri,
            inAt: _ms(fri, 9, 0),
            outAt: _ms(fri, 11, 15),
          ),
          VisitLite(
            id: 'b',
            date: fri,
            inAt: _ms(fri, 18, 0),
            outAt: _ms(fri, 18, 7),
          ),
        ]),
        142,
      );
    });
  });

  group('validateVisit, canTouchLeave, firstOverlap', () {
    test('validateVisit checks all rules in order', () {
      final nowMs = _ms(fri, 12, 0);
      final inAt = _ms(fri, 9, 0);

      expect(
        validateVisit(inAt: null, outAt: null, isAdmin: true, nowMs: nowMs),
        VisitError.missingIn,
      );
      expect(
        validateVisit(inAt: inAt, outAt: inAt, isAdmin: true, nowMs: nowMs),
        VisitError.outNotAfterIn,
      );
      expect(
        validateVisit(
          inAt: inAt,
          outAt: inAt + kMaxVisitMs + 60000,
          isAdmin: true,
          nowMs: nowMs,
        ),
        VisitError.tooLong,
      );
      expect(
        validateVisit(
          inAt: inAt,
          outAt: inAt + kMaxVisitMs,
          isAdmin: true,
          nowMs: nowMs,
        ),
        isNull,
      );

      final threeDaysAgo = nowMs - const Duration(days: 3).inMilliseconds;
      expect(
        validateVisit(
          inAt: threeDaysAgo,
          outAt: threeDaysAgo + 3600000,
          isAdmin: false,
          nowMs: nowMs,
        ),
        VisitError.memberTooOld,
      );
      expect(
        validateVisit(
          inAt: threeDaysAgo,
          outAt: threeDaysAgo + 3600000,
          isAdmin: true,
          nowMs: nowMs,
        ),
        isNull,
      );

      final fortySevenHoursAgo =
          nowMs - const Duration(hours: 47).inMilliseconds;
      expect(
        validateVisit(
          inAt: fortySevenHoursAgo,
          outAt: fortySevenHoursAgo + 3600000,
          isAdmin: false,
          nowMs: nowMs,
        ),
        isNull,
      );
    });

    test('canTouchLeave enforces 48h window for non-admins', () {
      expect(canTouchLeave(isAdmin: false, date: fri, today: fri), isTrue);
      expect(
        canTouchLeave(isAdmin: false, date: '2026-11-19', today: fri),
        isTrue,
      );
      expect(
        canTouchLeave(isAdmin: false, date: '2026-11-18', today: fri),
        isFalse,
      );
      expect(
        canTouchLeave(isAdmin: true, date: '2026-11-18', today: fri),
        isTrue,
      );
    });

    test('firstOverlap detects overlapping intervals and treats touching as separate', () {
      final vExisting = VisitLite(
        id: 'e1',
        date: fri,
        inAt: _ms(fri, 9, 0),
        outAt: _ms(fri, 10, 30),
      );
      expect(
        firstOverlap(
          [vExisting],
          inAt: _ms(fri, 10, 0),
          outAt: _ms(fri, 11, 0),
          nowMs: _ms(fri, 12, 0),
        ),
        vExisting,
      );
      expect(
        firstOverlap(
          [vExisting],
          inAt: _ms(fri, 11, 0),
          outAt: _ms(fri, 12, 0),
          nowMs: _ms(fri, 12, 0),
        ),
        isNull,
      );
      expect(
        firstOverlap(
          [VisitLite(id: 'open', date: fri, inAt: _ms(fri, 9, 0))],
          inAt: _ms(fri, 9, 30),
          outAt: _ms(fri, 9, 45),
          nowMs: _ms(fri, 10, 0),
        )?.id,
        'open',
      );
    });
  });

  group('alertsFor', () {
    test('detects past unclosed and multiple open visits', () {
      final a1 = alertsFor(
        openVisits: [
          VisitLite(id: '1', date: '2026-11-18', inAt: _ms('2026-11-18', 9, 0)),
        ],
        today: fri,
      );
      expect(a1.length, 1);
      expect(a1.single, isA<NotMarkedOut>());
      expect(a1.single.date, '2026-11-18');

      final a2 = alertsFor(
        openVisits: [
          VisitLite(id: '1', date: fri, inAt: _ms(fri, 9, 0)),
          VisitLite(id: '2', date: fri, inAt: _ms(fri, 10, 0)),
        ],
        today: fri,
      );
      expect(a2.length, 1);
      expect(a2.single, isA<TwoOpenVisits>());
      expect(a2.single.date, fri);

      expect(
        alertsFor(
          openVisits: [VisitLite(id: '1', date: fri, inAt: _ms(fri, 9, 0))],
          today: fri,
        ),
        isEmpty,
      );
    });
  });
}
