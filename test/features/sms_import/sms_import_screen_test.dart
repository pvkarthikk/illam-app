import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/domain/sms/sms_models.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/sms/sms_platform_bridge.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/features/money/draft_expenses_section.dart';
import 'package:nm_flat/features/sms_import/sms_import_screen.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

class _TestSmsBridge implements SmsPlatformBridge {
  bool backgroundCaptureEnabled = false;
  List<RawSmsMessage> inbox = const [];

  @override
  Future<SmsPermissionStatus> checkPermissions() async =>
      const SmsPermissionStatus(
        supported: true,
        readGranted: true,
        receiveGranted: true,
        permanentlyDenied: false,
      );

  @override
  Future<SmsPermissionStatus> requestPermissions() => checkPermissions();

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> setBackgroundCaptureEnabled(bool enabled) async {
    backgroundCaptureEnabled = enabled;
  }

  @override
  Future<List<RawSmsMessage>> readInbox({
    required int sinceMs,
    int limit = 400,
  }) async =>
      inbox;

  @override
  Future<List<RawSmsMessage>> drainQueuedMessages() async => const [];

  @override
  void setIncomingHandler(
    Future<void> Function(RawSmsMessage msg)? onIncoming,
  ) {}
}

Future<(NestDatabase, SmsImportStore, _TestSmsBridge)> _pumpScreen(
  WidgetTester tester, {
  SmsImportConfig? initial,
  bool includeMoneySection = false,
}) async {
  tester.view.physicalSize = const Size(412, 1900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-SMS1');
  await prefs.setMemberId('mem-1');
  final clock = FixedClock(DateTime(2026, 11, 26, 10, 0));
  final changes = ChangeWriter(
    db,
    CollectionRegistry.build(db),
    HlcClock(clock, prefs),
    prefs,
    validator: const Validator(),
    clock: clock,
  );
  await changes.write('Seed member', (c) {
    c.create('members', {
      'full_name': 'Karthik',
      'first_name': 'Karthik',
      'role': 'admin',
      'status': 'active',
    }, id: 'mem-1');
  }, homeId: 'NM-SMS1');

  final secure = MemorySecureStore();
  final store = SmsImportStore(secure);
  addTearDown(store.dispose);
  if (initial != null) {
    await store.save('NM-SMS1', initial);
  }
  final bridge = _TestSmsBridge();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(secure),
        clockProvider.overrideWithValue(clock),
        changesProvider.overrideWithValue(changes),
        smsImportStoreProvider.overrideWithValue(store),
        smsPlatformBridgeProvider.overrideWithValue(bridge),
      ],
      child: MaterialApp(
        theme: NestTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScaffoldMessenger(
          child: includeMoneySection
              ? const Scaffold(
                  body: SingleChildScrollView(child: DraftExpensesSection()),
                )
              : const SmsImportScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (db, store, bridge);
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('SmsImportScreen & Draft review workflow', () {
    testWidgets(
      'toggle OFF hides controls & disables receiver; toggle ON reveals controls',
      (tester) async {
        final (_, store, bridge) = await _pumpScreen(tester);

        expect(find.text('SMS access'), findsNothing);
        expect(find.text('Scan SMS'), findsNothing);
        expect(bridge.backgroundCaptureEnabled, isFalse);

        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();

        expect((await store.load('NM-SMS1')).enabled, isTrue);
        expect(bridge.backgroundCaptureEnabled, isTrue);
        expect(find.text('SMS access'), findsOneWidget);
        expect(find.text('Auto-capture incoming SMS'), findsOneWidget);
        expect(find.text('Scan SMS'), findsOneWidget);
        expect(find.text('Paste SMS text'), findsOneWidget);
      },
    );

    testWidgets(
      'paste bank SMS creates Draft excluded from ledger, then Review -> Account it records expense',
      (tester) async {
        final (db, store, _) = await _pumpScreen(
          tester,
          initial: const SmsImportConfig(enabled: true),
        );

        await tester.tap(find.text('Paste SMS text'));
        await tester.pumpAndSettle();

        const smsText =
            'Sent Rs.450.00 From HDFC Bank A/C *1234 On 26/11/26 '
            'To SWIGGY On Ref 633012345678. Avl Bal Rs.19,550.00';
        await tester.enterText(find.byType(TextField).last, smsText);
        await tester.tap(find.text('Create draft'));
        await tester.pumpAndSettle();

        // Draft exists with Draft + SMS tags, while Drift expenses has 0 rows.
        var cfg = await store.load('NM-SMS1');
        expect(cfg.drafts.length, 1);
        expect(cfg.drafts.first.merchant, 'Swiggy');
        expect(await db.select(db.expenses).get(), isEmpty);
        expect(find.text('Draft'), findsOneWidget);
        expect(find.text('SMS'), findsOneWidget);

        // Open one-by-one review sheet and tap Account it.
        await tester.tap(find.text('Review'));
        await tester.pumpAndSettle();

        expect(find.text('Review SMS spend'), findsOneWidget);
        expect(find.text('Original SMS excerpt'), findsOneWidget);
        await tester.tap(find.text('Account it').last);
        await tester.pumpAndSettle();

        final rows = await db.select(db.expenses).get();
        expect(rows.length, 1);
        expect(rows.first.source, 'manual');
        expect(rows.first.method, 'upi');
        expect(rows.first.amountPaise, 45000);
        expect(rows.first.merchant, 'Swiggy');
        expect(rows.first.category, 'Eating out');

        cfg = await store.load('NM-SMS1');
        expect(cfg.drafts, isEmpty);
        expect(cfg.processedFingerprints, contains('sms_ref_633012345678'));
      },
    );

    testWidgets('discard removes SMS draft without adding ledger expense', (
      tester,
    ) async {
      final (db, store, _) = await _pumpScreen(
        tester,
        initial: const SmsImportConfig(enabled: true),
      );

      await tester.tap(find.text('Paste SMS text'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).last,
        'Spent Rs.300 on ICICI Bank Card XX9911 at BIGBASKET on 26/11/26',
      );
      await tester.tap(find.text('Create draft'));
      await tester.pumpAndSettle();

      expect((await store.load('NM-SMS1')).drafts.length, 1);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect((await store.load('NM-SMS1')).drafts, isEmpty);
      expect(await db.select(db.expenses).get(), isEmpty);
    });

    testWidgets(
      'DraftExpensesSection displays SMS draft when enabled and hides when disabled',
      (tester) async {
        const draft = SmsDraftSpend(
          id: 'sms_ref_888999000111',
          amountPaise: 29900,
          merchant: 'Uber',
          category: 'Utilities',
          method: 'upi',
          date: '2026-11-26',
          rawSnippet: 'Sent Rs.299...',
          receivedAtMs: 1700000000000,
          importedAtMs: 1700000001000,
        );
        final (_, store, _) = await _pumpScreen(
          tester,
          includeMoneySection: true,
          initial: const SmsImportConfig(enabled: true, drafts: [draft]),
        );

        expect(find.text('DRAFT EXPENSES (1)'), findsOneWidget);
        expect(find.text('Uber'), findsOneWidget);
        expect(find.text('SMS'), findsOneWidget);

        await store.save(
          'NM-SMS1',
          const SmsImportConfig(enabled: false, drafts: [draft]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Uber'), findsNothing);
      },
    );
  });
}
