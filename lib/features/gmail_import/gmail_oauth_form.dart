import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/invoice/gmail_oauth_parser.dart';
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Card for entering or pasting a Google Cloud Desktop App OAuth client.
class GmailOAuthFormCard extends ConsumerStatefulWidget {
  const GmailOAuthFormCard({super.key, required this.config});

  final GmailImportConfig config;

  @override
  ConsumerState<GmailOAuthFormCard> createState() => _GmailOAuthFormCardState();
}

class _GmailOAuthFormCardState extends ConsumerState<GmailOAuthFormCard> {
  late final TextEditingController _clientIdCtrl;
  late final TextEditingController _clientSecretCtrl;
  bool _obscureSecret = true;
  GmailOAuthParseError? _formError;

  @override
  void initState() {
    super.initState();
    _clientIdCtrl = TextEditingController(
      text: widget.config.oauth?.clientId ?? '',
    );
    _clientSecretCtrl = TextEditingController(
      text: widget.config.oauth?.clientSecret ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant GmailOAuthFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldOAuth = oldWidget.config.oauth;
    final nextOAuth = widget.config.oauth;
    if (oldOAuth?.clientId != nextOAuth?.clientId ||
        oldOAuth?.clientSecret != nextOAuth?.clientSecret) {
      if (nextOAuth != null) {
        _clientIdCtrl.text = nextOAuth.clientId;
        _clientSecretCtrl.text = nextOAuth.clientSecret;
      } else {
        _clientIdCtrl.clear();
        _clientSecretCtrl.clear();
      }
    }
  }

  @override
  void dispose() {
    _clientIdCtrl.dispose();
    _clientSecretCtrl.dispose();
    super.dispose();
  }

  Future<void> _onPasteJson() async {
    final l10n = AppLocalizations.of(context);
    final creds = await showPasteOAuthJsonSheet(context);
    if (!mounted || creds == null) return;
    _clientIdCtrl.text = creds.clientId;
    _clientSecretCtrl.text = creds.clientSecret;
    setState(() => _formError = null);
    ref.read(snackbarProvider).show(l10n.gmailImportJsonApplied);
  }

  Future<void> _onSave() async {
    final l10n = AppLocalizations.of(context);
    final parsed = validateGmailOAuthPair(
      _clientIdCtrl.text,
      _clientSecretCtrl.text,
    );
    if (!parsed.isValid) {
      setState(() => _formError = parsed.error);
      return;
    }
    setState(() => _formError = null);
    await ref
        .read(gmailImportControllerProvider.notifier)
        .saveOAuth(parsed.credentials!);
    if (!mounted) return;
    ref.read(snackbarProvider).show(l10n.gmailImportOAuthSavedSnack);
  }

  Future<void> _onConfirmClear() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.gmailImportRemoveTitle),
        content: Text(l10n.gmailImportRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.gmailImportRemoveConfirm),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await ref.read(gmailImportControllerProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;

    return NestCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.gmailImportOAuthTitle,
                  style: NestText.itemTitle16.copyWith(color: c.ink),
                ),
                NestButton(
                  label: l10n.gmailImportPasteJsonBtn,
                  kind: NestButtonKind.tonal,
                  size: NestButtonSize.sm,
                  icon: Icons.content_paste_rounded,
                  onPressed: _onPasteJson,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.gmailImportOAuthLead,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientIdCtrl,
              decoration: InputDecoration(
                labelText: l10n.gmailImportClientIdLabel,
                hintText: l10n.gmailImportClientIdHint,
              ),
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientSecretCtrl,
              obscureText: _obscureSecret,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.gmailImportClientSecretLabel,
                hintText: l10n.gmailImportClientSecretHint,
                suffixIcon: IconButton(
                  tooltip: _obscureSecret
                      ? l10n.gmailImportShowSecret
                      : l10n.gmailImportHideSecret,
                  onPressed: () =>
                      setState(() => _obscureSecret = !_obscureSecret),
                  icon: Icon(
                    _obscureSecret
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              AlertLine(
                icon: Icons.error_outline,
                text: _oauthErrorText(l10n, _formError!),
                danger: true,
              ),
            ],
            const SizedBox(height: 14),
            NestButton(
              label: l10n.gmailImportSaveOAuthBtn,
              size: NestButtonSize.block,
              onPressed: _onSave,
            ),
            if (widget.config.hasOAuth || widget.config.drafts.isNotEmpty) ...[
              const SizedBox(height: 10),
              NestButton(
                label: l10n.gmailImportRemoveConfigBtn,
                kind: NestButtonKind.dangerGhost,
                size: NestButtonSize.block,
                onPressed: _onConfirmClear,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modal sheet allowing the user to paste downloaded Desktop App JSON.
Future<GmailOAuthCredentials?> showPasteOAuthJsonSheet(
  BuildContext context,
) async {
  return showNestSheet<GmailOAuthCredentials>(
    context,
    (_) => const _PasteOAuthJsonSheet(),
  );
}

class _PasteOAuthJsonSheet extends StatefulWidget {
  const _PasteOAuthJsonSheet();

  @override
  State<_PasteOAuthJsonSheet> createState() => _PasteOAuthJsonSheetState();
}

class _PasteOAuthJsonSheetState extends State<_PasteOAuthJsonSheet> {
  final _ctrl = TextEditingController();
  GmailOAuthParseError? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _apply() {
    final parsed = parseGmailOAuthInput(_ctrl.text);
    if (!parsed.isValid) {
      setState(() => _err = parsed.error);
      return;
    }
    Navigator.of(context).pop(parsed.credentials);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.gmailImportPasteJsonTitle,
          lead: l10n.gmailImportPasteJsonLead,
        ),
        TextField(
          controller: _ctrl,
          maxLines: 6,
          minLines: 4,
          decoration: InputDecoration(
            labelText: l10n.gmailImportPasteJsonField,
            alignLabelWithHint: true,
          ),
        ),
        if (_err != null) ...[
          const SizedBox(height: 10),
          AlertLine(
            icon: Icons.error_outline,
            text: _oauthErrorText(l10n, _err!),
            danger: true,
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonCancel,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () => Navigator.of(context).pop(),
            ),
            NestButton(
              label: l10n.gmailImportApplyJsonBtn,
              size: NestButtonSize.block,
              onPressed: _apply,
            ),
          ],
        ),
      ],
    );
  }
}

/// Modal sheet allowing offline invoice text parsing directly into Drafts.
Future<void> showPasteInvoiceSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  await showNestSheet<void>(
    context,
    (_) => _PasteInvoiceSheet(ref: ref),
  );
}

