import 'package:flutter_test/flutter_test.dart';
import 'package:nm_flat/core/domain/quick_add_type.dart';
import 'package:nm_flat/features/quickadd/quick_add_controller.dart';
import 'package:nm_flat/l10n/gen/app_localizations_en.dart';

void main() {
  test('quickAddPreview formats spend, item and todo previews', () {
    final l10n = AppLocalizationsEn();
    const today = '2026-11-23';

    expect(
      quickAddPreview(
        const QuickAddState(text: '₹450 Swiggy', type: QaType.spend),
        l10n,
        today: today,
        people: const [],
        rules: const {},
        usualMap: const {},
      ),
      'Spend · ₹450 · Swiggy · Eating out',
    );

    expect(
      quickAddPreview(
        const QuickAddState(text: 'milk 2L', type: QaType.grocery),
        l10n,
        today: today,
        people: const [],
        rules: const {},
        usualMap: const {'milk': 'blinkit'},
      ),
      'Grocery · Milk 2 L → Blinkit (usual)',
    );
  });
}
