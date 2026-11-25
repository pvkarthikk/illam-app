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
import 'package:nm_flat/core/gmail/gmail_import_config.dart';
import 'package:nm_flat/core/gmail/pdf_text_extractor.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/features/gmail_import/gmail_import_screen.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<(NestDatabase, GmailImportStore, MemorySecureStore)> _pumpScreen(
  WidgetTester tester, {
  GmailImportConfig? initial,
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
  await prefs.setCurrentHomeId('NM-GM1');
  await prefs.setMemberId('mem-1');
  final clock = FixedClock(DateTime(2026, 11, 25, 10, 0));
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
  }, homeId: 'NM-GM1');

  final secure = MemorySecureStore();
  final store = GmailImportStore(secure);
  addTearDown(store.dispose);
  if (initial != null) {
    await store.save('NM-GM1', initial);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(secure),
        clockProvider.overrideWithValue(clock),
        changesProvider.overrideWithValue(changes),
        gmailImportStoreProvider.overrideWithValue(store),
        pdfTextExtractorProvider.overrideWithValue(
          const EmptyPdfTextExtractor(),
        ),
      ],
      child: MaterialApp(
        theme: NestTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ScaffoldMessenger(child: GmailImportScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (db, store, secure);
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('GmailImportScreen & Draft accounting workflow', () {
    testWidgets(
      'toggle OFF hides setup cards; toggle ON reveals guide and OAuth form',
      (tester) async {
        final (_, store, _) = await _pumpScreen(tester);

        expect(find.text('Google Desktop OAuth'), findsNothing);
        expect(find.text('Paste OAuth JSON'), findsNothing);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect((await store.load('NM-GM1')).enabled, isTrue);
        expect(find.text('Google Desktop OAuth'), findsOneWidget);
        expect(find.text('Paste OAuth JSON'), findsOneWidget);
        expect(find.text('Paste invoice text'), findsOneWidget);
      },
    );

    testWidgets(
      'paste invoice creates Draft excluded from ledger, then Review -> Account it records expenses',
      (tester) async {
        final (db, store, _) = await _pumpScreen(
          tester,
          initial: const GmailImportConfig(enabled: true),
        );

        await tester.tap(find.text('Paste invoice text'));
        await tester.pumpAndSettle();

        const zeptoInvoice = '''
Zepto Order #ZP-556677
Order Date: 25 Nov 2026
Amul Milk 500ml | 1 | ₹30.00
Farm Fresh Eggs 6pcs | 1 | ₹70.00
Grand Total: ₹100.00
''';
        await tester.enterText(find.byType(TextField).last, zeptoInvoice);
        await tester.tap(find.text('Create draft'));
        await tester.pumpAndSettle();

        // Draft exists with Draft badge, but Drift expenses table has 0 rows yet.
        var cfg = await store.load('NM-GM1');
        expect(cfg.drafts.length, 1);
        expect(cfg.drafts.first.items.length, 2);
        expect(await db.select(db.expenses).get(), isEmpty);
        expect(find.text('Draft'), findsOneWidget);

        // Open Review sheet and tap Account it.
        await tester.tap(find.text('Review'));
        await tester.pumpAndSettle();

        expect(find.text('Log each item separately'), findsOneWidget);
        await tester.tap(find.text('Account it').last);
        await tester.pumpAndSettle();

        // Now expenses exist in Drift under order channel 'zepto' and draft is cleared.
        final rows = await db.select(db.expenses).get();
        expect(rows.length, 2);
        expect(rows.every((r) => r.source == 'order'), isTrue);
        expect(rows.every((r) => r.orderChannel == 'zepto'), isTrue);
        expect(
          rows.fold<int>(0, (sum, r) => sum + r.amountPaise),
          10000,
        );

        cfg = await store.load('NM-GM1');
        expect(cfg.drafts, isEmpty);
      },
    );

    testWidgets('discard removes draft without adding ledger expenses', (
      tester,
    ) async {
      final (db, store, _) = await _pumpScreen(
        tester,
        initial: const GmailImportConfig(enabled: true),
      );

      await tester.tap(find.text('Paste invoice text'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).last,
        'Blinkit\nOrder Total: ₹250.00',
      );
      await tester.tap(find.text('Create draft'));
      await tester.pumpAndSettle();

      expect((await store.load('NM-GM1')).drafts.length, 1);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect((await store.load('NM-GM1')).drafts, isEmpty);
      expect(await db.select(db.expenses).get(), isEmpty);
    });
  });
}
