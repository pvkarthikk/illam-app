import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/domain/names.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/util/ids.dart';
import 'package:nm_flat/features/onboarding/create_home_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class CreateHomeScreen extends ConsumerStatefulWidget {
  const CreateHomeScreen({super.key});

  @override
  ConsumerState<CreateHomeScreen> createState() => _CreateHomeScreenState();
}

class _CreateHomeScreenState extends ConsumerState<CreateHomeScreen> {
  late final int _createdAt;
  late final String _nonceB64;
  final _name = TextEditingController();
  final _home = TextEditingController();
  String? _nameError;
  String? _homeError;
  String _previewId = '';
  int _previewSeq = 0;
  bool _addStarter = true;

  @override
  void initState() {
    super.initState();
    _createdAt = ref.read(clockProvider).nowMs;
    _nonceB64 = base64.encode(Ids.randomBytes(16));
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePreview());
  }

  @override
  void dispose() {
    _name.dispose();
    _home.dispose();
    super.dispose();
  }

  Future<void> _updatePreview() async {
    final keys = ref.read(deviceKeysProvider).value;
    if (keys == null) return;
    final seq = ++_previewSeq;
    final id = await HomeIds.fromGenesis(
      HomeIds.genesisJson(
        homeName: _home.text.trim(),
        creatorName: Names.titleCase(_name.text),
        creatorDeviceId: keys.deviceId,
        signPubB64: keys.signPubB64,
        createdAt: _createdAt,
        nonceB64: _nonceB64,
      ),
    );
    if (!mounted || seq != _previewSeq) return;
    setState(() => _previewId = id);
  }

  void _onChanged() {
    setState(() {});
    _updatePreview();
  }

  void _submit(AppLocalizations l10n) {
    setState(() {
      _nameError = _name.text.trim().isEmpty ? l10n.createErrName : null;
      _homeError = _home.text.trim().isEmpty ? l10n.createErrHome : null;
    });
    if (_nameError != null || _homeError != null) return;
    ref
        .read(createHomeControllerProvider.notifier)
        .create(
          name: _name.text,
          homeName: _home.text,
          createdAt: _createdAt,
          nonceB64: _nonceB64,
          addStarter: _addStarter,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;
    final busy = ref.watch(createHomeControllerProvider);
    ref.listen(deviceKeysProvider, (_, next) {
      if (next.hasValue) _updatePreview();
    });
    final surname = Names.surname(_name.text) ?? l10n.createSurnameFallback;
    final suggestions = [
      l10n.createSuggestHome(surname),
      l10n.createSuggestFlat,
      l10n.createSuggestAmma,
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: l10n.commonBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              Text(
                l10n.createTitle,
                style: NestText.display30.copyWith(color: c.ink),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.createSub,
                style: NestText.body15.copyWith(color: c.ink2),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _name,
                maxLength: 40,
                autofillHints: const [AutofillHints.name],
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.createYourName,
                  hintText: l10n.createYourNameHint,
                  errorText: _nameError,
                ),
                onChanged: (_) => _onChanged(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _home,
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: l10n.createHomeName,
                  hintText: l10n.createHomeNameHint(surname),
                  errorText: _homeError,
                ),
                onChanged: (_) => _onChanged(),
              ),
              const SizedBox(height: 8),
              Semantics(
                container: true,
                label: l10n.createSuggestionsLabel,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in suggestions)
                      NestChip(
                        label: s,
                        onTap: () {
                          _home.text = s;
                          _onChanged();
                        },
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: DashedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.createHomeIdLabel,
                          style: TextStyle(
                            fontFamily: NestText.sans,
                            fontSize: 12,
                            color: c.ink3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _previewId.isEmpty
                              ? 'NM-····-····'
                              : HomeIds.display(_previewId),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: c.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.createHomeIdNote,
                          style: TextStyle(
                            fontFamily: NestText.sans,
                            fontSize: 12,
                            color: c.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _addStarter = !_addStarter),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      children: [
                        NestCheckbox(
                          value: _addStarter,
                          semanticLabel: l10n.onboardingAddStarterRecipes,
                          onChanged: (v) => setState(() => _addStarter = v),
                        ),
                        Expanded(
                          child: Text(
                            l10n.onboardingAddStarterRecipes,
                            style: NestText.body15.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: NestButton(
                  label: l10n.createButton,
                  size: NestButtonSize.block,
                  onPressed: busy ? null : () => _submit(l10n),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
