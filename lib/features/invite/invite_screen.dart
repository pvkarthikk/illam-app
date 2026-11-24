import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:nm_flat/core/backup/backup_health.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/home_ids.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/features/account/home_members_parts.dart';
import 'package:nm_flat/features/invite/invite_controller.dart';
import 'package:nm_flat/features/invite/invite_parts.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key, this.firstRun = false});

  final bool firstRun;

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  Timer? _tick;
  InviteController? _ctrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAdmin());
  }

  void _initAdmin() {
    if (!mounted || !ref.read(isAdminProvider)) return;
    final ctrl = ref.read(inviteControllerProvider.notifier);
    _ctrl = ctrl;
    unawaited(ctrl.start());
    unawaited(_setWakelock(true));
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final ui = ref.read(inviteControllerProvider);
      if (ui.stage == InviteStage.waiting &&
          ui.invite != null &&
          !ui.invite!.isOpen(DateTime.now())) {
        ref.read(inviteControllerProvider.notifier).expireNow();
      }
    });
  }

  Future<void> _setWakelock(bool enable) async {
    try {
      if (enable) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } on Object {
      // Platform channel absent in headless tests.
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    final ctrl = _ctrl;
    if (ctrl != null) {
      unawaited(ctrl.pause());
      unawaited(_setWakelock(false));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final isAdmin = ref.watch(isAdminProvider);
    final home = ref.watch(currentHomeProvider).value;
    final homeId = home?.id ?? ref.watch(prefsProvider).currentHomeId ?? '';
    final homeName = home?.name ?? '';

    if (!isAdmin) {
      final adminList = ref.watch(adminNamesProvider);
      return Scaffold(
        appBar: NestTopBar.sub(title: l.inviteTitle),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            l.inviteMembersOnly(adminNames(adminList, l)),
            style: NestText.body15.copyWith(color: c.ink2),
          ),
        ),
      );
    }

    final ui = ref.watch(inviteControllerProvider);
    final hideNetwork =
        ui.stage == InviteStage.request ||
        ui.stage == InviteStage.copying ||
        ui.stage == InviteStage.done;

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.firstRun) ...[
          Text(
            l.inviteFirstRunTitle(homeName),
            style: NestText.display30.copyWith(color: c.ink),
          ),
          const SizedBox(height: 4),
          Text(
            l.inviteFirstRunSub(HomeIds.display(homeId)),
            style: NestText.meta13.copyWith(color: c.ink3),
          ),
          const SizedBox(height: 8),
          Text(
            l.inviteFirstRunLead,
            style: NestText.body15.copyWith(color: c.ink2),
          ),
          const SizedBox(height: 16),
        ],
        if (ui.stage == InviteStage.waiting || ui.stage == InviteStage.expired)
          InviteCard(homeId: homeId, homeName: homeName, ui: ui),
        if (ui.stage == InviteStage.request ||
            ui.stage == InviteStage.copying ||
            ui.stage == InviteStage.done)
          JoinRequestCard(ui: ui),
        if (ui.stage == InviteStage.done && ui.showSecondAdminTip) ...[
          const SizedBox(height: 12),
          InfoBanner(
            icon: Icons.admin_panel_settings_outlined,
            title: l.inviteTipSecondAdmin,
            subtitle: '',
            info: true,
          ),
          const SizedBox(height: 10),
          if ((ref.watch(backupHealthProvider).value?.state ??
                  HealthState.none) ==
              HealthState.none)
            NestButton(
              label: l.inviteBackupNow(homeName),
              kind: NestButtonKind.tonal,
              size: NestButtonSize.block,
              onPressed: () => context.push(Routes.backup),
            ),
        ],
        if (!hideNetwork) ...[
          const SizedBox(height: 12),
          InviteNetworkCard(port: ui.port),
        ],
        const SizedBox(height: 20),
        if (widget.firstRun)
          ui.stage == InviteStage.done
              ? NestButton(
                  label: l.inviteContinue,
                  kind: NestButtonKind.primary,
                  size: NestButtonSize.block,
                  onPressed: () => context.go(Routes.today),
                )
              : NestButton(
                  label: l.inviteSkip,
                  kind: NestButtonKind.ghost,
                  size: NestButtonSize.block,
                  onPressed: () {
                    context.go(Routes.today);
                    ref
                        .read(snackbarProvider)
                        .show(l.inviteWelcomeSnack(homeName));
                  },
                )
        else
          NestButton(
            label: l.inviteDone,
            kind: NestButtonKind.ghost,
            size: NestButtonSize.block,
            onPressed: () => context.pop(),
          ),
      ],
    );

    final scaffold = Scaffold(
      appBar: widget.firstRun
          ? null
          : NestTopBar.sub(title: l.inviteTitle, subtitle: homeName),
      body: SafeArea(top: widget.firstRun, child: body),
    );

    return widget.firstRun
        ? PopScope(canPop: false, child: scaffold)
        : scaffold;
  }
}
