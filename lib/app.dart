import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workmanager/workmanager.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/router.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/notify/background_tasks.dart';
import 'package:nm_flat/core/notify/notifications.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/control_dialer.dart';
import 'package:nm_flat/core/sync/control_store.dart';
import 'package:nm_flat/core/sync/op_ignored_notifier.dart';
import 'package:nm_flat/core/sync/sync_engine.dart';
import 'package:nm_flat/features/account/home_gone_dialog.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class NestApp extends ConsumerStatefulWidget {
  const NestApp({super.key});

  @override
  ConsumerState<NestApp> createState() => _NestAppState();
}

class _NestAppState extends ConsumerState<NestApp> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<String>? _ignoredSub;
  StreamSubscription<void>? _controlSub;
  Timer? _dialTimer;
  Duration? _dialPeriod;
  Timer? _planTimer;
  String? _handlingTombstoneHomeId;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _schedulePlan);
    _ignoredSub = ref.read(opIgnoredProvider).reasons.listen(_onIgnoredReason);
    _controlSub = ref.read(controlStoreProvider).changes.listen(
      (_) => unawaited(_syncDialTimer()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _schedulePlan();
    });
  }

  void _onIgnoredReason(String reason) {
    final l = lookupAppLocalizations(const Locale('en'));
    final text = reason == 'lastAdmin'
        ? l.syncReasonLastAdmin
        : l.opIgnoredRoleChanged;
    ref.read(snackbarProvider).show(l.syncChangeNotApplied(text));
  }

  Future<void> _syncDialTimer() async {
    try {
      final cs = ref.read(controlStoreProvider);
      final pending = await cs.pendingKinds();
      if (!mounted) return;
      final Duration? period = pending.outbox
          ? const Duration(seconds: 30)
          : (pending.tombstones ? const Duration(minutes: 5) : null);
      if (period != null) {
        if (_dialTimer == null || _dialPeriod != period) {
          _dialTimer?.cancel();
          _dialPeriod = period;
          _dialTimer = Timer.periodic(
            period,
            (_) => unawaited(ref.read(controlDialerProvider).runOnce()),
          );
        }
      } else {
        _dialTimer?.cancel();
        _dialTimer = null;
        _dialPeriod = null;
      }
    } catch (_) {}
  }

  void _schedulePlan() {
    _planTimer?.cancel();
    _planTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_runPlan());
    });
    unawaited(_syncDialTimer());
  }

  Future<void> _runPlan() async {
    try {
      await planAndEnqueue(ref.read);
    } catch (e) {
      debugPrint('planAndEnqueue skipped: $e');
    }
  }

  @override
  void dispose() {
    _planTimer?.cancel();
    _dialTimer?.cancel();
    _controlSub?.cancel();
    _ignoredSub?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(startupProvider, (_, _) {});
    ref.listen<AsyncValue<Tombstone?>>(homeGoneProvider, (_, next) {
      final t = next.value;
      if (t == null || _handlingTombstoneHomeId == t.homeId) return;
      _handlingTombstoneHomeId = t.homeId;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          _handlingTombstoneHomeId = null;
          return;
        }
        try {
          final store = ref.read(controlStoreProvider);
          final stillUnshown = (await store.unshownTombstones()).any(
            (u) => u.homeId == t.homeId,
          );
          if (!stillUnshown) return;
          if (t.reason == 'left') {
            await store.markShown(t.homeId);
            final l = lookupAppLocalizations(const Locale('en'));
            ref.read(snackbarProvider).show(l.homeLeft(t.homeName));
            ref.read(routerProvider).go(Routes.onboardingStep('welcome'));
          } else {
            final navCtx = rootNavigatorKey.currentContext;
            if (navCtx != null && navCtx.mounted) {
              await showHomeGoneDialog(navCtx, t);
            }
          }
        } finally {
          _handlingTombstoneHomeId = null;
        }
      });
    });
    final router = ref.watch(routerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationRouter.instance.attach(router, ref.read);
      }
    });

    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      theme: NestTheme.light(),
      darkTheme: NestTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      scaffoldMessengerKey: ref.watch(snackbarProvider).messengerKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return SyncLifecycle(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                    .copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: Colors.transparent,
                    ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Manages foreground LAN sync, background WorkManager catch-up, and reconnect triggers.
class SyncLifecycle extends ConsumerStatefulWidget {
  const SyncLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends ConsumerState<SyncLifecycle> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<void>? _changedSub;
  StreamSubscription<void>? _syncedSub;
  Timer? _stopTimer;
  Timer? _startTimer;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume, onPause: _onPause);
    final engine = ref.read(syncEngineProvider);
    _startSoon();
    _syncedSub = engine.synced.listen((_) => _dirty = false);
    _changedSub = ref.read(changesProvider).changed.listen((_) {
      _dirty = true;
      ref.read(syncEngineProvider).onLocalChange();
    });
  }

  void _startSoon() {
    _startTimer?.cancel();
    _startTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        unawaited(ref.read(syncEngineProvider).startForeground());
      }
    });
  }

  void _onResume() {
    _stopTimer?.cancel();
    _stopTimer = null;
    _startSoon();
  }

  void _onPause() {
    _startTimer?.cancel();
    _startTimer = null;
    if (_dirty) {
      try {
        unawaited(
          Workmanager().registerOneOffTask(
            'nm.sync.once',
            'nm.sync',
            constraints: Constraints(networkType: NetworkType.connected),
            existingWorkPolicy: ExistingWorkPolicy.replace,
          ),
        );
      } on Object {
        // WorkManager plugin absent in widget tests.
      }
    }
    _stopTimer?.cancel();
    _stopTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        unawaited(ref.read(syncEngineProvider).stopForeground());
      }
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _stopTimer?.cancel();
    _changedSub?.cancel();
    _syncedSub?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncEngine>(syncEngineProvider, (prev, next) {
      _syncedSub?.cancel();
      _syncedSub = next.synced.listen((_) => _dirty = false);
      unawaited(next.startForeground());
    });
    ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityProvider, (
      prev,
      next,
    ) {
      if (prev != null && prev.hasValue && next.hasValue) {
        unawaited(ref.read(syncEngineProvider).syncNow());
      }
    });
    return widget.child;
  }
}
