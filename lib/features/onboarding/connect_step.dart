import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/join/join_guest.dart';
import 'package:nm_flat/features/onboarding/join_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ConnectStep extends ConsumerStatefulWidget {
  const ConnectStep({super.key});

  @override
  ConsumerState<ConnectStep> createState() => _ConnectStepState();
}

class _ConnectStepState extends ConsumerState<ConnectStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(joinControllerProvider.notifier).start());
      }
    });
  }

  Widget _stepIcon(BuildContext context, JoinStepState st) {
    final c = context.nest;
    return switch (st) {
      JoinStepState.active => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.2),
      ),
      JoinStepState.done => Icon(Icons.check_circle_rounded, color: c.ok, size: 22),
      JoinStepState.fail => Icon(Icons.cancel_rounded, color: c.danger, size: 22),
      JoinStepState.todo => Icon(Icons.circle, color: c.line2, size: 12),
    };
  }

  Widget _stepRow(BuildContext context, JoinStepState st, String text) {
    final c = context.nest;
    final style = st == JoinStepState.todo
        ? NestText.body15.copyWith(color: c.ink3)
        : NestText.body15.copyWith(color: c.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Center(child: _stepIcon(context, st)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }

  (String, String) _errorTexts(
    AppLocalizations l,
    JoinFailure f,
    String who,
    String inviter,
  ) => switch (f) {
    JoinFailure.notFound => (l.errNotFound(who), l.errNotFoundHelp(inviter)),
    JoinFailure.wrongCode => (l.errWrongCode, l.errWrongCodeHelp(inviter)),
    JoinFailure.expired => (l.errExpired, ''),
    JoinFailure.declined => (l.errDeclined(inviter), l.errDeclinedHelp(inviter)),
    JoinFailure.version => (l.errVersion(inviter), ''),
    JoinFailure.interrupted => (l.errCopy, ''),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final ui = ref.watch(joinControllerProvider);
    final ctrl = ref.read(joinControllerProvider.notifier);

    final hasInviter = ui.inviterName != null && ui.inviterName!.isNotEmpty;
    final who = hasInviter ? l.whoName(ui.inviterName!) : l.whoTheir;
    final inviter = hasInviter ? ui.inviterName! : l.whoTheir;
    final homeName = ui.homeName ?? '';

    final eyebrow = ui.homeName != null && ui.homeName!.isNotEmpty
        ? l.connectEyebrowHome(homeName)
        : l.connectEyebrow;
    final title = ui.failure != null
        ? l.connectFailed
        : (ui.copy == JoinStepState.done
              ? l.connectWelcome(homeName)
              : l.connectTitle);

    final findText = ui.find == JoinStepState.done
        ? l.stepFindDone(who)
        : l.stepFindActive(who);
    final codeText = ui.code == JoinStepState.done
        ? l.stepCodeDone
        : l.stepCodeActive;
    final approveText = ui.approve == JoinStepState.done
        ? l.stepApproveDone(inviter, ui.role)
        : l.stepApproveActive(inviter);
    final copyText = ui.copy == JoinStepState.done
        ? l.stepCopyDone(ui.count)
        : l.stepCopyActive(ui.pct);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: NestText.eyebrow12.copyWith(color: c.ink3),
              ),
              const SizedBox(height: 6),
              Text(title, style: NestText.display30.copyWith(color: c.ink)),
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _stepRow(context, ui.find, findText),
                    _stepRow(context, ui.code, codeText),
                    _stepRow(context, ui.approve, approveText),
                    if (ui.emojis.isNotEmpty &&
                        ui.approve != JoinStepState.done) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 36, bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: c.infoSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l.stepApproveSas(inviter, ui.emojis.join(' ')),
                            style: NestText.itemTitle16.copyWith(color: c.ink),
                          ),
                        ),
                      ),
                    ],
                    _stepRow(context, ui.copy, copyText),
                    if (ui.copy == JoinStepState.active) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 36, bottom: 8),
                        child: NestProgressBar(value: ui.pct / 100),
                      ),
                    ],
                  ],
                ),
              ),
              if (ui.failure != null) ...[
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final (errTitle, errSub) = _errorTexts(
                      l,
                      ui.failure!,
                      who,
                      inviter,
                    );
                    return InfoBanner(
                      icon: Icons.error_outline_rounded,
                      title: errTitle,
                      subtitle: errSub,
                    );
                  },
                ),
                const SizedBox(height: 16),
                NestButton(
                  label: l.tryAgain,
                  kind: NestButtonKind.primary,
                  size: NestButtonSize.block,
                  onPressed: ctrl.retry,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(Routes.onboardingStep('join')),
                  child: Text(
                    l.useDifferentCode,
                    style: NestText.button15.copyWith(color: c.primary),
                  ),
                ),
              ],
              if (ui.running && ui.approve != JoinStepState.done) ...[
                const SizedBox(height: 20),
                NestButton(
                  label: l.commonCancel,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.block,
                  onPressed: () async {
                    await ctrl.cancel();
                    if (!context.mounted) return;
                    ref.read(snackbarProvider).show(l.stoppedSnack);
                    context.go(Routes.onboardingStep('join'));
                  },
                ),
              ],
              if (ui.approve == JoinStepState.done &&
                  ui.copy != JoinStepState.done &&
                  ui.homeId != null &&
                  ref.read(prefsProvider).setupIncompleteHomeId ==
                      ui.homeId) ...[
                const SizedBox(height: 20),
                NestButton(
                  label: l.finishLater,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.block,
                  onPressed: () => ref
                      .read(prefsProvider)
                      .setCurrentHomeId(ui.homeId!),
                ),
                const SizedBox(height: 6),
                Text(
                  l.finishLaterNote,
                  textAlign: TextAlign.center,
                  style: NestText.meta13.copyWith(color: c.ink3),
                ),
              ],
              if (ui.copy == JoinStepState.done && ui.homeId != null) ...[
                const SizedBox(height: 20),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ui.others.isNotEmpty) ...[
                        AvatarStack(
                          people: [
                            for (final o in ui.others)
                              (
                                name: o.name,
                                color: o.color.isEmpty
                                    ? c.primary
                                    : NestPalette.fromHex(o.color),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        l.successBody([for (final o in ui.others) o.name].join(', ')),
                        style: NestText.body15.copyWith(color: c.ink2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                NestButton(
                  label: l.goHome(homeName),
                  kind: NestButtonKind.primary,
                  size: NestButtonSize.block,
                  onPressed: () async {
                    await ref.read(prefsProvider).setCurrentHomeId(ui.homeId!);
                    ref
                        .read(snackbarProvider)
                        .show(l.joinedSnack(homeName, ui.role));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
