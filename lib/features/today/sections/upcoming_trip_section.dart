import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/trip_state.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/trips/trip_format.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class UpcomingTripSection extends ConsumerWidget {
  const UpcomingTripSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider).value ?? const <TripRow>[];
    if (trips.isEmpty) return const SizedBox.shrink();

    final items =
        ref.watch(allTripItemsProvider).value ?? const <TripItemRow>[];
    final today = ref.watch(todayDateProvider);
    final sorted = splitAndSortTrips(
      trips,
      startDateOf: (t) => t.startDate,
      endDateOf: (t) => t.endDate,
      titleOf: (t) => t.title,
      today: today,
    ).upcoming;

    TripRow? bestTrip;
    TripStatus? bestStatus;
    for (final t in sorted) {
      final st = summarizeTrip(t, items, today);
      if (st.phase == TripPhase.startingSoon && st.remainingItems > 0) {
        bestTrip = t;
        bestStatus = st;
        break;
      }
    }
    if (bestTrip == null || bestStatus == null) {
      return const SizedBox.shrink();
    }

    final trip = bestTrip;
    final status = bestStatus;
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final meta = l10n.tripsTodayMeta(
      tripWhenText(l10n, status),
      status.remainingItems,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SectionHeader(
          title: l10n.tripsTodaySection,
          actionLabel: l10n.tripsOpenChecklist,
          onAction: () => context.push(Routes.trip(trip.id)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: NestCard(
            fill: c.accentSoft,
            borderColor: c.accent,
            onTap: () => context.push(Routes.trip(trip.id)),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: NestText.itemTitle16.copyWith(color: c.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta,
                            style: NestText.meta13.copyWith(color: c.ink2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, color: c.ink2),
                  ],
                ),
                const SizedBox(height: 10),
                NestProgressBar(
                  value: status.progress,
                  height: 6,
                  color: c.accentInk,
                  track: c.card,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
