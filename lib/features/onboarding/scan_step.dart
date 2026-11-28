import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/join_phrase.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/features/onboarding/join_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class ScanStep extends ConsumerStatefulWidget {
  const ScanStep({super.key});

  @override
  ConsumerState<ScanStep> createState() => _ScanStepState();
}

class _ScanStepState extends ConsumerState<ScanStep>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _anim;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _anim.stop();
    } else if (!_anim.isAnimating) {
      unawaited(_anim.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _openAppSettings() async {
    final info = await PackageInfo.fromPlatform();
    final intent = AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:${info.packageName}',
    );
    await intent.launch();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final t = JoinTicket.parse(raw);
      if (t != null) {
        _handled = true;
        ref.read(joinControllerProvider.notifier).useTicket(t);
        context.go(Routes.onboardingStep('connect'));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final disableAnim = MediaQuery.disableAnimationsOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.onboardingStep('join'));
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: NestPalette.immersiveBg,
          appBar: AppBar(
            backgroundColor: NestPalette.immersiveBg,
            foregroundColor: NestPalette.immersiveText,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              tooltip: l.commonBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go(Routes.onboardingStep('join')),
            ),
            title: Text(
              l.scanTitle,
              style: NestText.title22.copyWith(
                color: NestPalette.immersiveText,
              ),
            ),
            actions: [
              IconButton(
                tooltip: l.scanTorch,
                icon: const Icon(Icons.flashlight_on_rounded),
                onPressed: () => unawaited(_controller.toggleTorch()),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    l.scanHint,
                    style: NestText.body15.copyWith(
                      color: NestPalette.immersiveMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _onDetect,
                        errorBuilder: (context, error) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l.scanDenied,
                                  textAlign: TextAlign.center,
                                  style: NestText.body16.copyWith(
                                    color: NestPalette.immersiveText,
                                  ),
                                ),
                                if (error.errorCode ==
                                    MobileScannerErrorCode.permissionDenied) ...[
                                  const SizedBox(height: 16),
                                  NestButton(
                                    label: l.scanOpenSettings,
                                    kind: NestButtonKind.accent,
                                    onPressed: _openAppSettings,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _ScanOverlayPainter(
                            animation: disableAnim ? null : _anim,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.scanNote,
                        textAlign: TextAlign.center,
                        style: NestText.meta13.copyWith(
                          color: NestPalette.immersiveMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      NestButton(
                        label: l.scanTypeInstead,
                        kind: NestButtonKind.ghost,
                        size: NestButtonSize.block,
                        onPressed: () =>
                            context.go(Routes.onboardingStep('phrase')),
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

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({this.animation}) : super(repaint: animation);

  final Animation<double>? animation;

  @override
  void paint(Canvas canvas, Size size) {
    const boxSize = 240.0;
    const corner = 24.0;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: boxSize,
      height: boxSize,
    );

    final bracketPaint = Paint()
      ..color = NestPalette.immersiveAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      // Top-left
      ..moveTo(rect.left, rect.top + corner)
      ..lineTo(rect.left, rect.top)
      ..lineTo(rect.left + corner, rect.top)
      // Top-right
      ..moveTo(rect.right - corner, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.top + corner)
      // Bottom-left
      ..moveTo(rect.left, rect.bottom - corner)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left + corner, rect.bottom)
      // Bottom-right
      ..moveTo(rect.right - corner, rect.bottom)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right, rect.bottom - corner);

    canvas.drawPath(path, bracketPaint);

    if (animation != null) {
      final y = rect.top + 8 + (rect.height - 16) * animation!.value;
      final linePaint = Paint()
        ..color = NestPalette.immersiveAccent.withValues(alpha: 0.85)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(rect.left + 8, y),
        Offset(rect.right - 8, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
