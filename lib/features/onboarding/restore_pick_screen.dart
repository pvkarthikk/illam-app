import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/file_format.dart';
import 'package:nm_flat/core/backup/restore_service.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/features/backup/backup_texts.dart';
import 'package:nm_flat/features/onboarding/restore_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class RestorePickScreen extends ConsumerStatefulWidget {
  const RestorePickScreen({super.key});

  @override
  ConsumerState<RestorePickScreen> createState() => _RestorePickScreenState();
}

class _RestorePickScreenState extends ConsumerState<RestorePickScreen> {
  bool _keepBackingUp = true;
  bool _deadSheetShown = false;

  void _back() => context.go(Routes.onboardingStep('restore'));

  Future<void> _showUnlockSheet() async {
    final ctrl = TextEditingController();
    var hide = true;
    var unlocking = false;
    var wrongPw = false;

    try {
      await showNestSheet<void>(
        context,
        (ctx) => StatefulBuilder(
          builder: (ctx, setSheetState) {
            final l = AppLocalizations.of(ctx);
            final c = ctx.nest;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NestSheetHeader(title: l.restoreUnlockTitle),
                TextField(
                  controller: ctrl,
                  obscureText: hide,
                  autofocus: true,
                  enabled: !unlocking,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l.backupPwField,
                    suffixIcon: IconButton(
                      icon: Icon(
                        hide
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      tooltip: hide ? 'Show password' : 'Hide password',
                      onPressed: unlocking
                          ? null
                          : () => setSheetState(() => hide = !hide),
                    ),
                  ),
                  onChanged: (_) {
                    if (wrongPw) setSheetState(() => wrongPw = false);
                  },
                ),
                if (wrongPw) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l.restoreWrongPw,
                      style: NestText.meta13.copyWith(color: c.danger),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (unlocking)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l.restoreUnlocking,
                        style: NestText.body15.copyWith(color: c.ink2),
                      ),
                    ],
                  )
                else
                  NestButton(
                    label: l.restoreUnlockTitle,
                    kind: NestButtonKind.primary,
                    size: NestButtonSize.block,
                    onPressed: ctrl.text.isEmpty
                        ? null
                        : () async {
                            setSheetState(() {
                              unlocking = true;
                              wrongPw = false;
                            });
                            final ok = await ref
                                .read(restoreControllerProvider.notifier)
                                .unlock(ctrl.text);
                            if (!ctx.mounted) return;
                            if (ok) {
                              Navigator.of(ctx).pop();
                              unawaited(
                                ref
                                    .read(restoreControllerProvider.notifier)
                                    .runRestore(),
                              );
                            } else if (ref
                                    .read(restoreControllerProvider)
                                    .error !=
                                null) {
                              Navigator.of(ctx).pop();
                            } else {
                              setSheetState(() {
                                unlocking = false;
                                wrongPw = true;
                              });
                            }
                          },
                  ),
              ],
            );
          },
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _showDeadKitSheet(RestoreUi ui) async {
    final snap = ui.snapshot;
    if (snap == null) return;
    final l = AppLocalizations.of(context);
    final dateStr = DateFormat('d MMM yyyy', 'en').format(
      DateTime.fromMillisecondsSinceEpoch(
        ui.deadAtMs ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );

    await showNestSheet<void>(
      context,
      (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSheetHeader(
            title: snap.homeName,
            lead: l.restoreDeadKit(dateStr, snap.homeName),
          ),
          NestButton(
            label: l.restoreSeparateCopy,
            kind: NestButtonKind.primary,
            size: NestButtonSize.block,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(restoreControllerProvider.notifier)
                  .keepAsSeparateCopy();
              if (mounted) context.go(Routes.today);
            },
          ),
          const SizedBox(height: 10),
          NestButton(
            label: l.restoreRemoveFromPhone,
            kind: NestButtonKind.dangerGhost,
            size: NestButtonSize.block,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(restoreControllerProvider.notifier)
                  .removeDeadRestore();
              if (mounted) context.go(Routes.onboardingStep('welcome'));
            },
          ),
        ],
      ),
    );
  }

  String _errorMessage(AppLocalizations l, String key) => switch (key) {
    'restoreDownloadFail' => l.restoreDownloadFail,
    _ => l.backupDamaged,
  };

  Widget _stepRow(BuildContext context, int idx, int current, String text) {
    final c = context.nest;
    final done = current > idx;
    final active = current == idx;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: done
                  ? Icon(Icons.check_circle_rounded, color: c.ok, size: 22)
                  : active
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : Icon(Icons.circle, color: c.line2, size: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: NestText.body15.copyWith(
                color: done || active ? c.ink : c.ink3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorSection(AppLocalizations l, NestColors c, String key) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(_errorMessage(l, key), style: NestText.body15.copyWith(color: c.danger)),
      const SizedBox(height: 12),
      NestButton(
        label: l.restoreChooseAnother,
        kind: NestButtonKind.ghost,
        size: NestButtonSize.block,
        onPressed: _back,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final ui = ref.watch(restoreControllerProvider);

    ref.listen<RestoreUi>(restoreControllerProvider, (prev, next) {
      if (next.navigatedHomeId != null &&
          prev?.navigatedHomeId != next.navigatedHomeId &&
          mounted) {
        context.go(Routes.today);
      }
      if (next.outcome == RestoreOutcome.deadKit && !_deadSheetShown) {
        _deadSheetShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_showDeadKitSheet(next));
        });
      }
    });

    final snap = ui.snapshot;
    final Widget body;
    if (ui.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (snap != null) {
      final dateStr = DateFormat(
        'd MMM yyyy',
        'en',
      ).format(DateTime.fromMillisecondsSinceEpoch(snap.createdAt));
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          NestCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              l.restoreHeaderCard(
                snap.homeName,
                HomeIds.display(snap.homeId),
                dateStr,
                (snap.by['model'] as String?) ?? '',
                (snap.by['name'] as String?) ?? '',
              ),
              style: NestText.itemTitle16.copyWith(color: c.ink),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Column(
              children: [
                _stepRow(context, 0, ui.step, l.restoreStepDownload),
                _stepRow(context, 1, ui.step, l.restoreStepUnlock),
                _stepRow(context, 2, ui.step, l.restoreStepCheck),
                _stepRow(context, 3, ui.step, l.restoreStepSetup),
              ],
            ),
          ),
          if (ui.error != null) ...[
            const SizedBox(height: 16),
            _errorSection(l, c, ui.error!),
          ] else if (ui.step == 4 && ui.outcome == RestoreOutcome.restored) ...[
            const SizedBox(height: 20),
            Text(
              l.restoreWelcome(snap.homeName),
              style: NestText.display30.copyWith(color: c.ink),
            ),
            const SizedBox(height: 8),
            Text(
              l.restoreOthersNote(snap.homeName),
              style: NestText.body15.copyWith(color: c.ink2),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () => setState(() => _keepBackingUp = !_keepBackingUp),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    NestCheckbox(
                      value: _keepBackingUp,
                      semanticLabel: l.restoreKeepBackingUp(
                        providerTitle(l, ui.dest?.kind ?? 'folder'),
                      ),
                      onChanged: (v) => setState(() => _keepBackingUp = v),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l.restoreKeepBackingUp(
                          providerTitle(l, ui.dest?.kind ?? 'folder'),
                        ),
                        style: NestText.body15.copyWith(color: c.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            NestButton(
              label: l.restoreGo(snap.homeName),
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: () async {
                await ref
                    .read(restoreControllerProvider.notifier)
                    .finishRestored(keepBackingUp: _keepBackingUp);
                if (context.mounted) context.go(Routes.today);
              },
            ),
          ] else if (ui.step == 4 &&
              ui.outcome == RestoreOutcome.alreadyHere) ...[
            const SizedBox(height: 20),
            Text(
              l.restoreAlreadyHere(snap.homeName),
              style: NestText.itemTitle16.copyWith(color: c.ink),
            ),
            const SizedBox(height: 14),
            NestButton(
              label: l.restoreOpen,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: () async {
                await ref
                    .read(restoreControllerProvider.notifier)
                    .openAlreadyHere();
                if (context.mounted) context.go(Routes.today);
              },
            ),
          ] else if (ui.step == 4 && ui.outcome == RestoreOutcome.deadKit) ...[
            const SizedBox(height: 20),
            NestButton(
              label: l.restoreSeparateCopy,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: () => _showDeadKitSheet(ui),
            ),
          ],
        ],
      );
    } else {
      final groups = <String, List<FoundBackup>>{};
      for (final item in ui.found) {
        (groups[item.header.vaultId] ??= []).add(item);
      }
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            l.restoreFoundIn(
              providerTitle(l, ui.dest?.kind ?? 'folder'),
              ui.dest?.label ?? '',
            ),
            style: NestText.body15.copyWith(color: c.ink2),
          ),
          const SizedBox(height: 14),
          if (ui.error != null)
            _errorSection(l, c, ui.error!)
          else if (groups.isEmpty) ...[
            Text(l.restoreEmpty, style: NestText.body15.copyWith(color: c.ink2)),
            const SizedBox(height: 12),
            NestButton(
              label: l.restoreChooseAnother,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: _back,
            ),
          ] else ...[
            RadioGroup<String>(
              groupValue: ui.selected,
              onChanged: (val) {
                if (val != null) {
                  ref.read(restoreControllerProvider.notifier).selectFile(val);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in groups.entries) ...[
                    SectionHeader(
                      title: l.restoreVault(
                        entry.key.length >= 8
                            ? entry.key.substring(0, 8)
                            : entry.key,
                      ),
                    ),
                    const SizedBox(height: 6),
                    NestCard(
                      child: Column(
                        children: [
                          _BackupChoiceRow(entry: entry.value.first),
                          if (entry.value.length > 1) ...[
                            Divider(height: 1, color: c.line),
                            ExpansionTile(
                              shape: const Border(),
                              collapsedShape: const Border(),
                              title: Text(
                                l.restoreOlder(entry.value.length - 1),
                                style: NestText.body15.copyWith(color: c.ink2),
                              ),
                              children: [
                                for (final old in entry.value.skip(1)) ...[
                                  Divider(height: 1, color: c.line),
                                  _BackupChoiceRow(entry: old),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            NestButton(
              label: l.restoreUnlockTitle,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: ui.selected == null ? null : _showUnlockSheet,
            ),
          ],
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l.commonBack,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _back,
          ),
          title: Text(
            l.restorePickTitle,
            style: NestText.title22.copyWith(color: c.ink),
          ),
          backgroundColor: c.paper.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: c.ink,
        ),
        body: body,
      ),
    );
  }
}

class _BackupChoiceRow extends StatelessWidget {
  const _BackupChoiceRow({required this.entry});

  final FoundBackup entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final date = DateFormat(
      'd MMM yyyy, HH:mm',
      'en',
    ).format(DateTime.fromMillisecondsSinceEpoch(entry.header.createdAt));
    final size = formatBackupSize(entry.file.size);
    final full = entry.header.kind == 'full';

    return RadioListTile<String>(
      value: entry.file.name,
      title: Text(l.restoreRow(date, size)),
      secondary: NestTag(
        label: full ? l.restoreTagKit : l.restoreTagData,
        kind: full ? NestTagKind.ok : NestTagKind.neutral,
      ),
    );
  }
}
