import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/word_list.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/features/onboarding/join_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class PhraseStep extends ConsumerStatefulWidget {
  const PhraseStep({super.key});

  @override
  ConsumerState<PhraseStep> createState() => _PhraseStepState();
}

class _PhraseStepState extends ConsumerState<PhraseStep> {
  final _phrase = TextEditingController();
  final _port = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phrase.dispose();
    _port.dispose();
    super.dispose();
  }

  String _currentPrefix(String text) {
    final idx = text.lastIndexOf(RegExp(r'[\s_\-]'));
    return (idx >= 0 ? text.substring(idx + 1) : text).toLowerCase();
  }

  void _applySuggestion(String word) {
    final t = _phrase.text;
    final idx = t.lastIndexOf(RegExp(r'[\s_\-]'));
    final updated = idx >= 0 ? '${t.substring(0, idx + 1)}$word' : word;
    _phrase.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
    setState(() => _error = null);
  }

  void _connect(AppLocalizations l, WordList? wordList) {
    if (wordList == null) return;
    final res = JoinPhrase.check(_phrase.text, wordList.set);
    if (res == PhraseCheck.badFormat) {
      setState(() => _error = l.phraseBadFormat);
      return;
    }
    if (res == PhraseCheck.unknownWord) {
      setState(() => _error = l.phraseBadWord);
      return;
    }
    final debugPort = kDebugMode ? int.tryParse(_port.text.trim()) : null;
    ref
        .read(joinControllerProvider.notifier)
        .usePhrase(JoinPhrase.normalise(_phrase.text), debugPort: debugPort);
    context.go(Routes.onboardingStep('connect'));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final wordList = ref.watch(wordListProvider).value;
    final prefix = _currentPrefix(_phrase.text);
    final suggestions = (wordList != null && prefix.length >= 2)
        ? wordList.startingWith(prefix)
        : const <String>[];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.onboardingStep('join'));
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l.commonBack,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go(Routes.onboardingStep('join')),
          ),
          backgroundColor: c.paper,
          surfaceTintColor: Colors.transparent,
          foregroundColor: c.ink,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              l.joinPhraseTitle,
              style: NestText.display30.copyWith(color: c.ink),
            ),
            const SizedBox(height: 8),
            Text(l.phraseSub, style: NestText.body15.copyWith(color: c.ink2)),
            const SizedBox(height: 20),
            TextField(
              controller: _phrase,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: InputDecoration(
                labelText: l.phraseField,
                hintText: l.phraseHint,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: NestText.meta13.copyWith(color: c.danger),
                ),
              ),
            ],
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final w in suggestions)
                    NestChip(
                      label: w,
                      onTap: () => _applySuggestion(w),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(l.phraseNote, style: NestText.meta13.copyWith(color: c.ink3)),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _port,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.debugPort),
              ),
            ],
            const SizedBox(height: 24),
            NestButton(
              label: l.phraseConnect,
              kind: NestButtonKind.primary,
              size: NestButtonSize.block,
              onPressed: wordList == null ? null : () => _connect(l, wordList),
            ),
          ],
        ),
      ),
    );
  }
}
