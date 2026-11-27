import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/trip_state.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/trips/trip_format.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Readiness summary card shown at the top of [TripDetailScreen].
class TripReadinessCard extends StatelessWidget {
  const TripReadinessCard({
    super.key,
    required this.trip,
    required this.status,
    required this.hasItems,
  });

  final TripRow trip;
  final TripStatus status;
  final bool hasItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final tag = tripBadgeTag(l10n, status);

    return NestCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  !hasItems
                      ? l10n.tripsNoItemsYet
                      : (status.isReady
                            ? l10n.tripsAllReadyTitle
                            : l10n.tripsRemainingCount(status.remainingItems)),
                  style: NestText.itemTitle16.copyWith(
                    color: status.isReady ? c.ok : c.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NestTag(label: tag.label, kind: tag.kind),
            ],
          ),
          if (trip.note != null && trip.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(trip.note!, style: NestText.meta13.copyWith(color: c.ink3)),
          ],
          const SizedBox(height: 12),
          NestProgressBar(
            value: status.progress,
            height: 8,
            color: status.isReady ? c.ok : c.primary,
          ),
          if (hasItems) ...[
            const SizedBox(height: 6),
            Text(
              l10n.tripsCheckedCount(status.doneItems, status.totalItems),
              style: NestText.small12.copyWith(color: c.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

/// Interactive checklist row with a 48dp checkbox and tap-to-edit label.
class TripChecklistRow extends StatelessWidget {
  const TripChecklistRow({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
  });

  final TripItemRow item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Row(
        children: [
          const SizedBox(width: 4),
          NestCheckbox(
            value: item.done,
            semanticLabel: item.title,
            onChanged: onToggle,
          ),
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title,
                      style: NestText.body16.copyWith(
                        color: item.done ? c.ink3 : c.ink,
                        decoration: item.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens a modal sheet to rename, promote to Generic checklist, or delete [item].
Future<void> showTripItemSheet(
  BuildContext context,
  WidgetRef ref, {
  required TripItemRow item,
  required List<TripTemplateItemRow> templateItems,
}) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController(text: item.title);
  final alreadyGeneric = filterMissingTemplateTitles(
    [for (final t in templateItems) t.title],
    [item.title],
  ).isEmpty;
  try {
    await showNestSheet<void>(
      context,
      (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(title: l10n.tripsEditItemTitle),
          TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.tripsItemLabel,
              counterText: '',
            ),
          ),
          if (!alreadyGeneric) ...[
            const SizedBox(height: 8),
            NestButton(
              label: l10n.tripsSaveToGeneric,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () async {
                final text = ctrl.text.trim();
                final title = text.isEmpty ? item.title : text;
                final res = await ref
                    .read(tripsRepoProvider)
                    .addTemplateItem(title, sortOrder: templateItems.length);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                ref
                    .read(snackbarProvider)
                    .show(l10n.tripsSavedToGeneric, undo: res.undo);
              },
            ),
          ],
          const SizedBox(height: 12),
          NestButton(
            label: l10n.tripsSaveChanges,
            kind: NestButtonKind.primary,
            size: NestButtonSize.block,
            onPressed: () async {
              final next = ctrl.text.trim();
              if (next.isEmpty) return;
              Navigator.of(ctx).pop();
              if (next != item.title) {
                await ref
                    .read(tripsRepoProvider)
                    .updateTripItem(item.id, next);
              }
            },
          ),
          const SizedBox(height: 8),
          NestButton(
            label: l10n.tripsDeleteItem,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: () async {
              final res = await ref
                  .read(tripsRepoProvider)
                  .deleteTripItem(item.id);
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              ref
                  .read(snackbarProvider)
                  .show(l10n.tripsItemDeleted, undo: res.undo);
            },
          ),
        ],
      ),
    );
  } finally {
    ctrl.dispose();
  }
}
