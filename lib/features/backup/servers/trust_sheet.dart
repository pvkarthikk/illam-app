import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Displays a server TLS or SSH host key fingerprint and returns `true` if the
/// user explicitly chooses to trust it.
Future<bool> showTrustSheet(
  BuildContext context, {
  required String host,
  required String fingerprint,
}) async {
  final res = await showNestSheet<bool>(context, (ctx) {
    final l = AppLocalizations.of(ctx);
    final c = ctx.nest;
    final boxColor = Theme.of(ctx).colorScheme.surfaceContainerHighest;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSheetHeader(title: l.bkSrvTrustTitle, lead: l.bkSrvTrustLead(host)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.line),
          ),
          child: SelectableText(
            fingerprint,
            style: NestText.body15.copyWith(
              fontFamily: 'monospace',
              color: c.ink,
            ),
          ),
        ),
        NestSheetActions(
          children: [
            NestButton(
              label: l.commonCancel,
              kind: NestButtonKind.ghost,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            NestButton(
              label: l.bkSrvTrust,
              kind: NestButtonKind.primary,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ],
    );
  });
  return res ?? false;
}
