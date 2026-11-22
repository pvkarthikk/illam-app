import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('shared components render and expose semantics', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: NestTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(
            body: Column(
              children: [
                NestButton(label: 'Go', onPressed: () {}),
                const NestTag(label: 'Due', kind: NestTagKind.accent),
                NestCheckbox(
                  value: true,
                  onChanged: (_) {},
                  semanticLabel: 'Mark milk',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Go'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(NestCheckbox)),
        isSemantics(hasCheckedState: true, isChecked: true),
      );
    } finally {
      handle.dispose();
    }
  });
}
