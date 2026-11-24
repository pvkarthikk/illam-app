import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/net/local_ip.dart';
import 'package:nm_flat/features/invite/invite_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class InviteCard extends ConsumerWidget {
  const InviteCard({
    super.key,
    required this.homeId,
    required this.homeName,
    required this.ui,
  });

  final String homeId;
  final String homeName;
  final InviteUi ui;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final ctrl = ref.read(inviteControllerProvider.notifier);

    if (ui.stage == InviteStage.expired) {
      return NestCard(
        child: KolamBackground(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.inviteExpired,
                  style: NestText.itemTitle16.copyWith(color: c.danger),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                NestButton(
                  label: l.inviteMakeNew,
                  kind: NestButtonKind.primary,
                  size: NestButtonSize.block,
                  onPressed: ctrl.newInvite,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final inv = ui.invite;
    if (inv == null) {
      return const NestCard(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ticket = JoinTicket(
      homeId: homeId,
      ip: ui.ip ?? '127.0.0.1',
      nameplate: inv.nameplate,
      port: ui.port ?? 0,
      secret: inv.qrSecret,
      expiry: inv.expiresAt.millisecondsSinceEpoch ~/ 1000,
    );

    return NestCard(
      child: KolamBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: QrImageView(
                  data: ticket.toUrl(),
                  size: 196,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                  semanticsLabel: l.inviteQrLabel(homeName),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l.inviteOrTypePhrase,
                style: NestText.eyebrow12.copyWith(color: c.ink3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  SelectableText(
                    inv.phrase,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 22,
                      color: c.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, color: c.ink2),
                    tooltip: l.inviteCopyPhrase,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inv.phrase));
                      ref.read(snackbarProvider).show(l.invitePhraseCopied);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              NestButton(
                label: l.inviteSendWhatsApp,
                kind: NestButtonKind.primary,
                size: NestButtonSize.block,
                onPressed: () {
                  final text = l.inviteWhatsAppText(homeName, inv.phrase);
                  final uri = Uri.parse(
                    'https://wa.me/?text=${Uri.encodeComponent(text)}',
                  );
                  unawaited(
                    launchUrl(uri, mode: LaunchMode.externalApplication),
                  );
                },
              ),
              const SizedBox(height: 12),
              Semantics(
                liveRegion: false,
                child: _InviteCountdown(expiresAt: inv.expiresAt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteCountdown extends StatefulWidget {
  const _InviteCountdown({required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_InviteCountdown> createState() => _InviteCountdownState();
}

class _InviteCountdownState extends State<_InviteCountdown> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _countdown(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    final secs = diff.isNegative ? 0 : diff.inSeconds;
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    return Text(
      l.inviteValidFor(_countdown(widget.expiresAt)),
      style: NestText.meta13.copyWith(color: c.ink3),
      textAlign: TextAlign.center,
    );
  }
}

class InviteNetworkCard extends StatefulWidget {
  const InviteNetworkCard({super.key, this.port});

  final int? port;

  @override
  State<InviteNetworkCard> createState() => _InviteNetworkCardState();
}

class _InviteNetworkCardState extends State<InviteNetworkCard> {
  late final Future<bool> _wifi = onWifi();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    return NestCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<bool>(
            future: _wifi,
            builder: (context, snap) {
              final hasWifi = snap.data ?? false;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    hasWifi ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color: hasWifi ? c.primary : c.ink3,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasWifi ? l.inviteVisibleWifi : l.inviteNoWifi,
                          style: NestText.itemTitle16.copyWith(color: c.ink),
                        ),
                        if (hasWifi) ...[
                          const SizedBox(height: 2),
                          Text(
                            l.inviteVisibleWifiSub,
                            style: NestText.meta13.copyWith(color: c.ink3),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.inviteWaiting,
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.inviteWaitingSub,
                      style: NestText.meta13.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (kDebugMode && widget.port != null) ...[
            const SizedBox(height: 10),
            Text(
              l.debugInvitePort(widget.port!),
              style: NestText.small12.copyWith(color: c.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class JoinRequestCard extends ConsumerStatefulWidget {
  const JoinRequestCard({super.key, required this.ui});

  final InviteUi ui;

  @override
  ConsumerState<JoinRequestCard> createState() => _JoinRequestCardState();
}

class _JoinRequestCardState extends ConsumerState<JoinRequestCard> {
  String _role = 'member';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nest;
    final ctrl = ref.read(inviteControllerProvider.notifier);
    final ui = widget.ui;

    if (ui.stage == InviteStage.copying) {
      return NestCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.inviteAdding(ui.request?.name ?? ''),
              style: NestText.cardTitle20.copyWith(color: c.ink),
            ),
            const SizedBox(height: 8),
            Text(
              l.inviteSending(ui.pct),
              style: NestText.body15.copyWith(color: c.ink2),
            ),
            const SizedBox(height: 10),
            NestProgressBar(value: ui.pct / 100),
            const SizedBox(height: 8),
            Text(
              l.inviteSendingSub,
              style: NestText.meta13.copyWith(color: c.ink3),
            ),
          ],
        ),
      );
    }

    if (ui.stage == InviteStage.done) {
      return NestCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: c.ok, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.inviteJoined(ui.joinedName ?? ''),
                    style: NestText.cardTitle20.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l.inviteJoinedSub,
              style: NestText.body15.copyWith(color: c.ink2),
            ),
            const SizedBox(height: 14),
            NestButton(
              label: l.inviteAnother,
              kind: NestButtonKind.tonal,
              size: NestButtonSize.sm,
              onPressed: ctrl.newInvite,
            ),
          ],
        ),
      );
    }

    final req = ui.request;
    if (req == null) return const SizedBox.shrink();

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: l.inviteRequestEyebrow,
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.accent, width: 1.5),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.inviteRequestEyebrow,
              style: NestText.eyebrow12.copyWith(color: c.accentInk),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Avatar(name: req.name, color: c.accent, size: AvatarSize.s52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.name,
                        style: NestText.cardTitle20.copyWith(color: c.ink),
                      ),
                      Text(
                        l.inviteRequestVia(req.model),
                        style: NestText.meta13.copyWith(color: c.ink3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.infoSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.inviteRequestSas(ui.emojis.join(' ')),
                    style: NestText.itemTitle16.copyWith(
                      color: c.ink,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.inviteRequestSasHint,
                    style: NestText.meta13.copyWith(color: c.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.inviteJoinsAs,
              style: NestText.eyebrow12.copyWith(color: c.ink3),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NestChip(
                  label: l.roleMember,
                  selected: _role == 'member',
                  onTap: () => setState(() => _role = 'member'),
                ),
                NestChip(
                  label: l.roleAdmin,
                  selected: _role == 'admin',
                  onTap: () => setState(() => _role = 'admin'),
                ),
              ],
            ),
            if (_role == 'admin') ...[
              const SizedBox(height: 6),
              Text(
                l.inviteAdminNote,
                style: NestText.meta13.copyWith(color: c.ink3),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                NestButton(
                  label: l.inviteDeny,
                  kind: NestButtonKind.ghost,
                  onPressed: () {
                    unawaited(ctrl.deny());
                    ref
                        .read(snackbarProvider)
                        .show(l.inviteDeclinedSnack(req.name));
                  },
                ),
                NestButton(
                  label: l.inviteAllow,
                  kind: NestButtonKind.primary,
                  onPressed: () => ctrl.allow(_role),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
