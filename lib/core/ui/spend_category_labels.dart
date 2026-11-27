import 'package:nm_flat/l10n/gen/app_localizations.dart';

/// Maps canonical built-in spend categories (stored in English for cross-phone
/// sync parity) to their localized display labels, leaving custom categories as-is.
String localizedSpendCategory(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Groceries':
      return l10n.spendCatGroceries;
    case 'Shopping':
      return l10n.spendCatShopping;
    case 'Staff':
      return l10n.spendCatStaff;
    case 'Utilities':
      return l10n.spendCatUtilities;
    case 'Eating out':
      return l10n.spendCatEatingOut;
    case 'Home care':
      return l10n.spendCatHomeCare;
    case 'Other':
      return l10n.spendCatOther;
    default:
      return category;
  }
}
