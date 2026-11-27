import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/trip_state.dart';

void main() {
  group('classifyTrip', () {
    const today = '2026-11-27';

    test('identifies startingSoon (0..3 days), upcoming, ongoing & past', () {
      expect(
        classifyTrip(
          startDate: '2026-11-27',
          today: today,
          totalItems: 5,
          doneItems: 2,
        ).phase,
        TripPhase.startingSoon,
      );
      expect(
        classifyTrip(
          startDate: '2026-11-30',
          today: today,
          totalItems: 5,
          doneItems: 5,
        ).isReady,
        isTrue,
      );
      expect(
        classifyTrip(
          startDate: '2026-12-01',
          today: today,
          totalItems: 4,
          doneItems: 0,
        ).phase,
        TripPhase.upcoming,
      );
      expect(
        classifyTrip(
          startDate: '2026-11-25',
          endDate: '2026-11-29',
          today: today,
          totalItems: 4,
          doneItems: 4,
        ).phase,
        TripPhase.ongoing,
      );
      expect(
        classifyTrip(
          startDate: '2026-11-20',
          endDate: '2026-11-24',
          today: today,
          totalItems: 4,
          doneItems: 1,
        ).phase,
        TripPhase.past,
      );
      // Ignores an endDate earlier than startDate and treats trip as single-day.
      expect(
        classifyTrip(
          startDate: '2026-11-28',
          endDate: '2026-11-20',
          today: today,
          totalItems: 1,
          doneItems: 0,
        ).phase,
        TripPhase.startingSoon,
      );
    });
  });

  group('splitAndSortTrips', () {
    test('separates active (soonest first) and past (most recent first)', () {
      final rows = [
        (title: 'Ooty', start: '2026-11-10', end: '2026-11-12'),
        (title: 'Goa', start: '2026-12-05', end: null),
        (title: 'Coorg', start: '2026-11-28', end: '2026-11-30'),
        (title: 'Mysore', start: '2026-11-22', end: null),
      ];

      final res = splitAndSortTrips(
        rows,
        startDateOf: (r) => r.start,
        endDateOf: (r) => r.end,
        titleOf: (r) => r.title,
        today: '2026-11-27',
      );

      expect(res.upcoming.map((r) => r.title), ['Coorg', 'Goa']);
      expect(res.past.map((r) => r.title), ['Mysore', 'Ooty']);
    });
  });

  test('filterMissingTemplateTitles deduplicates case-insensitively', () {
    expect(
      filterMissingTemplateTitles(
        ['  chargers ', 'Medicines'],
        ['Chargers', 'ID cards', 'medicines', 'Power bank', 'id cards', '  '],
      ),
      ['ID cards', 'Power bank'],
    );
  });
}
