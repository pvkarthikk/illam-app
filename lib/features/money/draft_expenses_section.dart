import 'dart:math' as math;

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
import 'package:nm_flat/features/sms_import/sms_draft_review_sheet.dart';
import 'package:nm_flat/features/sms_import/sms_import_controller.dart';
import 'package:nm_flat/features/sms_import/sms_import_parts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Displays unapproved Gmail invoice and SMS spend drafts on [MoneyScreen] in
/// a collapsible, paginated list.
///
/// Drafts remain excluded from household spend/budget totals until the user
/// reviews each entry and explicitly taps **Account it**.
class DraftExpensesSection extends ConsumerStatefulWidget {
  const DraftExpensesSection({super.key});

  @override
  ConsumerState<DraftExpensesSection> createState() =>
      _DraftExpensesSectionState();
}

class _DraftExpensesSectionState extends ConsumerState<DraftExpensesSection> {
  static const _initialLimit = 10;

  bool _collapsed = false;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final gmailDrafts = ref.watch(gmailDraftOrdersProvider);
    final smsDrafts = ref.watch(smsDraftSpendsProvider);
    final totalCount = gmailDrafts.length + smsDrafts.length;
    if (totalCount == 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final gmailUi = ref.watch(gmailImportControllerProvider);
    final gmailCtrl = ref.read(gmailImportControllerProvider.notifier);
    final smsUi = ref.watch(smsImportControllerProvider);
    final smsCtrl = ref.read(smsImportControllerProvider.notifier);
    final snack = ref.read(snackbarProvider);
    final openRoute = gmailDrafts.isNotEmpty
        ? Routes.gmailImport
        : Routes.smsImport;

    final visibleCount = _showAll
        ? totalCount
        : math.min(totalCount, _initialLimit);
    final shownGmailCount = math.min(visibleCount, gmailDrafts.length);
    final shownSmsCount = math.min(
      visibleCount - shownGmailCount,
      smsDrafts.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  header: true,
                  label: _collapsed
                      ? l10n.moneyDraftsExpand
                      : l10n.moneyDraftsCollapse,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _collapsed = !_collapsed),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n
                                  .gmailImportDraftsSectionTitle(totalCount)
                                  .toUpperCase(),
                              style: NestText.section13.copyWith(color: c.ink2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _collapsed
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: 20,
                            color: c.ink2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: () => context.push(openRoute),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.gmailImportReviewAllAction,
                      style: NestText.small12.copyWith(color: c.primary),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: c.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!_collapsed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.gmailImportDraftsMoneyNote,
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
                if (totalCount > _initialLimit && !_showAll) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.moneyDraftsShowingCount(visibleCount, totalCount),
                    style: NestText.small12.copyWith(color: c.ink2),
                  ),
                ],
                for (var i = 0; i < shownGmailCount; i++) ...[
                  SizedBox(height: i == 0 ? 8 : 10),
                  GmailDraftCard(
                    draft: gmailDrafts[i],
                    accounting:
                        gmailUi.accountingDraftId == gmailDrafts[i].id,
                    onReview: () =>
                        showDraftReviewSheet(context, ref, gmailDrafts[i]),
                    onAccountIt: () async {
                      final res = await gmailCtrl.accountDraft(gmailDrafts[i]);
                      if (!context.mounted || res == null) return;
                      snack.show(
                        l10n.gmailImportAccountedSnack(
                          res.count,
                          Money.formatPaise(res.totalPaise),
                        ),
                      );
                    },
                    onDiscard: () => gmailCtrl.discardDraft(gmailDrafts[i].id),
                  ),
                ],
                for (var i = 0; i < shownSmsCount; i++) ...[
                  SizedBox(height: (i == 0 && shownGmailCount == 0) ? 8 : 10),
                  SmsDraftCard(
                    draft: smsDrafts[i],
                    accounting: smsUi.accountingDraftId == smsDrafts[i].id,
                    onReview: () =>
                        showSmsDraftReviewSheet(context, ref, smsDrafts[i]),
                    onAccountIt: () async {
                      final res = await smsCtrl.accountDraft(smsDrafts[i]);
                      if (!context.mounted || res == null) return;
                      snack.show(
                        l10n.smsImportAccountedSnack(
                          res.merchant,
                          Money.formatPaise(res.amountPaise),
                        ),
                      );
                    },
                    onDiscard: () => smsCtrl.discardDraft(smsDrafts[i].id),
                  ),
                ],
                if (totalCount > _initialLimit) ...[
                  const SizedBox(height: 12),
                  NestButton(
                    label: _showAll
                        ? l10n.moneyDraftsShowLess(_initialLimit)
                        : l10n.moneyDraftsShowAll(totalCount),
                    kind: NestButtonKind.ghost,
                    size: NestButtonSize.block,
                    onPressed: () => setState(() => _showAll = !_showAll),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
