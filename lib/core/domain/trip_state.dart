import 'package:nm_flat/core/time/dates.dart';

/// Lifecycle phase of a planned trip relative to `today`.
enum TripPhase { startingSoon, upcoming, ongoing, past }

/// Computed countdown and checklist readiness summary for a trip.
class TripStatus {
  const TripStatus({
    required this.phase,
    required this.daysUntilStart,
    required this.totalItems,
    required this.doneItems,
  });

  final TripPhase phase;
  final int daysUntilStart;
  final int totalItems;
  final int doneItems;

  int get remainingItems =>
      totalItems > doneItems ? totalItems - doneItems : 0;

  bool get isReady => totalItems > 0 && remainingItems == 0;

  double get progress => totalItems <= 0 ? 0.0 : doneItems / totalItems;
}

/// Evaluates [TripStatus] for a trip against [today] (`YYYY-MM-DD`).
TripStatus classifyTrip({
  required String startDate,
  String? endDate,
  required String today,
  required int totalItems,
  required int doneItems,
}) {
  final daysUntilStart = Dates.daysBetween(today, startDate);
  final effectiveEnd =
      (endDate != null && endDate.isNotEmpty && endDate.compareTo(startDate) >= 0)
          ? endDate
          : startDate;

  final TripPhase phase;
  if (today.compareTo(effectiveEnd) > 0) {
    phase = TripPhase.past;
  } else if (daysUntilStart < 0) {
    phase = TripPhase.ongoing;
  } else if (daysUntilStart <= 3) {
    phase = TripPhase.startingSoon;
  } else {
    phase = TripPhase.upcoming;
  }

  return TripStatus(
    phase: phase,
    daysUntilStart: daysUntilStart,
    totalItems: totalItems,
    doneItems: doneItems,
  );
}

/// Splits [trips] into active (`upcoming` + `ongoing`, soonest first) and
/// `past` (most recent first) lists.
({List<T> upcoming, List<T> past}) splitAndSortTrips<T>(
  Iterable<T> trips, {
  required String Function(T) startDateOf,
  required String? Function(T) endDateOf,
  required String Function(T) titleOf,
  required String today,
}) {
  final upcoming = <T>[];
  final past = <T>[];

  for (final trip in trips) {
    final status = classifyTrip(
      startDate: startDateOf(trip),
      endDate: endDateOf(trip),
      today: today,
      totalItems: 0,
      doneItems: 0,
    );
    if (status.phase == TripPhase.past) {
      past.add(trip);
    } else {
      upcoming.add(trip);
    }
  }

  upcoming.sort((a, b) {
    final byDate = startDateOf(a).compareTo(startDateOf(b));
    return byDate != 0
        ? byDate
        : titleOf(a).toLowerCase().compareTo(titleOf(b).toLowerCase());
  });

  past.sort((a, b) {
    final byDate = startDateOf(b).compareTo(startDateOf(a));
    return byDate != 0
        ? byDate
        : titleOf(a).toLowerCase().compareTo(titleOf(b).toLowerCase());
  });

  return (upcoming: upcoming, past: past);
}

/// Returns trimmed, non-empty titles from [templateTitles] that are not
/// already present (case-insensitively) in [existingTitles].
List<String> filterMissingTemplateTitles(
  Iterable<String> existingTitles,
  Iterable<String> templateTitles,
) {
  final seen = <String>{
    for (final raw in existingTitles)
      if (raw.trim().isNotEmpty) raw.trim().toLowerCase(),
  };
  final missing = <String>[];
  for (final raw in templateTitles) {
    final clean = raw.trim();
    if (clean.isEmpty) continue;
    final key = clean.toLowerCase();
    if (seen.add(key)) {
      missing.add(clean);
    }
  }
  return missing;
}
