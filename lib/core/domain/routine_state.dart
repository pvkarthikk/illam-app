import 'package:nm_flat/core/time/dates.dart';

enum RoutineLabel { overdue, dueToday, dueTomorrow, inDays }

enum Tone { ok, accent, danger }

enum BarTone { primary, accent, danger }

enum FrequencyKind {
  daily,
  weekly,
  fortnightly,
  monthly,
  every3Months,
  everyNDays,
}

class RoutineState {
  const RoutineState({
    required this.since,
    required this.left,
    required this.ratio,
  });

  final int since;
  final int left;
  final double ratio;

  bool get isDue => left <= 0;

  RoutineLabel get label {
    if (left < 0) return RoutineLabel.overdue;
    if (left == 0) return RoutineLabel.dueToday;
    if (left == 1) return RoutineLabel.dueTomorrow;
    return RoutineLabel.inDays;
  }

  Tone get tone {
    if (left < 0) return Tone.danger;
    if (left == 0) return Tone.accent;
    return Tone.ok;
  }

  BarTone get bar {
    if (ratio > 0.5) return BarTone.primary;
    if (ratio > 0.2) return BarTone.accent;
    return BarTone.danger;
  }
}

String newRoutineLastDone(String today, int everyDays) =>
    Dates.addDays(today, -everyDays);

RoutineState routineState({
  required String lastDone,
  required int everyDays,
  required String today,
}) {
  final effectiveLast =
      lastDone.isEmpty ? newRoutineLastDone(today, everyDays) : lastDone;
  final since = Dates.daysBetween(effectiveLast, today);
  final left = everyDays - since;
  final safeEvery = everyDays <= 0 ? 1 : everyDays;
  final ratio = (1.0 - since / safeEvery).clamp(0.0, 1.0);
  return RoutineState(since: since, left: left, ratio: ratio);
}

FrequencyKind frequencyKind(int everyDays) => switch (everyDays) {
  1 => FrequencyKind.daily,
  7 => FrequencyKind.weekly,
  14 => FrequencyKind.fortnightly,
  30 => FrequencyKind.monthly,
  90 => FrequencyKind.every3Months,
  _ => FrequencyKind.everyNDays,
};

int tasksDueCount({
  required List<({String lastDone, int everyDays})> routines,
  required List<({String due, bool done})> todos,
  required String today,
}) {
  var count = 0;
  for (final r in routines) {
    if (routineState(
          lastDone: r.lastDone,
          everyDays: r.everyDays,
          today: today,
        ).left <=
        0) {
      count++;
    }
  }
  for (final t in todos) {
    if (!t.done && t.due.isNotEmpty && Dates.daysBetween(t.due, today) >= 0) {
      count++;
    }
  }
  return count;
}
