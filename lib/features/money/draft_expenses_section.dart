import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/money.dart';
import 'package:nm_flat/features/gmail_import/draft_review_sheet.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_controller.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_parts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Displays unapproved Gmail invoice drafts on [MoneyScreen].
///
/// Drafts remain excluded from household spend/budget totals until the user
/// reviews them and explicitly taps **Account it**.
class DraftExpensesSection extends ConsumerWidget {
  const DraftExpensesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(gmailDraftOrdersProvider);
    if (drafts.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final uiState = ref.watch(gmailImportControllerProvider);
    final ctrl = ref.read(gmailImportControllerProvider.notifier);
    final snack = ref.read(snackbarProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        SectionHeader(
          title: l10n.gmailImportDraftsSectionTitle(drafts.length),
          actionLabel: l10n.gmailImportReviewAllAction,
          onAction: () => context.push(Routes.gmailImport),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.gmailImportDraftsMoneyNote,
                style: NestText.meta13.copyWith(color: c.ink3),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < drafts.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                GmailDraftCard(
                  draft: drafts[i],
                  accounting: uiState.accountingDraftId == drafts[i].id,
                  onReview: () => showDraftReviewSheet(context, ref, drafts[i]),
                  onAccountIt: () async {
                    final res = await ctrl.accountDraft(drafts[i]);
                    if (!context.mounted || res == null) return;
                    snack.show(
                      l10n.gmailImportAccountedSnack(
                        res.count,
                        Money.formatPaise(res.totalPaise),
                      ),
                    );
                  },
                  onDiscard: () => ctrl.discardDraft(drafts[i].id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
