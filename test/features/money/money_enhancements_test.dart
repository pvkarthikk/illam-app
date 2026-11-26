import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/db/database.dart';
import 'package:nm_flat/core/data/ops/change_writer.dart';
import 'package:nm_flat/core/data/ops/collection_registry.dart';
import 'package:nm_flat/core/data/prefs/device_prefs.dart';
import 'package:nm_flat/core/data/secure/secure_store.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/nav/routes.dart';
import 'package:nm_flat/core/providers.dart';
import 'package:nm_flat/core/sms/sms_import_config.dart';
import 'package:nm_flat/core/sms/sms_platform_bridge.dart';
import 'package:nm_flat/core/sync/validator.dart';
import 'package:nm_flat/core/time/clock.dart';
import 'package:nm_flat/core/time/hlc.dart';
import 'package:nm_flat/features/money/draft_expenses_section.dart';
import 'package:nm_flat/features/money/money_screen.dart';
import 'package:nm_flat/features/money/money_sections.dart';
import 'package:nm_flat/features/money/widgets/spend_category_picker.dart';
import 'package:nm_flat/features/money/widgets/spend_pie_chart.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

Future<({
  NestDatabase db,
  DevicePrefs prefs,
  MemorySecureStore secure,
  ChangeWriter changes,
  SmsImportStore smsStore,
  FixedClock clock,
})> _seedMoneyEnv(WidgetTester tester) async {
  tester.view.physicalSize = const Size(412, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final db = NestDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final prefs = await DevicePrefs.inMemory();
  await prefs.setCurrentHomeId('NM-MON1');
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
  await changes.write('Seed home & members', (c) {
    c.create('homes', {
      'name': 'Home',
      'budget_monthly_paise': 5000000,
    }, id: 'NM-MON1');
    c.create('members', {
      'full_name': 'Karthik',
      'first_name': 'Karthik',
      'role': 'admin',
      'status': 'active',
      'color': '#23503A',
    }, id: 'mem-1');
    c.create('members', {
      'full_name': 'Priya',
      'first_name': 'Priya',
      'role': 'member',
      'status': 'active',
      'color': '#34508A',
    }, id: 'mem-2');
  }, homeId: 'NM-MON1');

  final secure = MemorySecureStore();
  final smsStore = SmsImportStore(secure);
  addTearDown(smsStore.dispose);
  return (
    db: db,
    prefs: prefs,
    secure: secure,
    changes: changes,
    smsStore: smsStore,
    clock: clock,
  );
}

SmsDraftSpend _smsDraft(int idx) => SmsDraftSpend(
  id: 'sms_ref_000000000$idx',
  amountPaise: (100 + idx) * 100,
  merchant: 'Merchant ${idx.toString().padLeft(2, '0')}',
  category: 'Shopping',
  method: 'upi',
  date: '2026-11-26',
  rawSnippet: 'Sent Rs.${100 + idx}...',
  receivedAtMs: 1700000000000 - idx * 1000,
  importedAtMs: 1700000001000,
);

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets(
    'DraftExpensesSection paginates at 10 with Show all and collapses via header',
    (tester) async {
      final env = await _seedMoneyEnv(tester);
      final drafts = [for (var i = 1; i <= 12; i++) _smsDraft(i)];
      await env.smsStore.save(
        'NM-MON1',
        SmsImportConfig(enabled: true, drafts: drafts),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(env.db),
            prefsProvider.overrideWithValue(env.prefs),
            secureStoreProvider.overrideWithValue(env.secure),
            clockProvider.overrideWithValue(env.clock),
            changesProvider.overrideWithValue(env.changes),
            smsImportStoreProvider.overrideWithValue(env.smsStore),
            smsPlatformBridgeProvider.overrideWithValue(
              const UnsupportedSmsPlatformBridge(),
            ),
          ],
          child: MaterialApp(
            theme: NestTheme.light(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: const Scaffold(
              body: SingleChildScrollView(child: DraftExpensesSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DRAFT EXPENSES (12)'), findsOneWidget);
      expect(find.text('Showing 10 of 12'), findsOneWidget);
      expect(find.text('Merchant 01'), findsOneWidget);
      expect(find.text('Merchant 10'), findsOneWidget);
      expect(find.text('Merchant 11'), findsNothing);
      expect(find.text('Show all (12)'), findsOneWidget);

      await tester.ensureVisible(find.text('Show all (12)'));
      await tester.tap(find.text('Show all (12)'));
      await tester.pumpAndSettle();

      expect(find.text('Merchant 11'), findsOneWidget);
      expect(find.text('Merchant 12'), findsOneWidget);
      expect(find.text('Show first 10'), findsOneWidget);

      await tester.ensureVisible(find.text('DRAFT EXPENSES (12)'));
      await tester.tap(find.text('DRAFT EXPENSES (12)'));
      await tester.pumpAndSettle();

      expect(find.text('Merchant 01'), findsNothing);
      expect(find.text('Show first 10'), findsNothing);

      await tester.ensureVisible(find.text('DRAFT EXPENSES (12)'));
      await tester.tap(find.text('DRAFT EXPENSES (12)'));
      await tester.pumpAndSettle();

      expect(find.text('Merchant 01'), findsOneWidget);
    },
  );

  testWidgets(
    'MoneyScreen places DraftExpensesSection after RecentSection and toggles pie chart modes',
    (tester) async {
      final env = await _seedMoneyEnv(tester);
      await env.changes.write('Seed spends', (c) {
        c.create('expenses', {
          'amount_paise': 50000,
          'merchant': 'Apollo Pharmacy',
          'merchant_key': 'apollo pharmacy',
          'category': 'Medical',
          'method': 'upi',
          'date': '2026-11-26',
          'doc_month': '2026-11',
          'paid_by': 'mem-1',
          'added_by': 'mem-1',
          'source': 'manual',
        });
        c.create('expenses', {
          'amount_paise': 30000,
          'merchant': 'Zepto',
          'merchant_key': 'zepto',
          'category': 'Groceries',
          'method': 'upi',
          'date': '2026-11-25',
          'doc_month': '2026-11',
          'paid_by': 'mem-2',
          'added_by': 'mem-1',
          'source': 'manual',
        });
      }, homeId: 'NM-MON1');

      await env.smsStore.save(
        'NM-MON1',
        SmsImportConfig(enabled: true, drafts: [_smsDraft(1)]),
      );

      final router = GoRouter(
        initialLocation: Routes.money,
        routes: [
          GoRoute(
            path: Routes.money,
            builder: (_, _) => const MoneyScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(env.db),
            prefsProvider.overrideWithValue(env.prefs),
            secureStoreProvider.overrideWithValue(env.secure),
            clockProvider.overrideWithValue(env.clock),
            changesProvider.overrideWithValue(env.changes),
            smsImportStoreProvider.overrideWithValue(env.smsStore),
            smsPlatformBridgeProvider.overrideWithValue(
              const UnsupportedSmsPlatformBridge(),
            ),
          ],
          child: MaterialApp.router(
            theme: NestTheme.light(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // DraftExpensesSection renders after RecentSection at bottom of Money tab.
      expect(find.byType(RecentSection), findsOneWidget);
      expect(find.byType(DraftExpensesSection), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(DraftExpensesSection)).dy,
        greaterThan(tester.getTopLeft(find.byType(RecentSection)).dy),
      );

      // Pie chart is hidden by default.
      expect(find.byType(SpendPieChartCard), findsNothing);
      expect(find.text('Show chart'), findsOneWidget);

      await tester.ensureVisible(find.text('Show chart'));
      await tester.tap(find.text('Show chart'));
      await tester.pumpAndSettle();

      final chartFinder = find.byType(SpendPieChartCard);
      expect(chartFinder, findsOneWidget);
      expect(find.text('Hide chart'), findsOneWidget);
      expect(
        find.descendant(of: chartFinder, matching: find.text('Apollo Pharmacy')),
        findsOneWidget,
      );

      // Switch to By category -> custom category 'Medical' appears in chart.
      await tester.ensureVisible(find.text('By category'));
      await tester.tap(find.text('By category'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: chartFinder, matching: find.text('Medical')),
        findsOneWidget,
      );

      // Switch to By people -> shows You and Priya.
      await tester.ensureVisible(find.text('By people'));
      await tester.tap(find.text('By people'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: chartFinder, matching: find.text('You')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chartFinder, matching: find.text('Priya')),
        findsOneWidget,
      );

      // Toggle off.
      await tester.ensureVisible(find.text('Hide chart'));
      await tester.tap(find.text('Hide chart'));
      await tester.pumpAndSettle();
      expect(find.byType(SpendPieChartCard), findsNothing);
    },
  );

  testWidgets(
    'SpendCategoryPicker exposes custom category chips and inline custom entry',
    (tester) async {
      var picked = 'Other';

      await tester.pumpWidget(
        MaterialApp(
          theme: NestTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) => SpendCategoryPicker(
                  value: picked,
                  categories: const ['Groceries', 'Travel', 'Other'],
                  onChanged: (v) => setState(() => picked = v),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Travel'), findsOneWidget);
      expect(find.text('＋ Custom'), findsOneWidget);

      await tester.tap(find.text('＋ Custom'));
      await tester.pump();

      expect(picked, '');
      await tester.enterText(find.byType(TextField), 'Medical');
      await tester.pump();

      expect(picked, 'Medical');
    },
  );
}
