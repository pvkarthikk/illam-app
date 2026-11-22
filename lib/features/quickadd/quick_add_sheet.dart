import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/quick_add_type.dart';
import 'package:nm_flat/core/domain/todo_parse.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/quickadd/quick_add_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showQuickAdd(
  BuildContext context,
  WidgetRef ref, {
  required int origin,
}) {
  ref.read(quickAddControllerProvider.notifier).open(origin);
  return showNestSheet<void>(context, (_) => const QuickAddSheet());
}

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final outcome = await ref.read(quickAddControllerProvider.notifier).add(l10n);
    if (!mounted) return;
    if (outcome == QaOutcome.added) {
      Navigator.of(context).pop();
    } else if (_ctrl.text.trim().isEmpty) {
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final s = ref.watch(quickAddControllerProvider);
    final ctrl = ref.read(quickAddControllerProvider.notifier);

    final today = Dates.today(ref.watch(clockProvider));
    final taskPeople =
        ref.watch(taskPeopleProvider).value ?? const <TaskPerson>[];
    final people = [
      for (final p in taskPeople) PersonRef(p.id, p.firstName, p.type),
    ];
    final rules =
        ref.watch(merchantRulesProvider).value ?? const <String, String>{};
    final list = s.type == QaType.shopping ? 'shopping' : 'grocery';
    final usualMap = ref.watch(usualMapProvider(list));

    final String previewText;
    final bool showCheck;
    if (s.dup case final hit?) {
      final who = hit.whoFirstName ?? l10n.moneyWhoYou;
      final when = hit.date == today
          ? l10n.moneyWhenToday
          : (hit.date == Dates.addDays(today, -1)
                ? l10n.moneyWhenYesterday
                : l10n.moneyWhenOn(Formatters.dayLabel(hit.date, today, l10n)));
      previewText = l10n.moneyDuplicate(
        who,
        Money.format(hit.amountPaise),
        hit.merchant,
        when,
      );
      showCheck = false;
    } else {
      previewText = quickAddPreview(
        s,
        l10n,
        today: today,
        people: people,
        rules: rules,
        usualMap: usualMap,
      );
      showCheck = s.text.trim().isNotEmpty && !s.needAmount;
    }

    final chips = <(QaType, String)>[
      (QaType.grocery, l10n.qaGrocery),
      (QaType.shopping, l10n.qaShopping),
      (QaType.todo, l10n.qaTodo),
      (QaType.spend, l10n.qaSpend),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(title: l10n.qaTitle, lead: l10n.qaLead),
        TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: l10n.qaPlaceholder),
          onChanged: ctrl.onText,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (type, label) in chips)
              NestChip(
                label: label,
                selected: s.type == type,
                onTap: () => ctrl.pickType(type),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCheck) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(Icons.check_rounded, size: 18, color: c.primary),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  previewText,
                  style: NestText.meta13.copyWith(
                    color: (s.dup != null || s.needAmount)
                        ? c.accentInk
                        : c.ink2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        NestButton(
          label: l10n.qaAdd,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: s.busy ? null : _submit,
        ),
      ],
    );
  }
}
