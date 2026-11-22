import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/attendance.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/features/staff/visit_sheet.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class VisitLogCard extends ConsumerWidget {
  const VisitLogCard({super.key, required this.staff});

  final StaffData staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final from = Dates.addDays(today, -60);
    final visits =
        ref.watch(staffVisitsProvider((staff.id, from, today))).value ??
        const [];
    if (visits.isEmpty) return const SizedBox.shrink();

    final tickNow = ref.watch(minuteTickProvider).value;
    final nowMs =
        tickNow?.millisecondsSinceEpoch ?? ref.read(clockProvider).nowMs;

    final grouped = <String, List<Visit>>{};
    for (final v in visits) {
      final d = v.date;
      if (d != null) grouped.putIfAbsent(d, () => []).add(v);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final newest6 = dates.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.staffVisitLog.toUpperCase(),
                    style: NestText.section13.copyWith(color: c.ink2),
                  ),
                ),
              ),
              Text(
                l10n.staffVisitLogHint,
                style: NestText.meta13.copyWith(color: c.ink3),
              ),
            ],
          ),
        ),
        NestCard(
          child: Column(
            children: [
              for (var i = 0; i < newest6.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.line),
                _VisitDayRow(
                  date: newest6[i],
                  today: today,
                  visits: grouped[newest6[i]]!,
                  nowMs: nowMs,
                  onTap: () => showVisitSheet(
                    context,
                    staffId: staff.id,
                    date: newest6[i],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _VisitDayRow extends StatelessWidget {
  const _VisitDayRow({
    required this.date,
    required this.today,
    required this.visits,
    required this.nowMs,
    required this.onTap,
  });

  final String date;
  final String today;
  final List<Visit> visits;
  final int nowMs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final sorted = [...visits]
      ..sort((a, b) => (a.inAt ?? 0).compareTo(b.inAt ?? 0));
    final spans = [
      for (final v in sorted)
        '${Formatters.time12Ms(v.inAt ?? 0)} – '
            '${v.outAt != null ? Formatters.time12Ms(v.outAt!) : l10n.staffNow}',
    ].join(' · ');
    final mins = liveMinutes([for (final v in sorted) toLite(v)], nowMs);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
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
                      Formatters.dayLabel(date, today, l10n),
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spans,
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                Formatters.duration(mins),
                style: TextStyle(
                  fontFamily: NestText.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontVariations: const [FontVariation.weight(700)],
                  color: c.ink,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.edit_outlined, size: 18, color: c.ink3),
            ],
          ),
        ),
      ),
    );
  }
}
