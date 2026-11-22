import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/l10n/gen/app_localizations.dart';

class SnackbarService {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// One snackbar at a time, 5 s, optional "Undo" (a later phase adds `undo: UndoToken`).
  void show(String text, {VoidCallback? onUndo}) {
    final m = messengerKey.currentState;
    final ctx = messengerKey.currentContext;
    if (m == null || ctx == null) return;
    final l10n = AppLocalizations.of(ctx);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 5),
        persist: false,
        action: onUndo == null
            ? null
            : SnackBarAction(label: l10n.commonUndo, onPressed: onUndo),
      ),
    );
  }
}
