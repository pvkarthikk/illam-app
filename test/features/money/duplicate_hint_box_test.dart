import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/data/repo/money_repo.dart';
import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/features/money/widgets/duplicate_hint_box.dart';
import 'package:nm_flat/features/staff/staff_providers.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('DuplicateHintBox formats duplicate message and handles taps', (
    WidgetTester tester,
  ) async {
    var addedAnyway = false;
    var dontAdd = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayDateProvider.overrideWithValue('2026-11-20')],
        child: MaterialApp(
          theme: NestTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: DuplicateHintBox(
              hit: const DuplicateHit(
                whoFirstName: 'Priya',
                amountPaise: 48600,
                merchant: 'Zepto',
                date: '2026-11-19',
              ),
              onDontAdd: () => dontAdd = true,
              onAddAnyway: () => addedAnyway = true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Looks like Priya already added ₹486 · Zepto yesterday.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Add anyway'));
    await tester.pump();
    expect(addedAnyway, isTrue);
    expect(dontAdd, isFalse);
  });
}
