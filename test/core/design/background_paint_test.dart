import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nm_flat/core/design/components/components.dart';
import 'package:nm_flat/core/design/nest_background.dart';

void main() {
  testWidgets(
    'NestPatternBackground isolates painter in RepaintBoundary sibling',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NestTheme.light(),
          home: Scaffold(
            body: SizedBox(
              width: 240,
              height: 160,
              child: NestPatternBackground(
                borderRadius: BorderRadius.circular(16),
                child: const Text('Pattern Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pattern Child'), findsOneWidget);
      final paintFinder = find.descendant(
        of: find.byType(NestPatternBackground),
        matching: find.byWidgetPredicate(
          (w) => w is CustomPaint && w.isComplex && !w.willChange,
        ),
      );
      expect(paintFinder, findsOneWidget);
      final boundaryFinder = find.ancestor(
        of: paintFinder,
        matching: find.byType(RepaintBoundary),
      );
      expect(
        find.descendant(
          of: find.byType(NestPatternBackground),
          matching: boundaryFinder,
        ),
        findsOneWidget,
      );

      // Verify clean State.dispose() tears down cached ui.Picture without error.
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('KolamBackground isolates painter in RepaintBoundary sibling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NestTheme.light(),
        home: const Scaffold(
          body: SizedBox(
            width: 200,
            height: 120,
            child: KolamBackground(
              child: Text('Kolam Child'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kolam Child'), findsOneWidget);
    final paintFinder = find.descendant(
      of: find.byType(KolamBackground),
      matching: find.byWidgetPredicate(
        (w) => w is CustomPaint && w.isComplex && !w.willChange,
      ),
    );
    expect(paintFinder, findsOneWidget);
    final boundaryFinder = find.ancestor(
      of: paintFinder,
      matching: find.byType(RepaintBoundary),
    );
    expect(
      find.descendant(
        of: find.byType(KolamBackground),
        matching: boundaryFinder,
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
