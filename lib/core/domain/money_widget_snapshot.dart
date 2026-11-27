import 'package:nm_flat/core/domain/duplicate_hint.dart';
import 'package:nm_flat/core/domain/money_math.dart';
import 'package:nm_flat/core/domain/spend_category.dart';
import 'package:nm_flat/core/time/dates.dart';
import 'package:nm_flat/core/util/money.dart';

/// Recent spend item shown inside the Android Quick Spend widget.
class MoneyWidgetRecentItem {
  const MoneyWidgetRecentItem({
    required this.merchant,
    required this.amountText,
    required this.category,
  });

  final String merchant;
  final String amountText;
  final String category;

  Map<String, Object?> toJson() => {
    'merchant': merchant,
    'amountText': amountText,
    'category': category,
  };
}

/// Complete JSON-serializable snapshot consumed by the Android Money Spend widget
/// and quick-spend dialog.
class MoneyWidgetSnapshot {
  const MoneyWidgetSnapshot({
    required this.hasHome,
    required this.homeName,
    required this.date,
    required this.month,
    required this.monthSpentPaise,
    required this.monthSpentText,
    required this.budgetSubtitle,
    required this.headerTitle,
    required this.addLabel,
    required this.scanLabel,
    required this.emptyText,
    required this.categories,
    required this.recentMerchants,
    required this.recentItems,
  });

  const MoneyWidgetSnapshot.noHome({
    this.date = '',
    this.headerTitle = 'Month spend',
    this.addLabel = 'Add spend',
    this.scanLabel = 'Scan',
    this.emptyText = 'Open Illam to set up your home.',
  }) : hasHome = false,
       homeName = '',
       month = '',
       monthSpentPaise = 0,
       monthSpentText = '₹0',
       budgetSubtitle = '',
       categories = const [],
       recentMerchants = const [],
       recentItems = const [];

  final bool hasHome;
  final String homeName;
  final String date;
  final String month;
  final int monthSpentPaise;
  final String monthSpentText;
  final String budgetSubtitle;
  final String headerTitle;
  final String addLabel;
  final String scanLabel;
  final String emptyText;
  final List<Map<String, String>> categories;
  final List<String> recentMerchants;
  final List<MoneyWidgetRecentItem> recentItems;

  Map<String, Object?> toJson() => {
    'hasHome': hasHome,
    'homeName': homeName,
    'date': date,
    'month': month,
    'monthSpentPaise': monthSpentPaise,
    'monthSpentText': monthSpentText,
    'budgetSubtitle': budgetSubtitle,
    'headerTitle': headerTitle,
    'addLabel': addLabel,
    'scanLabel': scanLabel,
    'emptyText': emptyText,
    'categories': categories,
    'recentMerchants': recentMerchants,
    'recentItems': [for (final item in recentItems) item.toJson()],
  };
}

/// Pure builder for [MoneyWidgetSnapshot].
MoneyWidgetSnapshot buildMoneyWidgetSnapshot({
  required bool hasHome,
  String homeName = '',
  required String today,
  required List<SpendLite> monthExpenses,
  required List<SpendLite> recentSpends,
  Set<String> excludedSalaryExpenseIds = const {},
  int? budgetMonthlyPaise,
  List<String> extraCategories = const [],
  Map<String, String> localizedCategoryLabels = const {},
  String headerTitle = 'Month spend',
  String addLabel = 'Add spend',
  String scanLabel = 'Scan',
  String emptyText = 'No spends recorded this month.',
  String noHomeText = 'Open Illam to set up your home.',
  String Function(String left, String budget)? budgetLeftText,
  String Function(String over, String budget)? budgetOverText,
}) {
  if (!hasHome) {
    return MoneyWidgetSnapshot.noHome(
      date: today,
      headerTitle: headerTitle,
      addLabel: addLabel,
      scanLabel: scanLabel,
      emptyText: noHomeText,
    );
  }

  final month = Dates.month(today);
  final spentPaise = monthTotal(monthExpenses, month, excludedSalaryExpenseIds);

  var budgetSub = '';
  if (budgetMonthlyPaise != null && budgetMonthlyPaise > 0) {
    final diff = budgetMonthlyPaise - spentPaise;
    final budgetFmt = Money.format(budgetMonthlyPaise);
    if (diff >= 0) {
      final leftFmt = Money.format(diff);
      budgetSub = budgetLeftText != null
          ? budgetLeftText(leftFmt, budgetFmt)
          : '$leftFmt left of $budgetFmt';
    } else {
      final overFmt = Money.format(-diff);
      budgetSub = budgetOverText != null
          ? budgetOverText(overFmt, budgetFmt)
          : '$overFmt over $budgetFmt budget';
    }
  }

  final mergedCats = mergeSpendCategories(extraCategories);
  final categoryEntries = [
    for (final id in mergedCats)
      {'id': id, 'label': localizedCategoryLabels[id] ?? id},
  ];

  final seenMerchantKeys = <String>{};
  final topMerchants = <String>[];
  for (final s in recentSpends) {
    final name = s.merchant.trim();
    final key = s.merchantKey.trim();
    if (name.isEmpty || key.isEmpty || s.source == 'salary') continue;
    if (seenMerchantKeys.add(key)) {
      topMerchants.add(name);
      if (topMerchants.length >= 6) break;
    }
  }

  final recentRows = <MoneyWidgetRecentItem>[];
  for (final e in monthExpenses) {
    if (e.source == 'salary' && excludedSalaryExpenseIds.contains(e.id)) {
      continue;
    }
    if (e.amountPaise <= 0) continue;
    recentRows.add(
      MoneyWidgetRecentItem(
        merchant: e.merchant.trim().isEmpty ? 'Spend' : e.merchant.trim(),
        amountText: Money.format(e.amountPaise),
        category: '',
      ),
    );
    if (recentRows.length >= 2) break;
  }

  return MoneyWidgetSnapshot(
    hasHome: true,
    homeName: homeName,
    date: today,
    month: month,
    monthSpentPaise: spentPaise,
    monthSpentText: Money.format(spentPaise),
    budgetSubtitle: budgetSub,
    headerTitle: headerTitle,
    addLabel: addLabel,
    scanLabel: scanLabel,
    emptyText: emptyText,
    categories: categoryEntries,
    recentMerchants: topMerchants,
    recentItems: recentRows,
  );
}
