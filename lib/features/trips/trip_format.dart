import 'package:intl/intl.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/trip_state.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Formats a trip's single date or `start – end` range cleanly.
String formatTripDateRange(String startDate, String? endDate) {
  if (startDate.isEmpty) return '';
  final fmt = DateFormat('d MMM', 'en');
  final startText = fmt.format(Dates.parse(startDate));
  if (endDate == null ||
      endDate.isEmpty ||
      endDate.compareTo(startDate) <= 0) {
    return startText;
  }
  final endText = fmt.format(Dates.parse(endDate));
  return '$startText – $endText';
}

/// Computes [TripStatus] for [trip] from all items matching its id.
TripStatus summarizeTrip(
  TripRow trip,
  List<TripItemRow> allItems,
  String today,
) {
  var total = 0;
  var done = 0;
  for (final item in allItems) {
    if (item.tripId == trip.id) {
      total++;
      if (item.done) done++;
    }
  }
  return classifyTrip(
    startDate: trip.startDate,
    endDate: trip.endDate,
    today: today,
    totalItems: total,
    doneItems: done,
  );
}

/// Localized relative countdown phrase for a non-past or past trip.
String tripWhenText(AppLocalizations l10n, TripStatus status) {
  switch (status.phase) {
    case TripPhase.past:
      return l10n.tripsPast;
    case TripPhase.ongoing:
      return l10n.tripsOngoing;
    case TripPhase.startingSoon:
    case TripPhase.upcoming:
      if (status.daysUntilStart <= 0) return l10n.tripsStartsToday;
      if (status.daysUntilStart == 1) return l10n.tripsStartsTomorrow;
      return l10n.tripsInDays(status.daysUntilStart);
  }
}

/// Badge text and semantic style shown on trip summary cards and detail views.
({String label, NestTagKind kind}) tripBadgeTag(
  AppLocalizations l10n,
  TripStatus status,
) {
  if (status.phase == TripPhase.past) {
    return (label: l10n.tripsPast, kind: NestTagKind.neutral);
  }
  if (status.isReady) {
    return (label: l10n.tripsReady, kind: NestTagKind.ok);
  }
  if (status.phase == TripPhase.ongoing) {
    return (label: l10n.tripsOngoing, kind: NestTagKind.info);
  }
  final label = tripWhenText(l10n, status);
  final kind = status.phase == TripPhase.startingSoon
      ? NestTagKind.accent
      : NestTagKind.info;
  return (label: label, kind: kind);
}
