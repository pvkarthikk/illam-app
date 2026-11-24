import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nm_flat/core/nav/router.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/device_model.dart';

class CreateHomeController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> create({
    required String name,
    required String homeName,
    required int createdAt,
    required String nonceB64,
    bool addStarter = true,
  }) async {
    state = true;
    try {
      final keys = await ref.read(deviceKeysProvider.future);
      final model = await deviceModel();
      await ref
          .read(homeRepoProvider)
          .createHome(
            creatorName: name,
            homeName: homeName,
            keys: keys,
            createdAt: createdAt,
            nonceB64: nonceB64,
            model: model,
          );
      if (addStarter) {
        ref.read(recipesRepoProvider).addStarterPack().ignore();
      }
      ref.read(routerProvider).go('${Routes.invite}?first=1');
    } finally {
      state = false;
    }
  }
}

final createHomeControllerProvider =
    NotifierProvider<CreateHomeController, bool>(CreateHomeController.new);
