import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/domain/attendance_calendar.dart';
import 'package:nm_flat/core/domain/staff_text.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_controller.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/visit_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class AttendanceCalendarCard extends ConsumerWidget {
  const AttendanceCalendarCard({super.key, required this.staff});

  final StaffData staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final month = ref.watch(staffControllerProvider(staff.id));
    final ctrl = ref.read(staffControllerProvider(staff.id).notifier);
    final today = ref.watch(todayDateProvider);
    final tickNow = ref.watch(minuteTickProvider).value;
    final nowMs =
        tickNow?.millisecondsSinceEpoch ?? ref.read(clockProvider).nowMs;

    final first = Dates.monthStart(month);
    final daysCount = Dates.daysInMonth(month);
    final last = '$month-${daysCount.toString().padLeft(2, '0')}';

    final visits =
        ref.watch(staffVisitsProvider((staff.id, first, last))).value ??
        const [];
    final leaves =
        ref.watch(staffLeavesProvider((staff.id, first, last))).value ??
        const [];

    final visitsByDate = <String, List<VisitLite>>{};
    for (final v in visits) {
      final d = v.date;
      if (d != null) visitsByDate.putIfAbsent(d, () => []).add(toLite(v));
    }
    final leaveDates = {
      for (final l in leaves)
        if (l.date != null && !l.paid) l.date!,
    };
    final paidLeaveDates = {
      for (final l in leaves)
        if (l.date != null && l.paid) l.date!,
    };
    final isAdmin = ref.watch(isAdminProvider);

    final workDays =
        ref.watch(workDaysProvider((staff.id, month))) ??
        parseWorkDays(staff.workDays);
    final start = staff.startDate;
    final end = staff.endDate;
    final canPrev =
        start == null ||
        start.length < 7 ||
        Dates.addMonths(month, -1).compareTo(Dates.month(start)) >= 0;
    final canNext =
        Dates.addMonths(month, 1).compareTo(Dates.month(today)) <= 0;

    final cells = <DayCell>[
      for (var d = 1; d <= daysCount; d++)
        cellFor(
          date: '$month-${d.toString().padLeft(2, '0')}',
          today: today,
          workDays: workDays,
          startDate: staff.startDate,
          endDate: staff.endDate,
          visits:
              visitsByDate['$month-${d.toString().padLeft(2, '0')}'] ??
              const [],
          leave: leaveDates.contains('$month-${d.toString().padLeft(2, '0')}'),
          paidLeave: paidLeaveDates.contains(
            '$month-${d.toString().padLeft(2, '0')}',
          ),
          nowMs: nowMs,
        ),
    ];
    final stats = statsFor(cells, visitsByDate);
    final leadingBlanks = Dates.weekdayIso(first) - 1;
    final letters = l10n.weekdayLetters.split(',');

    return NestCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: SectionHeader(
                    title: l10n.staffMonthAttendance(
                      Formatters.monthName(month),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.staffPrevMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: canPrev ? ctrl.prev : null,
                ),
                IconButton(
                  tooltip: l10n.staffNextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: canNext ? ctrl.next : null,
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            children: [
              for (final letter in letters)
                ExcludeSemantics(
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontFamily: NestText.sans,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontVariations: const [FontVariation.weight(800)],
                        color: c.ink3,
                      ),
                    ),
                  ),
                ),
              for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
              for (var i = 0; i < cells.length; i++)
                _DayCellTile(
                  day: i + 1,
                  cell: cells[i],
                  tappable:
                      (isAdmin || cells[i].date.compareTo(today) <= 0) &&
                      (start == null || cells[i].date.compareTo(start) >= 0) &&
                      (end == null || cells[i].date.compareTo(end) <= 0),
                  onTap: () => showVisitSheet(
                    context,
                    staffId: staff.id,
                    date: cells[i].date,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _LegendItem(color: c.primary, label: l10n.staffLegendWorked),
                _LegendItem(color: c.dangerSoft, label: l10n.staffLegendAbsent),
                _LegendItem(color: c.infoSoft, label: l10n.staffLegendLeave),
                _LegendItem(
                  color: c.accentSoft,
                  label: l10n.staffLegendPaidLeave,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.line),
          IntrinsicHeight(
            child: Row(
              children: [
                _StatColumn(
                  value: '${stats.present}',
                  label: l10n.staffStatPresent,
                ),
                VerticalDivider(width: 1, color: c.line),
                _StatColumn(
                  value: '${stats.absent}',
                  label: l10n.staffStatAbsent,
                ),
                VerticalDivider(width: 1, color: c.line),
                _StatColumn(
                  value: stats.hours.toStringAsFixed(1),
                  label: l10n.staffStatHours,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCellTile extends StatelessWidget {
  const _DayCellTile({
    required this.day,
    required this.cell,
    required this.tappable,
    required this.onTap,
  });

  final int day;
  final DayCell cell;
  final bool tappable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final label = switch (cell.kind) {
      CellKind.worked => l10n.staffCellWorked(
        day,
        Formatters.duration(cell.minutes),
      ),
      CellKind.absent => l10n.staffCellAbsent(day),
      CellKind.leave => l10n.staffCellLeave(day),
      CellKind.paidLeave => l10n.staffCellPaidLeave(day),
      CellKind.off => l10n.staffCellOff(day),
      CellKind.upcoming => l10n.staffCellUpcoming(day),
      CellKind.notMarkedYet => l10n.staffCellNotMarked(day),
      CellKind.beforeStart => l10n.staffCellBeforeStart(day),
    };

    final Color? fill = switch (cell.kind) {
      CellKind.worked => Color.lerp(c.paper2, c.primary, cell.intensity),
      CellKind.absent => c.dangerSoft,
      CellKind.leave => c.infoSoft,
      CellKind.paidLeave => c.accentSoft,
      _ => null,
    };
    final Color fg = switch (cell.kind) {
      CellKind.worked => cell.intensity > 0.6 ? c.onPrimary : c.ink,
      CellKind.absent => c.danger,
      CellKind.leave => c.info,
      CellKind.paidLeave => c.accentInk,
      CellKind.off || CellKind.beforeStart => c.ink3.withValues(alpha: 0.55),
      CellKind.upcoming || CellKind.notMarkedYet => c.ink3,
    };

    Widget numText = ExcludeSemantics(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$day',
              style: TextStyle(
                fontFamily: NestText.sans,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontVariations: const [FontVariation.weight(700)],
                fontFeatures: const [FontFeature.tabularFigures()],
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );

    if (cell.kind == CellKind.absent) {
      numText = CustomPaint(
        painter: _AbsentStrikePainter(c.danger.withValues(alpha: 0.7)),
        child: numText,
      );
    }

    Widget box;
    if (cell.kind == CellKind.upcoming || cell.kind == CellKind.notMarkedYet) {
      box = DashedBox(radius: 10, padding: EdgeInsets.zero, child: numText);
    } else {
      box = DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: numText,
      );
    }

    if (cell.isToday) {
      box = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.accent, width: 2),
        ),
        child: box,
      );
    }

    return Semantics(
      button: tappable,
      label: label,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            type: MaterialType.transparency,
            child: tappable
                ? InkWell(onTap: onTap, child: box)
                : box,
          ),
        ),
      ),
    );
  }
}

class _AbsentStrikePainter extends CustomPainter {
  _AbsentStrikePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final x1 = size.width * 0.24;
    final x2 = size.width * 0.76;
    final dx = (x2 - x1) / 2;
    final dy = dx * math.tan(35 * math.pi / 180);
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x1, cy + dy), Offset(x2, cy - dy), paint);
  }

  @override
  bool shouldRepaint(_AbsentStrikePainter old) => old.color != color;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: NestText.sans,
            fontSize: 12,
            color: c.ink3,
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nest;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: NestText.serif,
                fontSize: 24,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: c.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: NestText.sans,
                fontSize: 12,
                color: c.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
