import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksUiState {
  const TasksUiState({this.tab = 'routines', this.person});

  final String tab;
  final String? person;

  TasksUiState copyWith({
    String? tab,
    String? person,
    bool clearPerson = false,
  }) => TasksUiState(
    tab: tab ?? this.tab,
    person: clearPerson ? null : (person ?? this.person),
  );
}

class TasksController extends Notifier<TasksUiState> {
  @override
  TasksUiState build() => const TasksUiState();

  void setTab(String tab) => state = state.copyWith(tab: tab);

  void setPerson(String? id) =>
      state = state.copyWith(person: id, clearPerson: id == null);
}

final tasksControllerProvider = NotifierProvider<TasksController, TasksUiState>(
  TasksController.new,
);
