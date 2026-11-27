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
import 'package:nm_flat/features/trips/trip_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class TripsView extends ConsumerStatefulWidget {
  const TripsView({super.key});

  @override
  ConsumerState<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends ConsumerState<TripsView> {
  bool _pastOpen = false;

  Future<void> _openNewTrip() async {
    final newId = await showTripSheet(context);
    if (newId == null || newId.isEmpty || !mounted) return;
    await context.push(Routes.trip(newId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final trips = ref.watch(tripsProvider).value ?? const <TripRow>[];
    final allItems =
        ref.watch(allTripItemsProvider).value ?? const <TripItemRow>[];
    final templateItems =
        ref.watch(tripTemplateItemsProvider).value ??
        const <TripTemplateItemRow>[];
    final today = ref.watch(todayDateProvider);

    final split = splitAndSortTrips(
      trips,
      startDateOf: (t) => t.startDate,
      endDateOf: (t) => t.endDate,
      titleOf: (t) => t.title,
      today: today,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestCard(
            onTap: () => context.push(Routes.tripTemplate),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.checklist_rounded,
                    color: c.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.tripsGenericTitle,
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.tripsGenericSub(templateItems.length),
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (split.upcoming.isEmpty)
            NestCard(
              child: EmptyState(
                icon: Icons.luggage_outlined,
                title: l10n.tripsEmptyTitle,
                body: l10n.tripsEmptyBody,
              ),
            )
          else
            for (var i = 0; i < split.upcoming.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _TripSummaryCard(
                trip: split.upcoming[i],
                status: summarizeTrip(split.upcoming[i], allItems, today),
              ),
            ],
          if (split.past.isNotEmpty) ...[
            const SizedBox(height: 16),
            NestCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => setState(() => _pastOpen = !_pastOpen),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.tripsPastHeader(split.past.length),
                                style: NestText.itemTitle16.copyWith(
                                  color: c.ink2,
                                ),
                              ),
                            ),
                            Icon(
                              _pastOpen
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: c.ink3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_pastOpen)
                    for (final trip in split.past) ...[
                      Container(height: 1, color: c.line),
                      _PastTripRow(
                        trip: trip,
                        status: summarizeTrip(trip, allItems, today),
                      ),
                    ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          NestButton(
            label: l10n.tripsNewTrip,
            icon: Icons.add_rounded,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: _openNewTrip,
          ),
        ],
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.trip, required this.status});

  final TripRow trip;
  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final tag = tripBadgeTag(l10n, status);
    final dateText = formatTripDateRange(trip.startDate, trip.endDate);

    return NestCard(
      onTap: () => context.push(Routes.trip(trip.id)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      dateText,
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NestTag(label: tag.label, kind: tag.kind),
            ],
          ),
          const SizedBox(height: 12),
          NestProgressBar(
            value: status.progress,
            height: 6,
            color: status.isReady ? c.ok : c.primary,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  status.totalItems == 0
                      ? l10n.tripsNoItemsYet
                      : l10n.tripsCheckedCount(
                          status.doneItems,
                          status.totalItems,
                        ),
                  style: NestText.small12.copyWith(color: c.ink2),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.ink3, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastTripRow extends StatelessWidget {
  const _PastTripRow({required this.trip, required this.status});

  final TripRow trip;
  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final dateText = formatTripDateRange(trip.startDate, trip.endDate);

    return InkWell(
      onTap: () => context.push(Routes.trip(trip.id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trip.title,
                      style: NestText.itemTitle16.copyWith(color: c.ink2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateText · ${l10n.tripsCheckedCount(status.doneItems, status.totalItems)}',
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.ink3),
            ],
          ),
        ),
      ),
    );
  }
}
