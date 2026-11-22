import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<void> showLeavingSheet(
  BuildContext context, {
  required String homeId,
  required String homeName,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => LeavingSheet(homeId: homeId, homeName: homeName),
  ),
);

/// Full-screen waiting screen while delivering a `leave` op to a family phone.
class LeavingSheet extends ConsumerStatefulWidget {
  const LeavingSheet({
    super.key,
    required this.homeId,
    required this.homeName,
  });

  final String homeId;
  final String homeName;

  @override
  ConsumerState<LeavingSheet> createState() => _LeavingSheetState();
}

class _LeavingSheetState extends ConsumerState<LeavingSheet> {
  Timer? _timer;
  bool _showRemoveNow = false;
  bool _busy = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 20), () {
      if (mounted) setState(() => _showRemoveNow = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_done || !mounted) return;
    _done = true;
    await ref.read(controlStoreProvider).markShown(widget.homeId);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ref.read(snackbarProvider).show(l10n.homeLeft(widget.homeName));
    context.go(Routes.onboardingStep('welcome'));
  }

  Future<void> _removeNow() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(membershipServiceProvider).removeFromThisPhoneNow();
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.nest;

    ref.listen<AsyncValue<String?>>(currentHomeIdProvider, (_, next) {
      if (next.hasValue && next.value == null) {
        unawaited(_finish());
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 20),
                    Text(
                      l10n.leaveWaiting,
                      textAlign: TextAlign.center,
                      style: NestText.itemTitle16.copyWith(color: c.ink),
                    ),
                    if (_showRemoveNow) ...[
                      const SizedBox(height: 24),
                      NestButton(
                        label: l10n.leaveRemoveNow,
                        kind: NestButtonKind.primary,
                        size: NestButtonSize.block,
                        onPressed: _busy ? null : _removeNow,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
