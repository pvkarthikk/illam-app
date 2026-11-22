import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class VisitEditor extends ConsumerStatefulWidget {
  const VisitEditor({
    super.key,
    required this.staffId,
    required this.date,
    this.visit,
    required this.dayVisits,
    required this.onCancel,
    required this.onSave,
  });

  final String staffId;
  final String date;
  final Visit? visit;
  final List<Visit> dayVisits;
  final VoidCallback onCancel;
  final void Function(int inAt, int? outAt) onSave;

  @override
  ConsumerState<VisitEditor> createState() => _VisitEditorState();
}

class _VisitEditorState extends ConsumerState<VisitEditor> {
  int? _inMinutes;
  int? _outMinutes;
  late String _outDate;
  VisitError? _error;

  @override
  void initState() {
    super.initState();
    _outDate = widget.date;
    final v = widget.visit;
    if (v?.inAt case final inMs?) {
      final dt = DateTime.fromMillisecondsSinceEpoch(inMs);
      _inMinutes = dt.hour * 60 + dt.minute;
    }
    if (v?.outAt case final outMs?) {
      final odt = DateTime.fromMillisecondsSinceEpoch(outMs);
      _outMinutes = odt.hour * 60 + odt.minute;
      final outDay = Dates.iso(odt);
      if (outDay == Dates.addDays(widget.date, 1)) {
        _outDate = outDay;
      }
    }
  }

  Future<void> _pickTime({required bool isOut}) async {
    final cur = isOut ? _outMinutes : _inMinutes;
    final initial = cur != null
        ? TimeOfDay(hour: cur ~/ 60, minute: cur % 60)
        : const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() {
      final mins = picked.hour * 60 + picked.minute;
      if (isOut) {
        _outMinutes = mins;
      } else {
        _inMinutes = mins;
      }
      _error = null;
    });
  }

  String _formatMins(int minutes) => Formatters.time12(
    DateTime(2026, 1, 1, minutes ~/ 60, minutes % 60),
  );

  void _handleSave() {
    final nowMs = ref.read(clockProvider).nowMs;
    final isAdmin = ref.read(isAdminProvider);
    final inAt = _inMinutes == null ? null : Dates.msAt(widget.date, _inMinutes!);
    final outAt = _outMinutes == null ? null : Dates.msAt(_outDate, _outMinutes!);

    final err = validateVisit(
      inAt: inAt,
      outAt: outAt,
      isAdmin: isAdmin,
      nowMs: nowMs,
      oldInAt: widget.visit?.inAt,
    );
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    if (inAt != null) {
      widget.onSave(inAt, outAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final nextDay = Dates.addDays(widget.date, 1);
    final nowMs = ref.read(clockProvider).nowMs;

    final inAt = _inMinutes == null ? null : Dates.msAt(widget.date, _inMinutes!);
    final outAt = _outMinutes == null ? null : Dates.msAt(_outDate, _outMinutes!);
    final overlap = inAt != null && (outAt == null || outAt > inAt)
        ? firstOverlap(
            [for (final v in widget.dayVisits) toLite(v)],
            inAt: inAt,
            outAt: outAt,
            nowMs: nowMs,
            ignoreId: widget.visit?.id,
          )
        : null;

    final errText = switch (_error) {
      VisitError.missingIn => l10n.staffErrNoIn,
      VisitError.outNotAfterIn => l10n.staffErrOutBeforeIn,
      VisitError.tooLong => l10n.staffErrTooLong,
      VisitError.memberTooOld => l10n.staffOnlyAdminsOlder,
      null => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.staffIn, style: NestText.meta13.copyWith(color: c.ink3)),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: NestButton(
            label: _inMinutes == null ? '—' : _formatMins(_inMinutes!),
            kind: NestButtonKind.ghost,
            size: NestButtonSize.sm,
            onPressed: () => _pickTime(isOut: false),
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.staffOut, style: NestText.meta13.copyWith(color: c.ink3)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NestChip(
              label: Formatters.dayLabel(widget.date, today, l10n),
              selected: _outDate == widget.date,
              onTap: () => setState(() {
                _outDate = widget.date;
                _error = null;
              }),
            ),
            NestChip(
              label: Formatters.dayLabel(nextDay, today, l10n),
              selected: _outDate == nextDay,
              onTap: () => setState(() {
                _outDate = nextDay;
                _error = null;
              }),
            ),
            NestButton(
              label: _outMinutes == null ? '—' : _formatMins(_outMinutes!),
              kind: NestButtonKind.ghost,
              size: NestButtonSize.sm,
              onPressed: () => _pickTime(isOut: true),
            ),
            if (_outMinutes != null)
              IconButton(
                tooltip: l10n.commonClose,
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => setState(() {
                  _outMinutes = null;
                  _error = null;
                }),
              ),
          ],
        ),
        if (overlap != null) ...[
          const SizedBox(height: 10),
          Text(
            l10n.staffOverlap(Formatters.time12Ms(overlap.inAt)),
            style: NestText.meta13.copyWith(color: c.accent),
          ),
        ],
        if (errText != null) ...[
          const SizedBox(height: 10),
          Text(
            errText,
            style: NestText.meta13.copyWith(color: c.danger),
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonCancel,
              kind: NestButtonKind.ghost,
              onPressed: widget.onCancel,
            ),
            NestButton(
              label: l10n.commonSave,
              kind: NestButtonKind.primary,
              onPressed: _handleSave,
            ),
          ],
        ),
      ],
    );
  }
}
