import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/payroll.dart';
import 'package:nm_flat/core/domain/salary_months.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/salary/adjustments_section.dart';
import 'package:nm_flat/features/salary/salary_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showPayRulesSheet(
  BuildContext context, {
  required String staffId,
  required String name,
  required String month,
}) => showNestSheet<void>(
  context,
  (_) => _PayRulesSheet(staffId: staffId, name: name, month: month),
);

class _PayRulesSheet extends ConsumerStatefulWidget {
  const _PayRulesSheet({
    required this.staffId,
    required this.name,
    required this.month,
  });

  final String staffId;
  final String name;
  final String month;

  @override
  ConsumerState<_PayRulesSheet> createState() => _PayRulesSheetState();
}

class _PayRulesSheetState extends ConsumerState<_PayRulesSheet> {
  final _rateCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  late PayType _type;
  late int _roundingMin;
  late int _minHours;
  late int _paidLeaves;
  late Set<int> _workDays;
  bool _applyThisMonth = true;
  String? _amountError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final curMonth = Dates.month(Dates.today(ref.read(clockProvider)));
    final rule = ref
        .read(salaryViewProvider((widget.staffId, curMonth)))
        .value
        ?.payroll
        .rules;
    _type = rule?.type ?? PayType.hourly;
    _roundingMin = rule?.roundingMin ?? 15;
    _minHours = rule?.minHoursPerVisit ?? 1;
    _paidLeaves = (rule?.paidLeavesPerMonth ?? 2).clamp(0, 4);
    _workDays = (rule?.workDays ?? const [1, 2, 3, 4, 5, 6]).toSet();
    if (rule != null && rule.ratePerHourPaise > 0) {
      _rateCtrl.text = _formatInput(rule.ratePerHourPaise);
    }
    if (rule != null && rule.amountPerMonthPaise > 0) {
      _monthlyCtrl.text = _formatInput(rule.amountPerMonthPaise);
    }
  }

  String _formatInput(int paise) => paise % 100 == 0
      ? '${paise ~/ 100}'
      : (paise / 100).toStringAsFixed(2);

  @override
  void dispose() {
    _rateCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n, bool currentSettled) async {
    if (_saving || _workDays.isEmpty) return;
    final ctrl = _type == PayType.hourly ? _rateCtrl : _monthlyCtrl;
    final paise = Money.parseRupees(ctrl.text);
    if (paise == null || paise <= 0) {
      setState(() => _amountError = l10n.salaryCheckAmount);
      return;
    }

    setState(() {
      _saving = true;
      _amountError = null;
    });

    try {
      final curMonth = Dates.month(Dates.today(ref.read(clockProvider)));
      final applyNow = !currentSettled && _applyThisMonth;
      final days = _workDays.toList()..sort();
      final data = PayRulesData(
        effectiveMonth: applyNow ? curMonth : nextMonth(curMonth),
        workDays: days,
        type: _type,
        ratePerHourPaise: _type == PayType.hourly
            ? paise
            : (Money.parseRupees(_rateCtrl.text) ?? 0),
        roundingMin: _roundingMin,
        minHoursPerVisit: _minHours,
        amountPerMonthPaise: _type == PayType.monthly
            ? paise
            : (Money.parseRupees(_monthlyCtrl.text) ?? 0),
        paidLeavesPerMonth: _paidLeaves,
      );
      final res = await ref
          .read(salaryRepoProvider)
          .saveRules(widget.staffId, data, applyThisMonth: applyNow);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref
          .read(snackbarProvider)
          .show(l10n.salaryRulesSaved, undo: res.undo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _groupLabel(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: NestText.small12.copyWith(color: context.nest.ink2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final curMonth = Dates.month(Dates.today(ref.watch(clockProvider)));
    final currentSettled =
        ref.watch(settledMonthsProvider(widget.staffId)).value?.contains(
              curMonth,
            ) ??
        false;
    final effectiveApplyThisMonth = !currentSettled && _applyThisMonth;
    final dayLabels = [
      l10n.salaryDayMon,
      l10n.salaryDayTue,
      l10n.salaryDayWed,
      l10n.salaryDayThu,
      l10n.salaryDayFri,
      l10n.salaryDaySat,
      l10n.salaryDaySun,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.salaryRulesTitle(widget.name),
          lead: l10n.salaryRulesLead,
        ),
        _groupLabel(context, l10n.salaryPayType),
        Wrap(
          spacing: 8,
          children: [
            NestChip(
              label: l10n.salaryHourly,
              selected: _type == PayType.hourly,
              onTap: () => setState(() {
                _type = PayType.hourly;
                _amountError = null;
              }),
            ),
            NestChip(
              label: l10n.salaryMonthly,
              selected: _type == PayType.monthly,
              onTap: () => setState(() {
                _type = PayType.monthly;
                _amountError = null;
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_type == PayType.hourly) ...[
          TextField(
            controller: _rateCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
            decoration: InputDecoration(
              labelText: l10n.salaryRatePerHour,
              errorText: _amountError,
            ),
          ),
          _groupLabel(context, l10n.salaryRoundTo),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              NestChip(
                label: l10n.salaryRoundExactMinute,
                selected: _roundingMin == 1,
                onTap: () => setState(() => _roundingMin = 1),
              ),
              NestChip(
                label: l10n.salaryRound15,
                selected: _roundingMin == 15,
                onTap: () => setState(() => _roundingMin = 15),
              ),
              NestChip(
                label: l10n.salaryRound30,
                selected: _roundingMin == 30,
                onTap: () => setState(() => _roundingMin = 30),
              ),
            ],
          ),
          _groupLabel(context, l10n.salaryMinimum),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              NestChip(
                label: l10n.salaryMinNone,
                selected: _minHours == 0,
                onTap: () => setState(() => _minHours = 0),
              ),
              NestChip(
                label: l10n.salaryMin1,
                selected: _minHours == 1,
                onTap: () => setState(() => _minHours = 1),
              ),
              NestChip(
                label: l10n.salaryMin2,
                selected: _minHours == 2,
                onTap: () => setState(() => _minHours = 2),
              ),
            ],
          ),
        ] else ...[
          TextField(
            controller: _monthlyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
            decoration: InputDecoration(
              labelText: l10n.salaryMonthlyAmount,
              errorText: _amountError,
            ),
          ),
          _groupLabel(context, l10n.salaryPaidLeaves),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (var n = 0; n <= 4; n++)
                NestChip(
                  label: '$n',
                  selected: _paidLeaves == n,
                  onTap: () => setState(() => _paidLeaves = n),
                ),
            ],
          ),
        ],
        _groupLabel(context, l10n.salaryWorkDays),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (var i = 0; i < 7; i++)
              NestChip(
                label: dayLabels[i],
                selected: _workDays.contains(i + 1),
                onTap: () => setState(() {
                  if (_workDays.contains(i + 1)) {
                    _workDays.remove(i + 1);
                  } else {
                    _workDays.add(i + 1);
                  }
                }),
              ),
          ],
        ),
        _groupLabel(context, l10n.salaryApplyFrom),
        Wrap(
          spacing: 8,
          children: [
            if (!currentSettled)
              NestChip(
                label: l10n.salaryThisMonth,
                selected: effectiveApplyThisMonth,
                onTap: () => setState(() => _applyThisMonth = true),
              ),
            NestChip(
              label: l10n.salaryNextMonthChip,
              selected: !effectiveApplyThisMonth,
              onTap: () => setState(() => _applyThisMonth = false),
            ),
          ],
        ),
        const SizedBox(height: 18),
        NestButton(
          label: l10n.salarySaveRules,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: _workDays.isEmpty || _saving
              ? null
              : () => _save(l10n, currentSettled),
        ),
        AdjustmentsSection(staffId: widget.staffId, month: widget.month),
      ],
    );
  }
}
