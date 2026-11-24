import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/data/repo/lists_repo.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/data/repo/tasks_repo.dart';
import 'package:nm_flat/core/domain/item_parse.dart';
import 'package:nm_flat/core/domain/quick_add_type.dart';
import 'package:nm_flat/core/domain/spend_parser.dart';
import 'package:nm_flat/core/domain/todo_parse.dart';
import 'package:nm_flat/core/domain/usual_store.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/ui/formatters.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/lists/lists_controller.dart';
import 'package:nm_flat/features/lists/lists_text.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

enum QaOutcome { added, stayOpen }

class QuickAddState {
  const QuickAddState({
    this.text = '',
    this.type = QaType.grocery,
    this.locked = false,
    this.dup,
    this.dupConfirmed = false,
    this.needAmount = false,
    this.busy = false,
  });

  final String text;
  final QaType type;
  final bool locked;
  final DuplicateHit? dup;
  final bool dupConfirmed;
  final bool needAmount;
  final bool busy;

  QuickAddState copyWith({
    String? text,
    QaType? type,
    bool? locked,
    DuplicateHit? Function()? dup,
    bool? dupConfirmed,
    bool? needAmount,
    bool? busy,
  }) => QuickAddState(
    text: text ?? this.text,
    type: type ?? this.type,
    locked: locked ?? this.locked,
    dup: dup != null ? dup() : this.dup,
    dupConfirmed: dupConfirmed ?? this.dupConfirmed,
    needAmount: needAmount ?? this.needAmount,
    busy: busy ?? this.busy,
  );
}

String quickAddPreview(
  QuickAddState s,
  AppLocalizations l10n, {
  required String today,
  required List<PersonRef> people,
  required Map<String, String> rules,
  required Map<String, String> usualMap,
  String? lastChosen,
}) {
  if (s.needAmount) return l10n.qaNeedAmount;
  final trimmed = s.text.trim();
  if (trimmed.isEmpty) return l10n.qaEmpty;

  switch (s.type) {
    case QaType.todo:
      final parsed = parseTodo(trimmed, today: today, people: people);
      final title = parsed.title.isEmpty ? trimmed : parsed.title;
      final day = Formatters.dayLabel(parsed.due, today, l10n);
      final who = parsed.assignee?.firstName ?? l10n.tasksYou;
      return l10n.qaPreviewTodo(title, day, who);
    case QaType.spend:
      final parsed = parseSpend(
        trimmed,
        rules,
        fallbackMerchant: l10n.moneyCashSpend,
      );
      if (parsed.amountPaise <= 0) return l10n.qaPreviewSpendNoAmount;
      return l10n.qaPreviewSpend(
        Money.format(parsed.amountPaise),
        parsed.merchant,
        parsed.category,
      );
    case QaType.grocery:
    case QaType.shopping:
      final list = s.type == QaType.shopping ? 'shopping' : 'grocery';
      final typeLabel = s.type == QaType.shopping
          ? l10n.qaShopping
          : l10n.qaGrocery;
      final item = parseItem(trimmed);
      final store = usualStore(
        list: list,
        nameKey: itemNameKey(item.name),
        usualByKey: usualMap,
        lastChosen: lastChosen,
      );
      final qStr = item.qty == item.qty.truncateToDouble()
          ? item.qty.truncate().toString()
          : item.qty.toString();
      final qtyText = (item.unit.isEmpty && item.qty == 1)
          ? ''
          : (item.unit.isEmpty ? qStr : '$qStr ${item.unit}');
      final base = l10n.qaPreviewItem(
        typeLabel,
        item.name,
        qtyText,
        channelName(l10n, store.channel),
      );
      return store.learned ? '$base${l10n.qaUsual}' : base;
  }
}

class QuickAddController extends Notifier<QuickAddState> {
  @override
  QuickAddState build() => const QuickAddState();

  void open(int origin) {
    final (QaType type, bool locked) = switch (origin) {
      1 => (
        ref.read(listsControllerProvider).listType == 'shopping'
            ? QaType.shopping
            : QaType.grocery,
        true,
      ),
      2 => (QaType.todo, true),
      3 => (QaType.grocery, true),
      _ => (QaType.grocery, false),
    };
    state = QuickAddState(type: type, locked: locked);
  }

  void onText(String t) {
    state = state.copyWith(
      text: t,
      type: state.locked ? null : detectQuickAddType(t),
      dup: () => null,
      dupConfirmed: false,
      needAmount: false,
    );
  }

  void pickType(QaType t) {
    state = state.copyWith(
      type: t,
      locked: true,
      dup: () => null,
      dupConfirmed: false,
      needAmount: false,
    );
  }

