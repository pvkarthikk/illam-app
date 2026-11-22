import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nm_flat/core/domain/channels.dart';

enum StoreOpened { app, website, playStore, none }

class StoreLauncher {
  const StoreLauncher();

  Future<StoreOpened> open(String channelId) async {
    final ch = storeChannels[channelId];
    if (ch == null || !ch.online) return StoreOpened.none;

    final pkg = ch.androidPackage;
    if (Platform.isAndroid && pkg != null) {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: pkg,
        flags: const <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      if ((await intent.canResolveActivity()) == true) {
        await intent.launch();
        return StoreOpened.app;
      }
    }

    final site = ch.website;
    if (site != null && await _launch(site)) {
      return StoreOpened.website;
    }

    if (pkg != null) {
      final openedMarket = await _launch('market://details?id=$pkg');
      if (openedMarket) return StoreOpened.playStore;
      final openedPlay = await _launch(
        'https://play.google.com/store/apps/details?id=$pkg',
      );
      if (openedPlay) return StoreOpened.playStore;
    }

    return StoreOpened.none;
  }

  Future<bool> _launch(String url) async {
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}

final storeLauncherProvider = Provider<StoreLauncher>(
  (ref) => const StoreLauncher(),
);
