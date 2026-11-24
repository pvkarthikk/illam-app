import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_checker.dart';
import 'package:nm_flat/core/backup/backup_config.dart';
import 'package:nm_flat/core/backup/destinations/backup_destination.dart';
import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/backup/backup_controller.dart';
import 'package:nm_flat/features/backup/backup_password_sheet.dart';
import 'package:nm_flat/features/backup/backup_texts.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class BackupMoreSection extends ConsumerStatefulWidget {
  const BackupMoreSection({
    super.key,
    required this.homeId,
    required this.homeName,
    required this.config,
  });

  final String homeId;
  final String homeName;
  final BackupConfig config;

  @override
  ConsumerState<BackupMoreSection> createState() => _BackupMoreSectionState();
}

class _BackupMoreSectionState extends ConsumerState<BackupMoreSection> {
  bool _checking = false;
  ({int items, int size})? _checkOk;
  bool _checkFailed = false;
  bool _checkUnreachable = false;

  Future<void> _checkBackup() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _checkOk = null;
      _checkFailed = false;
      _checkUnreachable = false;
    });
    try {
      final res = await BackupChecker(ref.read).checkLatest(widget.homeId);
      if (!mounted) return;
      setState(() {
        _checking = false;
        _checkOk = (items: res.items, size: res.sizeBytes);
      });
    } on DestinationException {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _checkFailed = true;
        _checkUnreachable = true;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _checkFailed = true;
      });
    }
  }

  Future<void> _confirmTurnOffKit(KitView kit) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showNestSheet<bool>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: l.backupKitOffTitle(kit.name),
            lead: l.backupKitOffLead(kit.name, widget.homeName),
          ),
          NestSheetActions(
            children: [
              NestButton(
                label: l.backupKitKeep,
                kind: NestButtonKind.ghost,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              NestButton(
                label: l.backupKitTurnOff,
                kind: NestButtonKind.danger,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(membershipLogProvider).append(
      widget.homeId,
      'revokeRecoveryKey',
      {'pub': kit.pub},
    );
    ref.invalidate(recoveryKitsViewProvider);
    ref.invalidate(myKitDeadProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    ref.watch(minuteTickProvider);
    final nowMs = ref.read(clockProvider).nowMs;
    final pwSetAt = widget.config.passwordSetAt ?? nowMs;
    final pwDate = DateFormat(
      'd MMM yyyy',
      'en',
    ).format(DateTime.fromMillisecondsSinceEpoch(pwSetAt));
    final kits = ref.watch(recoveryKitsViewProvider).value ?? const <KitView>[];
    final myKitDead = ref.watch(myKitDeadProvider).value ?? false;
    final isAdmin = ref.watch(isAdminProvider);
    final myMemberId = ref.watch(myMemberIdProvider);
    final myRole = (ref.watch(myMemberProvider).value?.role == 'admin')
        ? 'admin'
        : 'member';

    final history = widget.config.history.take(5).toList();
    final destById = {
      for (final d in widget.config.destinations) d.destId: d,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsRow(
                label: l.backupPwRow,
                value: l.backupPwRowSub(pwDate),
                onTap: () => showBackupPasswordSheet(context, ref, change: true),
              ),
              Divider(height: 1, color: c.line),
              SettingsRow(
                label: l.backupCheck,
                value: l.backupCheckSub,
                trailing: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _checking ? null : _checkBackup,
              ),
              if (_checkOk != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    l.backupCheckOk(
                      _checkOk!.items,
                      formatBackupSize(_checkOk!.size),
                    ),
                    style: NestText.meta13.copyWith(color: c.ok),
                  ),
                ),
              if (_checkFailed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    _checkUnreachable
                        ? l.backupCheckUnreachable
                        : l.backupDamaged,
                    style: NestText.meta13.copyWith(color: c.danger),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(title: l.backupRecent),
        const SizedBox(height: 8),
        NestCard(
          padding: const EdgeInsets.all(16),
          child: history.isEmpty
              ? Text(
                  l.backupRecentEmpty,
                  style: NestText.body15.copyWith(color: c.ink3),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < history.length; i++) ...[
                      if (i > 0) const SizedBox(height: 6),
                      Builder(
                        builder: (_) {
                          final h = history[i];
                          final at = (h['at'] as num?)?.toInt() ?? nowMs;
                          final sizeBytes =
                              (h['sizeBytes'] as num?)?.toInt() ?? 0;
                          final destId = h['destId'] as String?;
                          final d = destId == null ? null : destById[destId];
                          final place = d?.label ??
                              providerShort(l, d?.kind ?? 'folder');
                          return Text(
                            l.backupRecentRow(
                              backupAgo(l, nowMs, at),
                              formatBackupSize(sizeBytes),
                              place,
                            ),
                            style: NestText.body15.copyWith(color: c.ink2),
                          );
                        },
                      ),
                    ],
                  ],
                ),
        ),
        if (kits.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionHeader(title: l.backupKits),
          const SizedBox(height: 8),
          NestCard(
            child: Column(
              children: [
                for (var i = 0; i < kits.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: c.line),
                  _KitRow(
                    kit: kits[i],
                    canTurnOff: isAdmin || kits[i].memberId == myMemberId,
                    onTurnOff: () => _confirmTurnOffKit(kits[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (myKitDead) ...[
          const SizedBox(height: 12),
          AlertLine(
            icon: Icons.warning_amber_rounded,
            text: l.backupKitDead,
            danger: true,
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l.backupFinePrint(widget.homeName, myRole),
          style: NestText.small12.copyWith(color: c.ink3),
        ),
      ],
    );
  }
}

class _KitRow extends StatelessWidget {
  const _KitRow({
    required this.kit,
    required this.canTurnOff,
    required this.onTurnOff,
  });

  final KitView kit;
  final bool canTurnOff;
  final VoidCallback onTurnOff;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final date = DateFormat(
      'd MMM yyyy',
      'en',
    ).format(DateTime.fromMillisecondsSinceEpoch(kit.madeAt));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Avatar(name: kit.name, color: c.primary, size: AvatarSize.s32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l.backupKitRow(kit.name, kit.model),
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    if (kit.thisPhone)
                      NestTag(label: l.backupKitThisPhone, kind: NestTagKind.ok),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l.backupKitSub(date, kit.name, kit.role),
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
              ],
            ),
          ),
          if (canTurnOff) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onTurnOff,
              child: Text(
                l.backupKitTurnOff,
                style: NestText.button15.copyWith(color: c.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
