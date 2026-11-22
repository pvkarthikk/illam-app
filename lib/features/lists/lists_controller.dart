import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/repo/lists_repo.dart';
import 'package:nm_flat/core/providers.dart';

class ListsUiState {
  const ListsUiState({
    this.listType = 'grocery',
    this.filter,
    this.pickedChannel,
  });

  final String listType;
  final String? filter;
  final String? pickedChannel;

  ListsUiState copyWith({
    String? listType,
    String? Function()? filter,
    String? Function()? pickedChannel,
  }) => ListsUiState(
    listType: listType ?? this.listType,
    filter: filter != null ? filter() : this.filter,
    pickedChannel: pickedChannel != null ? pickedChannel() : this.pickedChannel,
  );
}

class ListsController extends Notifier<ListsUiState> {
  @override
  ListsUiState build() => const ListsUiState();

  void setListType(String t) {
    state = ListsUiState(listType: t);
  }

  void setFilter(String? ch) {
    state = state.copyWith(filter: () => ch);
  }

  void showChannel(String list, String ch) {
    state = ListsUiState(listType: list, filter: ch);
  }

  Future<void> pickChannel(String ch) async {
    state = state.copyWith(pickedChannel: () => ch);
    await ref.read(prefsProvider).setLastStore(state.listType, ch);
  }

  Future<AddOutcome?> add(String text, {String source = 'manual'}) async {
    final home = ref.read(currentHomeIdProvider).value;
    if (home == null || text.trim().isEmpty) return null;
    final outcome = await ref
        .read(listsRepoProvider)
        .addItem(
          homeId: home,
          list: state.listType,
          text: text,
          pickedChannel: state.pickedChannel,
          source: source,
        );
    state = state.copyWith(pickedChannel: () => null);
    return outcome;
  }
}

final listsControllerProvider =
    NotifierProvider<ListsController, ListsUiState>(ListsController.new);
