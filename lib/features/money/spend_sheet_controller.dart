import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/data/repo/expenses_repo.dart';
import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/money.dart';

enum SpendSaveKind { invalid, duplicate, added, addedBill, learned, updated }

const Object _unset = Object();

class SpendSheetState {
  const SpendSheetState({
    this.id,
    this.merchant = '',
    this.category = 'Other',
    this.method = 'upi',
    this.date = '',
    this.paidBy = '',
    this.categoryLocked = false,
    this.repeat = false,
    this.confirmedDuplicate = false,
    this.dup,
    this.amountError,
    this.merchantError,
  });

  final String? id;
  final String merchant;
  final String category;
  final String method;
  final String date;
  final String paidBy;
  final bool categoryLocked;
  final bool repeat;
  final bool confirmedDuplicate;
  final DuplicateHit? dup;
  final String? amountError;
  final String? merchantError;

  SpendSheetState copyWith({
    Object? id = _unset,
    String? merchant,
    String? category,
    String? method,
    String? date,
    String? paidBy,
    bool? categoryLocked,
    bool? repeat,
    bool? confirmedDuplicate,
    Object? dup = _unset,
    Object? amountError = _unset,
    Object? merchantError = _unset,
  }) => SpendSheetState(
    id: id == _unset ? this.id : id as String?,
    merchant: merchant ?? this.merchant,
    category: category ?? this.category,
    method: method ?? this.method,
    date: date ?? this.date,
    paidBy: paidBy ?? this.paidBy,
    categoryLocked: categoryLocked ?? this.categoryLocked,
    repeat: repeat ?? this.repeat,
    confirmedDuplicate: confirmedDuplicate ?? this.confirmedDuplicate,
    dup: dup == _unset ? this.dup : dup as DuplicateHit?,
    amountError: amountError == _unset
        ? this.amountError
        : amountError as String?,
    merchantError: merchantError == _unset
        ? this.merchantError
        : merchantError as String?,
  );
}

class SpendSheetController extends Notifier<SpendSheetState> {
  @override
  SpendSheetState build() => const SpendSheetState();

  void start({
    ExpenseRow? existing,
    required String today,
    required String me,
  }) {
    if (existing == null) {
      state = SpendSheetState(
        id: null,
        merchant: '',
        category: 'Other',
        method: 'upi',
        date: today,
        paidBy: me,
        categoryLocked: false,
        repeat: false,
        confirmedDuplicate: false,
      );
    } else {
      state = SpendSheetState(
        id: existing.id,
        merchant: existing.merchant,
        category: existing.category,
        method: existing.method,
        date: existing.date,
        paidBy: existing.paidBy,
        categoryLocked: true,
        repeat: false,
        confirmedDuplicate: false,
      );
    }
  }

  void merchantTyped(String text, Map<String, String> rules) {
    state = state.copyWith(
      merchant: text,
      category: state.categoryLocked
          ? state.category
          : guessSpendCategory(text, rules),
      confirmedDuplicate: false,
      dup: null,
      merchantError: null,
    );
  }

  void pickMerchant(
    String name,
    Map<String, String> rules,
    String? lastMethod,
  ) {
    state = state.copyWith(
      merchant: name,
      category: state.categoryLocked
          ? state.category
          : guessSpendCategory(name, rules),
      method: lastMethod ?? state.method,
      confirmedDuplicate: false,
      dup: null,
      merchantError: null,
    );
  }

  void pickCategory(String cat) {
    state = state.copyWith(category: cat, categoryLocked: true);
  }

  void setMethod(String method) {
    state = state.copyWith(method: method);
  }

  void setDate(String date) {
    state = state.copyWith(date: date, confirmedDuplicate: false, dup: null);
  }

  void setPaidBy(String paidBy) {
    state = state.copyWith(paidBy: paidBy);
  }

  void toggleRepeat() {
    state = state.copyWith(repeat: !state.repeat);
  }

  void clearAmountError() {
    if (state.amountError != null) {
      state = state.copyWith(amountError: null);
    }
  }

  void confirmDuplicate() {
    state = state.copyWith(confirmedDuplicate: true, dup: null);
  }

  Future<(SpendSaveKind, ChangeResult?)> save({
    required String amountText,
    required String merchant,
    required Map<String, String> rules,
    String? note,
  }) async {
    final paise = Money.parseRupees(amountText);
    final amtErr = validateAmount(paise);
    final merchErr = validateMerchant(merchant);
    if (amtErr != null || merchErr != null) {
      state = state.copyWith(amountError: amtErr, merchantError: merchErr);
      return (SpendSaveKind.invalid, null);
    }

    final trimmed = merchant.trim();
    final trimmedNote = note?.trim();
    final cleanNote =
        (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote;
    final learn = state.category != guessSpendCategory(trimmed, rules);
    final repo = ref.read(moneyRepoProvider);

    final id = state.id;
    if (id != null) {
      final res = await repo.editSpend(
        id,
        SpendEdit(
          amountPaise: paise!,
          merchant: trimmed,
          category: state.category,
          method: state.method,
          date: state.date,
          paidBy: state.paidBy,
          note: cleanNote,
        ),
        learn: learn,
      );
      return (learn ? SpendSaveKind.learned : SpendSaveKind.updated, res);
    }

    if (!state.confirmedDuplicate) {
      final hit = await repo.checkDuplicate(
        amountPaise: paise!,
        merchant: trimmed,
        date: state.date,
      );
      if (hit != null) {
        state = state.copyWith(
          dup: hit,
          amountError: null,
          merchantError: null,
        );
        return (SpendSaveKind.duplicate, null);
      }
    }

    final res = await repo.addSpend(
      NewExpense(
        amountPaise: paise!,
        merchant: trimmed,
        category: state.category,
        method: state.method,
        date: state.date,
        source: 'manual',
        paidBy: state.paidBy,
        note: cleanNote,
      ),
      learn: learn,
      repeatMonthly: state.repeat,
    );
    final kind = state.repeat
        ? SpendSaveKind.addedBill
        : (learn ? SpendSaveKind.learned : SpendSaveKind.added);
    return (kind, res);
  }
}

final spendSheetControllerProvider =
    NotifierProvider<SpendSheetController, SpendSheetState>(
      SpendSheetController.new,
    );
