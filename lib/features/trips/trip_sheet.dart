import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/trips/trip_format.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Opens a modal sheet to create a trip (returning its id) or edit [existing].
Future<String?> showTripSheet(
  BuildContext context, {
  TripRow? existing,
}) => showNestSheet<String?>(
  context,
  (_) => _TripSheet(existing: existing),
);

class _TripSheet extends ConsumerStatefulWidget {
  const _TripSheet({this.existing});

  final TripRow? existing;

  @override
  ConsumerState<_TripSheet> createState() => _TripSheetState();
}

class _TripSheetState extends ConsumerState<_TripSheet> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late String _startDate;
  String? _endDate;
  bool _includeGeneric = true;
  String? _titleError;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final today = ref.read(todayDateProvider);
    final ex = widget.existing;
    if (ex != null) {
      _titleCtrl.text = ex.title;
      _noteCtrl.text = ex.note ?? '';
      _startDate = ex.startDate.isEmpty ? today : ex.startDate;
      _endDate = (ex.endDate != null && ex.endDate!.isNotEmpty)
          ? ex.endDate
          : null;
    } else {
      _startDate = Dates.addDays(today, 1);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate(String today) async {
    final todayDt = Dates.parse(today);
    final minCandidate = Dates.parse(Dates.addDays(today, -30));
    final cur = Dates.parse(_startDate);
    final firstDate = cur.isBefore(minCandidate) ? cur : minCandidate;
    final lastDate = DateTime(todayDt.year + 5, todayDt.month, todayDt.day);
    final initialDate = cur.isAfter(lastDate) ? lastDate : cur;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (!mounted || picked == null) return;
    final iso = Dates.iso(picked);
    setState(() {
      _startDate = iso;
      if (_endDate != null && _endDate!.compareTo(iso) < 0) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate(String today) async {
    final startDt = Dates.parse(_startDate);
    final todayDt = Dates.parse(today);
    final lastDate = DateTime(todayDt.year + 5, todayDt.month, todayDt.day);
    final currentEnd = _endDate != null ? Dates.parse(_endDate!) : startDt;
    final initial = currentEnd.isBefore(startDt)
        ? startDt
        : (currentEnd.isAfter(lastDate) ? lastDate : currentEnd);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: startDt,
      lastDate: lastDate.isBefore(startDt) ? startDt : lastDate,
    );
    if (!mounted || picked == null) return;
    setState(() => _endDate = Dates.iso(picked));
  }

  Future<void> _save(
    AppLocalizations l10n,
    List<TripTemplateItemRow> templateItems,
  ) async {
    if (_saving) return;
    final rawTitle = _titleCtrl.text.trim();
    if (rawTitle.isEmpty) {
      setState(() => _titleError = l10n.tripsNameRequired);
      return;
    }
    final title = '${rawTitle[0].toUpperCase()}${rawTitle.substring(1)}';
    final cleanNote = _noteCtrl.text.trim();
    final noteVal = cleanNote.isEmpty ? null : cleanNote;

    setState(() => _saving = true);
    var closed = false;
    try {
      final repo = ref.read(tripsRepoProvider);
      final snack = ref.read(snackbarProvider);
      final ex = widget.existing;
      if (ex == null) {
        final created = await repo.createTrip(
          title: title,
          startDate: _startDate,
          endDate: _endDate,
          note: noteVal,
          initialItems: _includeGeneric
              ? [for (final t in templateItems) t.title]
              : const [],
        );
        if (!mounted) return;
        closed = true;
        Navigator.of(context).pop(created.id);
        snack.show(l10n.tripsAdded, undo: created.result.undo);
      } else {
        final diff = <String, Object?>{
          if (title != ex.title) 'title': title,
          if (_startDate != ex.startDate) 'start_date': _startDate,
          if (_endDate != ex.endDate) 'end_date': _endDate,
          if (noteVal != ex.note) 'note': noteVal,
        };
        if (diff.isEmpty) {
          closed = true;
          Navigator.of(context).pop();
          return;
        }
        closed = true;
        Navigator.of(context).pop();
        try {
          final res = await repo.updateTrip(ex.id, diff);
          snack.show(l10n.tripsUpdated, undo: res.undo);
        } on Object {
          snack.show(rejectText('other'));
        }
      }
    } finally {
      if (!closed && mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final ex = widget.existing;
    if (ex == null || _saving) return;
    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId ??
        '';
    setState(() => _saving = true);
    try {
      final res = await ref.read(tripsRepoProvider).deleteTrip(homeId, ex.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(snackbarProvider).show(l10n.tripsDeleted, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final templateItems =
        ref.watch(tripTemplateItemsProvider).value ??
        const <TripTemplateItemRow>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: _isEdit ? l10n.tripsEditTripTitle : l10n.tripsNewTripTitle,
        ),
        TextField(
          controller: _titleCtrl,
          autofocus: !_isEdit,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_titleError != null) setState(() => _titleError = null);
          },
          decoration: InputDecoration(
            labelText: l10n.tripsNameLabel,
            hintText: l10n.tripsNameHint,
            counterText: '',
            errorText: _titleError,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.tripsStartDate,
          style: NestText.small12.copyWith(color: c.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            NestChip(
              label: formatTripDateRange(_startDate, null),
              leading: Icon(
                Icons.event_outlined,
                size: 16,
                color: c.paper,
              ),
              selected: true,
              onTap: () => _pickStartDate(today),
            ),
            NestChip(
              label: _endDate == null
                  ? l10n.tripsAddEndDate
                  : '${l10n.tripsEndDate}: ${formatTripDateRange(_endDate!, null)}',
              selected: _endDate != null,
              onTap: () => _pickEndDate(today),
            ),
            if (_endDate != null)
              IconButton(
                tooltip: l10n.tripsClearEndDate,
                icon: Icon(Icons.close_rounded, color: c.ink3),
                onPressed: () => setState(() => _endDate = null),
              ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _noteCtrl,
          maxLength: 120,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.tripsNoteLabel,
            hintText: l10n.tripsNoteHint,
            counterText: '',
          ),
        ),
        if (!_isEdit && templateItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          SwitchRow(
            title: l10n.tripsIncludeGeneric(templateItems.length),
            value: _includeGeneric,
            onChanged: (v) => setState(() => _includeGeneric = v),
          ),
        ],
        const SizedBox(height: 20),
        NestButton(
          label: _isEdit ? l10n.tripsSaveChanges : l10n.tripsSaveTrip,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _saving ? null : () => _save(l10n, templateItems),
        ),
        if (_isEdit) ...[
          const SizedBox(height: 10),
          NestButton(
            label: l10n.tripsDeleteTrip,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: _saving ? null : () => _delete(l10n),
          ),
        ],
      ],
    );
  }
}
