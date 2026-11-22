import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/routine_state.dart';

void main() {
  const today = '2026-11-20';

  group('routineState', () {
    test('every 3, last done 4 days ago -> overdue, ratio 0, bar danger', () {
      final s = routineState(
        lastDone: '2026-11-16',
        everyDays: 3,
        today: today,
      );
      expect(s.since, 4);
      expect(s.left, -1);
      expect(s.isDue, isTrue);
      expect(s.label, RoutineLabel.overdue);
      expect(s.tone, Tone.danger);
      expect(s.ratio, 0.0);
      expect(s.bar, BarTone.danger);
    });

    test('every 7, last done 5 days ago -> inDays, ratio ~0.2857, bar accent', () {
      final s = routineState(
        lastDone: '2026-11-15',
        everyDays: 7,
        today: today,
      );
      expect(s.since, 5);
      expect(s.left, 2);
      expect(s.isDue, isFalse);
      expect(s.label, RoutineLabel.inDays);
      expect(s.tone, Tone.ok);
      expect(s.ratio, closeTo(2 / 7, 1e-4));
      expect(s.bar, BarTone.accent);
    });

    test('every 1, last done 1 day ago -> dueToday', () {
      final s = routineState(
        lastDone: '2026-11-19',
        everyDays: 1,
        today: today,
      );
      expect(s.left, 0);
      expect(s.isDue, isTrue);
      expect(s.label, RoutineLabel.dueToday);
      expect(s.tone, Tone.accent);
    });

    test('every 90, last done 71 days ago -> left 19, ratio ~0.211, bar accent', () {
      final s = routineState(
        lastDone: '2026-09-10',
        everyDays: 90,
        today: today,
      );
      expect(s.since, 71);
      expect(s.left, 19);
      expect(s.label, RoutineLabel.inDays);
      expect(s.ratio, closeTo(19 / 90, 1e-3));
      expect(s.bar, BarTone.accent);
    });

    test('newRoutineLastDone produces dueToday', () {
      final lastDone = newRoutineLastDone(today, 7);
      expect(lastDone, '2026-11-13');
      final s = routineState(lastDone: lastDone, everyDays: 7, today: today);
      expect(s.label, RoutineLabel.dueToday);
      expect(s.left, 0);

      final emptyLast = routineState(lastDone: '', everyDays: 7, today: today);
      expect(emptyLast.label, RoutineLabel.dueToday);
    });
  });

  group('frequencyKind & tasksDueCount', () {
    test('frequencyKind maps 1/7/14/30/90/other', () {
      expect(frequencyKind(1), FrequencyKind.daily);
      expect(frequencyKind(7), FrequencyKind.weekly);
      expect(frequencyKind(14), FrequencyKind.fortnightly);
      expect(frequencyKind(30), FrequencyKind.monthly);
      expect(frequencyKind(90), FrequencyKind.every3Months);
      expect(frequencyKind(5), FrequencyKind.everyNDays);
    });

    test('tasksDueCount matches demo data count = 7', () {
      String ago(int days) => switch (days) {
        -1 => '2026-11-19',
        -4 => '2026-11-16',
        -5 => '2026-11-15',
        -6 => '2026-11-14',
        -16 => '2026-11-04',
        -71 => '2026-09-10',
        _ => throw ArgumentError('$days'),
      };

      final routines = [
        (lastDone: ago(-1), everyDays: 1), // Sweep & mop (due: left 0)
        (lastDone: ago(-1), everyDays: 1), // Wash utensils (due: left 0)
        (lastDone: ago(-4), everyDays: 3), // Clean bathrooms (due: left -1)
        (lastDone: ago(-5), everyDays: 7), // Change bedsheets (left 2)
        (lastDone: ago(-16), everyDays: 14), // Fridge clean-out (due: left -2)
        (lastDone: ago(-6), everyDays: 15), // Dust fans & windows (left 9)
        (lastDone: ago(-1), everyDays: 2), // Water the plants (left 1)
        (lastDone: ago(-71), everyDays: 90), // Change RO filter (left 19)
      ];

      final todos = [
        (due: '2026-11-19', done: false), // -1 open -> due
        (due: '2026-11-20', done: false), // 0 open -> due
        (due: '2026-11-20', done: false), // 0 open -> due
        (due: '2026-11-21', done: false), // +1 open
        (due: '2026-11-22', done: false), // +2 open
        (due: '2026-11-24', done: false), // +4 open
        (due: '2026-11-18', done: true), // -2 done
      ];

      expect(
        tasksDueCount(routines: routines, todos: todos, today: today),
        7,
      );
    });
  });
}
