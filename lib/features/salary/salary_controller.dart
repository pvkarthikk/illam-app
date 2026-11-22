import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalaryMonthController extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void select(String staffId, String month) {
    state = {...state, staffId: month};
  }
}

final salaryMonthProvider =
    NotifierProvider<SalaryMonthController, Map<String, String>>(
      SalaryMonthController.new,
    );
