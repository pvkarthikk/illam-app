import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/cloud/gdrive_destination.dart';
import 'package:nm_flat/core/backup/cloud/oauth_tokens.dart';
import 'package:nm_flat/core/backup/destination_secrets.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class BackupLabScreen extends ConsumerStatefulWidget {
  const BackupLabScreen({super.key});

  @override
  ConsumerState<BackupLabScreen> createState() => _BackupLabScreenState();
}

class _BackupLabScreenState extends ConsumerState<BackupLabScreen> {
  String _googleResult = '';
  String _expireResult = '';
  String _breakResult = '';

  Future<void> _testGoogleSilent() async {
    final l = AppLocalizations.of(context);
    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId;
    var ok = false;
    if (homeId != null && homeId.isNotEmpty) {
      final config = await ref.read(backupConfigStoreProvider).load(homeId);
      final secure = ref.read(secureStoreProvider);
      for (final d in config.destinations) {
        if (d.kind != 'gdrive') continue;
        try {
          final dest = await destinationFor(d, secure) as GdriveDestination;
          await dest.keeper.accessToken();
          ok = true;
        } on Object {
          ok = false;
        }
        break;
      }
    }
    if (!mounted) return;
    setState(() {
      _googleResult = ok ? l.debugResultOk : l.debugResultNeedsSignIn;
    });
  }

  Future<void> _mutateTokens({required bool breakRefresh}) async {
    final l = AppLocalizations.of(context);
    final homeId =
        ref.read(currentHomeIdProvider).value ??
        ref.read(prefsProvider).currentHomeId;
    if (homeId == null || homeId.isEmpty) return;

    final config = await ref.read(backupConfigStoreProvider).load(homeId);
    final secrets = DestinationSecrets(ref.read(secureStoreProvider));

    for (final d in config.destinations) {
      if (d.kind != 'dropbox' && d.kind != 'onedrive') continue;
      final raw = await secrets.read(d.destId);
      if (raw == null || raw.isEmpty) continue;
      final tokens = OAuthTokens.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
      final updated = tokens.copyWith(
        expiresAtMs: 0,
        refreshToken: breakRefresh ? 'broken-token' : tokens.refreshToken,
      );
      await secrets.write(d.destId, jsonEncode(updated.toJson()));
    }

    if (!mounted) return;
    setState(() {
      if (breakRefresh) {
        _breakResult = l.debugResultOk;
      } else {
        _expireResult = l.debugResultOk;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;

    return Scaffold(
      appBar: NestTopBar.sub(title: l.debugBackupLab),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NestButton(
            label: l.debugGoogleSilent,
            kind: NestButtonKind.tonal,
            size: NestButtonSize.block,
            onPressed: _testGoogleSilent,
          ),
          if (_googleResult.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_googleResult, style: NestText.meta13.copyWith(color: c.ink2)),
          ],
          const SizedBox(height: 16),
          NestButton(
            label: l.debugExpireTokens,
            kind: NestButtonKind.tonal,
            size: NestButtonSize.block,
            onPressed: () => _mutateTokens(breakRefresh: false),
          ),
          if (_expireResult.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_expireResult, style: NestText.meta13.copyWith(color: c.ink2)),
          ],
          const SizedBox(height: 16),
          NestButton(
            label: l.debugBreakTokens,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: () => _mutateTokens(breakRefresh: true),
          ),
          if (_breakResult.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_breakResult, style: NestText.meta13.copyWith(color: c.ink2)),
          ],
        ],
      ),
    );
  }
}
