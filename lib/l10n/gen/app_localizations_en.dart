// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nest Mojo : Flat';

  @override
  String get tabToday => 'Today';

  @override
  String get tabLists => 'Lists';

  @override
  String get tabTasks => 'Tasks';

  @override
  String get tabMeals => 'Meals';

  @override
  String get tabMoney => 'Money';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDecrease => 'Decrease';

  @override
  String get commonIncrease => 'Increase';

  @override
  String commonArrivesIn(Object phase) {
    return 'Arrives in $phase';
  }

  @override
  String get debugTitle => 'Developer tools';

  @override
  String get debugGallery => 'Component gallery';

  @override
  String get debugGallerySub => 'Every shared component, light and dark';

  @override
  String get debugDarkTheme => 'Dark theme';

  @override
  String get dayToday => 'Today';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String get dayYesterday => 'Yesterday';
}