class _PasteInvoiceSheet extends StatefulWidget {
  const _PasteInvoiceSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_PasteInvoiceSheet> createState() => _PasteInvoiceSheetState();
}

class _PasteInvoiceSheetState extends State<_PasteInvoiceSheet> {
  final _ctrl = TextEditingController();
  bool _notMatched = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    final l10n = AppLocalizations.of(context);
    final draft = await widget.ref
        .read(gmailImportControllerProvider.notifier)
        .importPastedText(_ctrl.text);
    if (!mounted) return;
    if (draft == null) {
      setState(() => _notMatched = true);
      return;
    }
    Navigator.of(context).pop();
    widget.ref
        .read(snackbarProvider)
        .show(l10n.gmailImportPasteAddedSnack(draft.channel.displayName));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NestSheetHeader(
          title: l10n.gmailImportPasteInvoiceTitle,
          lead: l10n.gmailImportPasteInvoiceLead,
        ),
        TextField(
          controller: _ctrl,
          maxLines: 8,
          minLines: 5,
          decoration: InputDecoration(
            labelText: l10n.gmailImportPasteInvoiceField,
            alignLabelWithHint: true,
          ),
          onChanged: (_) {
            if (_notMatched) setState(() => _notMatched = false);
          },
        ),
        if (_notMatched) ...[
          const SizedBox(height: 10),
          AlertLine(
            icon: Icons.error_outline,
            text: l10n.gmailImportPasteNotMatched,
            danger: true,
          ),
        ],
        NestSheetActions(
          children: [
            NestButton(
              label: l10n.commonCancel,
              kind: NestButtonKind.ghost,
              size: NestButtonSize.block,
              onPressed: () => Navigator.of(context).pop(),
            ),
            NestButton(
              label: l10n.gmailImportParseToDraftBtn,
              size: NestButtonSize.block,
              onPressed: _parse,
            ),
          ],
        ),
      ],
    );
  }
}

String _oauthErrorText(AppLocalizations l10n, GmailOAuthParseError err) =>
    switch (err) {
      GmailOAuthParseError.empty => l10n.gmailImportErrOAuthEmpty,
      GmailOAuthParseError.malformed => l10n.gmailImportErrOAuthMalformed,
      GmailOAuthParseError.webClientNotSupported => l10n.gmailImportErrWebClient,
      GmailOAuthParseError.invalidClientId =>
        l10n.gmailImportErrInvalidClientId,
      GmailOAuthParseError.missingClientSecret =>
        l10n.gmailImportErrMissingSecret,
    };
