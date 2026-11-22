import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class CookScreen extends ConsumerStatefulWidget {
  const CookScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends ConsumerState<CookScreen> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipe = ref.watch(recipeProvider(widget.id)).value;

    if (recipe == null || recipe.steps.isEmpty) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: NestPalette.immersiveBg,
          body: SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  tooltip: l10n.commonClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: NestPalette.immersiveText,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final total = recipe.steps.length;
    final current = _step.clamp(0, total - 1);
    final stepText = recipe.steps[current];
    final isLast = current == total - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: NestPalette.immersiveBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.cookBack,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: NestPalette.immersiveText,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: NestText.title22.copyWith(
                              color: NestPalette.immersiveText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            l10n.cookSub,
                            style: NestText.meta13.copyWith(
                              color: NestPalette.immersiveMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var i = 0; i < total; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: ShapeDecoration(
                            shape: const StadiumBorder(),
                            color: i <= current
                                ? NestPalette.immersiveAccent
                                : NestPalette.immersiveMuted.withValues(
                                    alpha: 0.25,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${current + 1}',
                      style: const TextStyle(
                        fontFamily: NestText.serif,
                        fontSize: 96,
                        height: 1.0,
                        color: NestPalette.immersiveAccent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.cookOf(total),
                      style: const TextStyle(
                        fontFamily: NestText.sans,
                        fontSize: 28,
                        color: NestPalette.immersiveMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    label: l10n.cookStepSemantics(current + 1, total, stepText),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: !isLast
                          ? () => setState(() => _step = current + 1)
                          : null,
                      child: SingleChildScrollView(
                        child: Text(
                          stepText,
                          style: const TextStyle(
                            fontFamily: NestText.sans,
                            fontSize: 26,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            fontVariations: [FontVariation.weight(600)],
                            color: NestPalette.immersiveText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: OutlinedButton(
                            onPressed: current == 0
                                ? null
                                : () => setState(() => _step = current - 1),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: NestPalette.immersiveText,
                              disabledForegroundColor:
                                  NestPalette.immersiveMuted.withValues(
                                    alpha: 0.35,
                                  ),
                              side: BorderSide(
                                color: current == 0
                                    ? NestPalette.immersiveMuted.withValues(
                                        alpha: 0.25,
                                      )
                                    : NestPalette.immersiveMuted,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              l10n.cookBack,
                              style: NestText.button16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: FilledButton(
                            onPressed: isLast
                                ? () => context.pop()
                                : () => setState(() => _step = current + 1),
                            style: FilledButton.styleFrom(
                              backgroundColor: NestPalette.immersiveAccent,
                              foregroundColor: NestPalette.immersiveBg,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              isLast ? l10n.cookFinished : l10n.cookNext,
                              style: NestText.button16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
