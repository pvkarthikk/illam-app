import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/time/dates.dart';

class MealsUiState {
  const MealsUiState({
    required this.weekStart,
    required this.selectedDay,
  });

  final String weekStart;
  final String selectedDay;

  MealsUiState copyWith({String? weekStart, String? selectedDay}) =>
      MealsUiState(
        weekStart: weekStart ?? this.weekStart,
        selectedDay: selectedDay ?? this.selectedDay,
      );
}

class MealsController extends Notifier<MealsUiState> {
  String _today() => Dates.today(ref.read(clockProvider));
  String _mondayOf(String iso) =>
      Dates.addDays(iso, 1 - Dates.weekdayIso(iso));

  @override
  MealsUiState build() {
    ref.watch(clockProvider);
    final today = _today();
    return MealsUiState(weekStart: _mondayOf(today), selectedDay: today);
  }

  bool get isThisWeek => state.weekStart == _mondayOf(_today());

  void prevWeek() => _shiftWeek(-7);
  void nextWeek() => _shiftWeek(7);

  void _shiftWeek(int days) {
    final newStart = Dates.addDays(state.weekStart, days);
    final today = _today();
    final selected =
        newStart == _mondayOf(today) ? today : newStart;
    state = MealsUiState(weekStart: newStart, selectedDay: selected);
  }

  void thisWeek() {
    final today = _today();
    state = MealsUiState(weekStart: _mondayOf(today), selectedDay: today);
  }

  void selectDay(String iso) {
    state = state.copyWith(selectedDay: iso);
  }
}

final mealsControllerProvider =
    NotifierProvider<MealsController, MealsUiState>(MealsController.new);
