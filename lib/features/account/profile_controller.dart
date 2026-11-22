import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/providers.dart';

class ProfileController extends Notifier<void> {
  @override
  void build() {}

  Future<ChangeResult?> rename(String typed) async {
    final full = Names.titleCase(typed);
    if (full.isEmpty) return null;
    final id = ref.read(myMemberIdProvider);
    return ref.read(changesProvider).write('Name changed', (c) {
      c.set('members', id, 'full_name', full);
      c.set('members', id, 'first_name', Names.firstName(full));
    });
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, void>(
  ProfileController.new,
);
