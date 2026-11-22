import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/visit_editor.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showVisitSheet(
  BuildContext context, {
  required String staffId,
  required String date,
}) => showNestSheet<void>(
  context,
  (_) => _VisitSheet(staffId: staffId, date: date),
);

class _VisitSheet extends ConsumerStatefulWidget {
  const _VisitSheet({required this.staffId, required this.date});

  final String staffId;
  final String date;

  @override
  ConsumerState<_VisitSheet> createState() => _VisitSheetState();
}

class _VisitSheetState extends ConsumerState<_VisitSheet> {
  Visit? _editing;
  bool _adding = false;

  Future<void> _save(
    AppLocalizations l10n,
    int inAt,
    int? outAt,
  ) async {
    final me = ref.read(myMemberIdProvider);
    final res = await ref
        .read(staffRepoProvider)
        .saveVisit(
          id: _editing?.id,
          staffId: widget.staffId,
          inAt: inAt,
          outAt: outAt,
          memberId: me,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    ref.read(snackbarProvider).show(l10n.staffVisitUpdated, undo: res.undo);
  }

  Future<void> _remove(AppLocalizations l10n, String visitId) async {
    final res = await ref.read(staffRepoProvider).removeVisit(visitId);
    if (!mounted) return;
    Navigator.of(context).pop();
    ref.read(snackbarProvider).show(l10n.staffVisitRemoved, undo: res.undo);
  }

  Future<void> _toggleLeave(
    AppLocalizations l10n,
    String today,
    bool hasLeave,
  ) async {
    final me = ref.read(myMemberIdProvider);
    final res = await ref
        .read(staffRepoProvider)
        .setLeave(
          staffId: widget.staffId,
          date: widget.date,
          on: !hasLeave,
          memberId: me,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    final msg = hasLeave
        ? l10n.staffLeaveRemoved
        : l10n.staffLeaveMarked(
            Formatters.dayLabel(widget.date, today, l10n),
          );
    ref.read(snackbarProvider).show(msg, undo: res.undo);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final staff = ref.watch(staffByIdProvider(widget.staffId)).value;
    final dayKey = (widget.staffId, widget.date, widget.date);
    final visits = [
      ...(ref.watch(staffVisitsProvider(dayKey)).value ?? const <Visit>[]),
    ]..sort((a, b) => (a.inAt ?? 0).compareTo(b.inAt ?? 0));
    final leaves =
        ref.watch(staffLeavesProvider(dayKey)).value ?? const <Leave>[];
    final hasLeave = leaves.isNotEmpty;

    final month = Dates.month(widget.date);
    final settled = ref.watch(monthSettledProvider((widget.staffId, month)));
    final isAdmin = ref.watch(isAdminProvider);
    final readOnly = !isAdmin && Dates.daysBetween(widget.date, today) >= 2;
    final tickNow = ref.watch(minuteTickProvider).value;
    final nowMs =
        tickNow?.millisecondsSinceEpoch ?? ref.read(clockProvider).nowMs;

    final name = staff?.name ?? '';
    final header = NestSheetHeader(
      title: l10n.staffVisitTitle(
        name,
        Formatters.dayLabel(widget.date, today, l10n),
      ),
      lead: visits.isEmpty ? l10n.staffVisitLeadNone : l10n.staffVisitLeadSome,
    );

    if (_editing != null || _adding) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          VisitEditor(
            staffId: widget.staffId,
            date: widget.date,
            visit: _editing,
            dayVisits: visits,
            onCancel: () => setState(() {
              _editing = null;
              _adding = false;
            }),
            onSave: (inAt, outAt) => _save(l10n, inAt, outAt),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        if (settled) ...[
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: c.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.staffSettledNotice(Formatters.monthName(month)),
                  style: NestText.meta13.copyWith(color: c.info),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (readOnly) ...[
          Text(
            l10n.staffOnlyAdminsOlder,
            style: NestText.meta13.copyWith(color: c.ink3),
          ),
          const SizedBox(height: 12),
        ],
        for (final v in visits) ...[
          NestCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Formatters.time12Ms(v.inAt ?? 0)} – '
                        '${v.outAt != null ? Formatters.time12Ms(v.outAt!) : l10n.staffNow}',
                        style: NestText.itemTitle16.copyWith(color: c.ink),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.duration(liveMinutes([toLite(v)], nowMs)),
                  style: NestText.meta13.copyWith(color: c.ink2),
                ),
                if (!readOnly &&
                    canMemberTouchVisit(
                      isAdmin: isAdmin,
                      nowMs: nowMs,
                      oldInAt: v.inAt,
                    )) ...[
                  IconButton(
                    tooltip: l10n.staffEditVisit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => setState(() => _editing = v),
                  ),
                  IconButton(
                    tooltip: l10n.staffRemoveVisit,
                    icon: Icon(Icons.delete_outline, color: c.danger),
                    onPressed: () => _remove(l10n, v.id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (!readOnly) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NestButton(
                label: '+ ${l10n.staffAddVisit}',
                kind: NestButtonKind.ghost,
                size: NestButtonSize.sm,
                onPressed: () => setState(() => _adding = true),
              ),
              if (visits.isEmpty &&
                  canTouchLeave(
                    isAdmin: isAdmin,
                    date: widget.date,
                    today: today,
                  ))
                NestButton(
                  label: hasLeave ? l10n.staffUndoLeave : l10n.staffInformedLeave,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.sm,
                  onPressed: () => _toggleLeave(l10n, today, hasLeave),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
