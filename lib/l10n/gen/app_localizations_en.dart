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

  @override
  String get errCantSecure =>
      'Nest Mojo : Flat can’t secure data on this phone';

  @override
  String welcomeHeadline(Object em) {
    return 'Run your home,\n$em';
  }

  @override
  String get welcomeHeadlineEm => 'together.';

  @override
  String get welcomeSub =>
      'House help, groceries, chores, meals and spends — shared between the phones in your home.';

  @override
  String get welcomeStartLabel => 'How do you want to start?';

  @override
  String get welcomeCreateTitle => 'Create a home';

  @override
  String get welcomeCreateBody =>
      'Set it up for your family. You’ll be the admin and invite the others.';

  @override
  String get welcomeJoinTitle => 'Join a home';

  @override
  String get welcomeJoinBody =>
      'Someone at home already uses Nest Mojo : Flat. Scan their QR code or type their phrase.';

  @override
  String get welcomeHint =>
      'Only one person creates the home — everyone else joins it.';

  @override
  String get welcomeRestore => 'Restore from a backup';

  @override
  String get welcomeFine =>
      'No account, no cloud. Your home’s data stays on your family’s phones and syncs directly between them.';

  @override
  String get welcomeCreditLine1 => 'Made at home, for homes.';

  @override
  String welcomeCreditLine2(Object heart) {
    return 'with $heart by Nandini Srinivasan & Karthik Venkatesh';
  }

  @override
  String get welcomeCreditA11y =>
      'Made at home, for homes, with love by Nandini Srinivasan and Karthik Venkatesh';

  @override
  String get createTitle => 'Create your home';

  @override
  String get createSub =>
      'You’ll be its admin. Others join from their phones with a QR code or a short phrase.';

  @override
  String get createYourName => 'Your name';

  @override
  String get createYourNameHint => 'e.g. Anand Kumar';

  @override
  String get createHomeName => 'Home name';

  @override
  String createHomeNameHint(Object surname) {
    return 'e.g. $surname Home';
  }

  @override
  String createSuggestHome(Object surname) {
    return '$surname Home';
  }

  @override
  String get createSuggestFlat => 'Our flat';

  @override
  String get createSuggestAmma => 'Amma’s house';

  @override
  String get createSurnameFallback => 'Our';

  @override
  String get createSuggestionsLabel => 'Suggestions';

  @override
  String get createHomeIdLabel => 'Home ID';

  @override
  String get createHomeIdNote => 'Made on this phone · unique to your home';

  @override
  String get createButton => 'Create home';

  @override
  String get createErrName => 'Add your name.';

  @override
  String get createErrHome => 'Give your home a name.';

  @override
  String get todayGreetingLate => 'Still up';

  @override
  String get todayGreetingMorning => 'Good morning';

  @override
  String get todayGreetingAfternoon => 'Good afternoon';

  @override
  String get todayGreetingEvening => 'Good evening';

  @override
  String todayEyebrow(Object home, Object date) {
    return '$home · $date';
  }

  @override
  String todayHeadlineAllSet(Object em) {
    return 'The house is $em today.';
  }

  @override
  String get todayAllSetEm => 'all set';

  @override
  String get debugViewAsMember => 'Viewing as member';

  @override
  String get debugViewAsMemberSub => 'Hide admin-only controls (UI test only)';

  @override
  String debugIsAdmin(Object value) {
    return 'Admin on this phone: $value';
  }
}