  Future<QaOutcome> add(AppLocalizations l10n) async {
    if (state.busy) return QaOutcome.stayOpen;
    final trimmed = state.text.trim();
    if (trimmed.isEmpty) return QaOutcome.stayOpen;

    state = state.copyWith(busy: true);
    var added = false;
    try {
      final today = Dates.today(ref.read(clockProvider));
      switch (state.type) {
        case QaType.todo:
          final taskPeople =
              ref.read(taskPeopleProvider).value ?? const <TaskPerson>[];
          final people = [
            for (final p in taskPeople) PersonRef(p.id, p.firstName, p.type),
          ];
          final parsed = parseTodo(trimmed, today: today, people: people);
          final title = parsed.title.isEmpty ? trimmed : parsed.title;
          final tomorrow = Dates.addDays(today, 1);
          final msg = parsed.due == today
              ? l10n.qaTodoAddedToday
              : (parsed.due == tomorrow
                    ? l10n.qaTodoAddedTomorrow
                    : l10n.qaTodoAddedOn(
                        Formatters.dayLabel(parsed.due, today, l10n),
                      ));
          final snack = ref.read(snackbarProvider);
          unawaited(
            ref
                .read(tasksRepoProvider)
                .createTodo(
                  title: title,
                  due: parsed.due,
                  assigneeType: parsed.assignee?.type ?? 'member',
                  assignee: parsed.assignee?.id ?? ref.read(myMemberIdProvider),
                )
                .then((res) => snack.show(msg, undo: res.undo))
                .catchError((Object _) => snack.show(rejectText('other'))),
          );
          added = true;
          return QaOutcome.added;

        case QaType.grocery:
        case QaType.shopping:
          final homeId =
              ref.read(currentHomeIdProvider).value ??
              ref.read(prefsProvider).currentHomeId;
          if (homeId == null || homeId.isEmpty) return QaOutcome.stayOpen;
          final list = state.type == QaType.shopping ? 'shopping' : 'grocery';
          final sb = ref.read(snackbarProvider);
          unawaited(
            ref
                .read(listsRepoProvider)
                .addItem(
                  homeId: homeId,
                  list: list,
                  text: trimmed,
                  source: 'quickAdd',
                )
                .then((outcome) {
                  switch (outcome.kind) {
                    case AddKind.added:
                      sb.show(
                        l10n.listsAdded(
                          outcome.name,
                          channelName(l10n, outcome.channel),
                        ),
                        undo: outcome.undo,
                      );
                    case AddKind.merged:
                      sb.show(
                        l10n.listsMerged(outcome.name, outcome.qtyText),
                        undo: outcome.undo,
                      );
                    case AddKind.incompatible:
                      sb.show(l10n.listsAlready(outcome.name, outcome.qtyText));
                  }
                })
                .catchError((Object _) => sb.show(rejectText('other'))),
          );
          added = true;
          return QaOutcome.added;

        case QaType.spend:
          final rules =
              ref.read(merchantRulesProvider).value ?? const <String, String>{};
          final parsed = parseSpend(
            trimmed,
            rules,
            fallbackMerchant: l10n.moneyCashSpend,
          );
          if (parsed.amountPaise <= 0) {
            state = state.copyWith(needAmount: true);
            return QaOutcome.stayOpen;
          }
          if (!state.dupConfirmed) {
            final hit = await ref
                .read(moneyRepoProvider)
                .checkDuplicate(
                  amountPaise: parsed.amountPaise,
                  merchant: parsed.merchant,
                  date: today,
                );
            if (hit != null) {
              state = state.copyWith(dup: () => hit, dupConfirmed: true);
              return QaOutcome.stayOpen;
            }
          }
          final snack = ref.read(snackbarProvider);
          final msg = l10n.qaSpendAdded(Money.format(parsed.amountPaise));
          unawaited(
            ref
                .read(moneyRepoProvider)
                .addSpend(
                  NewExpense(
                    amountPaise: parsed.amountPaise,
                    merchant: parsed.merchant,
                    category: parsed.category,
                    method: 'upi',
                    date: today,
                    source: 'manual',
                  ),
                )
                .then((res) => snack.show(msg, undo: res.undo))
                .catchError((Object _) => snack.show(rejectText('other'))),
          );
          added = true;
          return QaOutcome.added;
      }
    } finally {
      if (!added) state = state.copyWith(busy: false);
    }
  }
}

final quickAddControllerProvider =
    NotifierProvider<QuickAddController, QuickAddState>(
      QuickAddController.new,
    );
