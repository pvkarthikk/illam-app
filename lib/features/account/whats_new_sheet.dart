import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/changelog.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Resolves a [ReleaseNoteEntry.highlightKeys] key into its localized text.
String resolveReleaseHighlight(AppLocalizations l10n, String key) =>
    switch (key) {
      'v171TodoDoneNotif' => l10n.whatsNewV171TodoDoneNotif,
      'v171TodoWidgetMine' => l10n.whatsNewV171TodoWidgetMine,
      'v170Changelog' => l10n.whatsNewV170Changelog,
      'v170SpendWidget' => l10n.whatsNewV170SpendWidget,
      'v170Languages' => l10n.whatsNewV170Languages,
      'v160BillScan' => l10n.whatsNewV160BillScan,
      'v150Trips' => l10n.whatsNewV150Trips,
      'v140MoneyCharts' => l10n.whatsNewV140MoneyCharts,
      'v132SmsParser' => l10n.whatsNewV132SmsParser,
      'v131Routines' => l10n.whatsNewV131Routines,
      'v130SmsImport' => l10n.whatsNewV130SmsImport,
      'v120GmailImport' => l10n.whatsNewV120GmailImport,
      _ => key,
    };

/// Displays unseen release notes (after an app update) or full version history.
Future<void> showWhatsNewSheet(
  BuildContext context, {
  required List<ReleaseNoteEntry> releases,
  bool isHistory = false,
}) async {
  if (releases.isEmpty) return;
  await showNestSheet<void>(
    context,
    (sheetCtx) {
      final l10n = AppLocalizations.of(sheetCtx);
      final c = sheetCtx.nest;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestSheetHeader(
            title: isHistory ? l10n.whatsNewHistoryTitle : l10n.whatsNewTitle,
          ),
          for (var i = 0; i < releases.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _ReleaseCard(entry: releases[i], l10n: l10n, c: c),
          ],
          const SizedBox(height: 20),
          NestButton(
            label: l10n.whatsNewGotIt,
            kind: NestButtonKind.primary,
            size: NestButtonSize.block,
            onPressed: () => Navigator.of(sheetCtx).pop(),
          ),
        ],
      );
    },
  );
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({
    required this.entry,
    required this.l10n,
    required this.c,
  });

  final ReleaseNoteEntry entry;
  final AppLocalizations l10n;
  final NestColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NestTag(
                label: l10n.whatsNewVersionHeader(entry.version),
                kind: NestTagKind.ok,
              ),
              Text(
                entry.date,
                style: NestText.small12.copyWith(color: c.ink3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var j = 0; j < entry.highlightKeys.length; j++) ...[
            if (j > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    resolveReleaseHighlight(l10n, entry.highlightKeys[j]),
                    style: NestText.body15.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
