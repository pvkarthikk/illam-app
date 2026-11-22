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

  @override
  String undoConflict(Object name) {
    return 'Couldn’t undo — $name changed it.';
  }

  @override
  String get undoConflictYou => 'Couldn’t undo — you changed it.';

  @override
  String get undoConflictSomeone => 'Couldn’t undo — someone else changed it.';

  @override
  String get debugDataLab => 'Data lab';

  @override
  String get debugDataLabSub => 'Notes, undo and the op log';

  @override
  String get labAddNote => 'Add note';

  @override
  String get labNoteHint => 'Note title';

  @override
  String get labNoteAdded => 'Note added';

  @override
  String get labNoteRenamed => 'Note renamed';

  @override
  String get labNoteDeleted => 'Note deleted';

  @override
  String get labPinned => 'Pinned';

  @override
  String get labUnpinned => 'Unpinned';

  @override
  String labTaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taps',
      one: '1 tap',
    );
    return '$_temp0';
  }

  @override
  String get labRecent => 'Recent changes';

  @override
  String get labOpLog => 'Op log';

  @override
  String labOpsTotal(int count) {
    return '$count ops';
  }

  @override
  String get labPin => 'Pin';

  @override
  String get labEdit => 'Edit';

  @override
  String get labDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get debugLoadDemo => 'Load demo home';

  @override
  String get debugLoadDemoSub => 'Adds sample data for every finished phase';

  @override
  String get debugDemoLoaded => 'Demo data loaded';

  @override
  String get debugWipe => 'Wipe this phone';

  @override
  String get debugWipeSub => 'Erase the database and settings';

  @override
  String get debugWipeTitle => 'Erase everything on this phone?';

  @override
  String get debugWipeConfirm => 'Wipe';

  @override
  String get debugWiped => 'This phone was wiped';

  @override
  String get commonCancel => 'Cancel';
}
