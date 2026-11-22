import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/backup/backup_schedule.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/backup/backup_controller.dart';
import 'package:nm_flat/features/backup/password_tools.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showBackupPasswordSheet(
  BuildContext context,
  WidgetRef ref, {
  bool change = false,
}) => showNestSheet<void>(
  context,
  (ctx) => _BackupPasswordSheet(sheetContext: ctx, change: change),
);

class _BackupPasswordSheet extends ConsumerStatefulWidget {
  const _BackupPasswordSheet({
    required this.sheetContext,
    required this.change,
  });

  final BuildContext sheetContext;
  final bool change;

  @override
  ConsumerState<_BackupPasswordSheet> createState() =>
      _BackupPasswordSheetState();
}

class _BackupPasswordSheetState extends ConsumerState<_BackupPasswordSheet> {
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hidePw = true;
  bool _hideConfirm = true;
  bool _saved = false;
  bool _busy = false;

  @override
  void dispose() {
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _suggest() async {
    final words = await loadWordList();
    if (!mounted) return;
    final pw = suggestPassword(words, Random.secure());
    setState(() {
      _pwCtrl.text = pw;
      _confirmCtrl.text = pw;
      _hidePw = false;
      _hideConfirm = false;
    });
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final homeId =
          ref.read(currentHomeIdProvider).value ??
          ref.read(prefsProvider).currentHomeId ??
          '';
      if (homeId.isEmpty) return;

      final store = ref.read(backupConfigStoreProvider);
      final config = await store.load(homeId);
      config.password = _pwCtrl.text;
      config.passwordSetAt = ref.read(clockProvider).nowMs;
      await store.save(homeId, config);

      await ref
          .read(recoveryKitsProvider)
          .ensureLive(homeId, force: widget.change);
      await scheduleBackup(homeId, config);
      ref.invalidate(backupConfigProvider);

      if (!widget.sheetContext.mounted) return;
      Navigator.of(widget.sheetContext).pop();
      await ref.read(backupControllerProvider.notifier).runNow();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final pw = _pwCtrl.text;
    final confirm = _confirmCtrl.text;
    final strength = passwordStrength(pw);
    final mismatch = confirm.isNotEmpty && pw != confirm;
    final canSave = pw.length >= 10 && pw == confirm && _saved && !_busy;

    final (strengthLabel, strengthColor) = switch (strength) {
      PwStrength.tooShort => (l.backupPwTooShort, c.danger),
      PwStrength.okay => (l.backupPwOkay, c.accentInk),
      PwStrength.strong => (l.backupPwStrong, c.ok),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(
          title: widget.change ? l.backupPwChangeTitle : l.backupPwTitle,
          lead: widget.change ? l.backupPwChangeNote : null,
        ),
        TextField(
          controller: _pwCtrl,
          obscureText: _hidePw,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: l.backupPwField,
            suffixIcon: IconButton(
              icon: Icon(
                _hidePw
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: _hidePw ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _hidePw = !_hidePw),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: pw.isEmpty
                    ? const SizedBox.shrink()
                    : Text(
                        strengthLabel,
                        style: NestText.meta13.copyWith(color: strengthColor),
                      ),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _suggest,
              child: Text(
                l.backupPwSuggest,
                style: NestText.button15.copyWith(color: c.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmCtrl,
          obscureText: _hideConfirm,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: l.backupPwConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _hideConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: _hideConfirm ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (mismatch) ...[
          const SizedBox(height: 6),
          Text(
            l.backupPwMismatch,
            style: NestText.meta13.copyWith(color: c.danger),
          ),
        ],
        const SizedBox(height: 14),
        NestCard(
          fill: c.accentSoft,
          borderColor: c.accent,
          padding: const EdgeInsets.all(14),
          child: Text(
            l.backupPwWarning,
            style: NestText.body15.copyWith(color: c.ink),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _busy ? null : () => setState(() => _saved = !_saved),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                NestCheckbox(
                  value: _saved,
                  semanticLabel: l.backupPwSaved,
                  onChanged: (v) {
                    if (!_busy) setState(() => _saved = v);
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l.backupPwSaved,
                    style: NestText.body15.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        NestButton(
          label: widget.change ? l.backupPwChangeSave : l.backupPwSave,
          kind: NestButtonKind.primary,
          size: NestButtonSize.block,
          onPressed: canSave ? _save : null,
        ),
      ],
    );
  }
}
