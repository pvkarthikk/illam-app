import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/features/onboarding/join_controller.dart';
import 'package:nm_flat/features/onboarding/welcome_screen.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class JoinStep extends ConsumerStatefulWidget {
  const JoinStep({super.key});

  @override
  ConsumerState<JoinStep> createState() => _JoinStepState();
}

class _JoinStepState extends ConsumerState<JoinStep> {
  late final TextEditingController _name;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: ref.read(joinControllerProvider).name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _pick(AppLocalizations l, String step) {
    final raw = _name.text.trim();
    if (raw.isEmpty) {
      setState(() => _nameError = l.joinNameRequired);
      return;
    }
    ref.read(joinControllerProvider.notifier).setName(raw);
    context.go(Routes.onboardingStep(step));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.onboardingStep('welcome'));
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l.commonBack,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go(Routes.onboardingStep('welcome')),
          ),
          backgroundColor: c.paper,
          surfaceTintColor: Colors.transparent,
          foregroundColor: c.ink,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(l.joinTitle, style: NestText.display30.copyWith(color: c.ink)),
            const SizedBox(height: 8),
            Text(l.joinSub, style: NestText.body15.copyWith(color: c.ink2)),
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              autofillHints: const [AutofillHints.name],
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l.joinYourName,
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 20),
            ChoiceCard(
              icon: Icons.qr_code_scanner_rounded,
              tileBg: c.primarySoft,
              tileFg: c.primary,
              title: l.joinScanTitle,
              body: l.joinScanSub,
              onTap: () => _pick(l, 'scan'),
            ),
            const SizedBox(height: 12),
            ChoiceCard(
              icon: Icons.keyboard_rounded,
              tileBg: c.accentSoft,
              tileFg: c.accentInk,
              title: l.joinPhraseTitle,
              body: l.joinPhraseSub,
              onTap: () => _pick(l, 'phrase'),
            ),
          ],
        ),
      ),
    );
  }
}
