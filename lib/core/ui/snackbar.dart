import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/ops/undo.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class SnackbarService {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// One snackbar at a time, 5 s, optional "Undo".
  void show(String text, {UndoToken? undo, VoidCallback? onUndo}) {
    final m = messengerKey.currentState;
    final ctx = messengerKey.currentContext;
    if (m == null || ctx == null) return;
    final l10n = AppLocalizations.of(ctx);
    m.hideCurrentSnackBar();

    final SnackBarAction? action;
    if (undo != null) {
      action = undo.used
          ? null
          : SnackBarAction(
              label: l10n.commonUndo,
              onPressed: () => _runUndo(undo, l10n),
            );
    } else if (onUndo != null) {
      action = SnackBarAction(label: l10n.commonUndo, onPressed: onUndo);
    } else {
      action = null;
    }

    m.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 5),
        persist: false,
        action: action,
      ),
    );
  }

  Future<void> _runUndo(UndoToken token, AppLocalizations l10n) async {
    final r = await token.run();
    final text = switch (r) {
      UndoConflict(byMe: true) => l10n.undoConflictYou,
      UndoConflict(name: final String n) => l10n.undoConflict(n),
      UndoConflict() => l10n.undoConflictSomeone,
      UndoDone() => null,
    };
    if (text != null) show(text);
  }
}
