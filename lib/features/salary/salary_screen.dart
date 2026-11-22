import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/features/salary/pay_rules_sheet.dart';
import 'package:nm_flat/features/salary/salary_actions.dart';
import 'package:nm_flat/features/salary/salary_controller.dart';
import 'package:nm_flat/features/salary/salary_parts.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class SalaryScreen extends ConsumerWidget {
  const SalaryScreen({super.key, required this.staffId});

  final String staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final today = ref.watch(todayDateProvider);
    final curMonth = Dates.month(today);
    final staff = ref.watch(salaryStaffProvider(staffId)).value;
    final settled =
        ref.watch(settledMonthsProvider(staffId)).value ?? const <String>{};
    final rawMonths = staff == null
        ? <String>[curMonth]
        : salaryMonths(
            startDate: staff.startDate ?? today,
            endDate: staff.endDate,
            today: today,
          );
    final months = rawMonths.isEmpty ? <String>[curMonth] : rawMonths;
    final chosen = ref.watch(salaryMonthProvider)[staffId];
    final month = chosen != null && months.contains(chosen)
        ? chosen
        : defaultSalaryMonth(
            today: today,
            months: months,
            isSettled: settled.contains,
          );

    final viewAsync = ref.watch(salaryViewProvider((staffId, month)));
    final isAdmin = ref.watch(isAdminProvider);
    final monthName = Formatters.monthName(month);
    final rules = viewAsync.value?.shown.rules;
    String? subtitle;
    if (rules != null) {
      if (month != curMonth) {
        subtitle = l10n.salarySubtitlePast(
          monthName,
          Dates.daysInMonth(month),
        );
      } else if (rules.type == PayType.hourly) {
        subtitle = l10n.salarySubtitleSoFar(
          monthName,
          Dates.parse(today).day,
        );
      } else {
        subtitle = l10n.salarySubtitleProjected(
          monthName,
          Dates.daysInMonth(month),
        );
      }
    }

    final idx = months.indexOf(month);
    final hasPrev = idx > 0;
    final hasNext = idx >= 0 && idx < months.length - 1;

    return Scaffold(
      appBar: NestTopBar.sub(
        title: l10n.salaryTitle(staff?.name ?? ''),
        subtitle: subtitle,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasPrev)
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: l10n.salaryPrevMonth,
                    onPressed: () => ref
                        .read(salaryMonthProvider.notifier)
                        .select(staffId, months[idx - 1]),
                  )
                else
                  const SizedBox(width: 48, height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    monthName,
                    style: TextStyle(
                      fontFamily: NestText.sans,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation.weight(700)],
                      color: c.ink,
                    ),
                  ),
                ),
                if (hasNext)
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: l10n.salaryNextMonth,
                    onPressed: () => ref
                        .read(salaryMonthProvider.notifier)
                        .select(staffId, months[idx + 1]),
                  )
                else
                  const SizedBox(width: 48, height: 48),
              ],
            ),
          ),
          viewAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Center(
              child: EmptyState(
                icon: Icons.person_off_outlined,
                title: l10n.staffNotFound,
                body: '',
              ),
            ),
            data: (view) {
              final r = view.shown;
              if (r.noRules) {
                return EmptyState(
                  icon: Icons.payments_outlined,
                  title: l10n.salaryNoRules,
                  body: l10n.salaryNoRulesBody,
                  action: isAdmin
                      ? NestButton(
                          label: l10n.salarySetRules,
                          kind: NestButtonKind.primary,
                          onPressed: () => showPayRulesSheet(
                            context,
                            staffId: staffId,
                            name: view.staff.name ?? '',
                            month: month,
                          ),
                        )
                      : null,
                );
              }
              if (r.notWorking) {
                return EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: l10n.salaryNotWorking(monthName),
                  body: '',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReceiptCard(view: view, month: month),
                        const ReceiptEdge(),
                      ],
                    ),
                  ),
                  SalaryActions(view: view, month: month),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: c.ink3),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.salaryFootnote,
                    style: NestText.meta13.copyWith(
                      fontSize: 12.5,
                      color: c.ink3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
