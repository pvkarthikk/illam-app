import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nest Mojo : Flat'**
  String get appName;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get tabLists;

  /// No description provided for @tabTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tabTasks;

  /// No description provided for @tabMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get tabMeals;

  /// No description provided for @tabMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get tabMoney;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get commonDecrease;

  /// No description provided for @commonIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get commonIncrease;

  /// No description provided for @commonArrivesIn.
  ///
  /// In en, this message translates to:
  /// **'Arrives in {phase}'**
  String commonArrivesIn(Object phase);

  /// No description provided for @debugTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get debugTitle;

  /// No description provided for @debugGallery.
  ///
  /// In en, this message translates to:
  /// **'Component gallery'**
  String get debugGallery;

  /// No description provided for @debugGallerySub.
  ///
  /// In en, this message translates to:
  /// **'Every shared component, light and dark'**
  String get debugGallerySub;

  /// No description provided for @debugDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get debugDarkTheme;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dayTomorrow;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @undoConflict.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t undo — {name} changed it.'**
  String undoConflict(Object name);

  /// No description provided for @undoConflictYou.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t undo — you changed it.'**
  String get undoConflictYou;

  /// No description provided for @undoConflictSomeone.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t undo — someone else changed it.'**
  String get undoConflictSomeone;

  /// No description provided for @debugDataLab.
  ///
  /// In en, this message translates to:
  /// **'Data lab'**
  String get debugDataLab;

  /// No description provided for @debugDataLabSub.
  ///
  /// In en, this message translates to:
  /// **'Notes, undo and the op log'**
  String get debugDataLabSub;

  /// No description provided for @labAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get labAddNote;

  /// No description provided for @labNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note title'**
  String get labNoteHint;

  /// No description provided for @labNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get labNoteAdded;

  /// No description provided for @labNoteRenamed.
  ///
  /// In en, this message translates to:
  /// **'Note renamed'**
  String get labNoteRenamed;

  /// No description provided for @labNoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get labNoteDeleted;

  /// No description provided for @labPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get labPinned;

  /// No description provided for @labUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get labUnpinned;

  /// No description provided for @labTaps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tap} other{{count} taps}}'**
  String labTaps(int count);

  /// No description provided for @labRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent changes'**
  String get labRecent;

  /// No description provided for @labOpLog.
  ///
  /// In en, this message translates to:
  /// **'Op log'**
  String get labOpLog;

  /// No description provided for @labOpsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} ops'**
  String labOpsTotal(int count);

  /// No description provided for @labPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get labPin;

  /// No description provided for @labEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get labEdit;

  /// No description provided for @labDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get labDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @debugLoadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo home'**
  String get debugLoadDemo;

  /// No description provided for @debugLoadDemoSub.
  ///
  /// In en, this message translates to:
  /// **'Adds sample data for every finished phase'**
  String get debugLoadDemoSub;

  /// No description provided for @debugDemoLoaded.
  ///
  /// In en, this message translates to:
  /// **'Demo data loaded'**
  String get debugDemoLoaded;

  /// No description provided for @debugWipe.
  ///
  /// In en, this message translates to:
  /// **'Wipe this phone'**
  String get debugWipe;

  /// No description provided for @debugWipeSub.
  ///
  /// In en, this message translates to:
  /// **'Erase the database and settings'**
  String get debugWipeSub;

  /// No description provided for @debugWipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase everything on this phone?'**
  String get debugWipeTitle;

  /// No description provided for @debugWipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Wipe'**
  String get debugWipeConfirm;

  /// No description provided for @debugWiped.
  ///
  /// In en, this message translates to:
  /// **'This phone was wiped'**
  String get debugWiped;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @errCantSecure.
  ///
  /// In en, this message translates to:
  /// **'Nest Mojo : Flat can’t secure data on this phone'**
  String get errCantSecure;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Run your home,\n{em}'**
  String welcomeHeadline(Object em);

  /// No description provided for @welcomeHeadlineEm.
  ///
  /// In en, this message translates to:
  /// **'together.'**
  String get welcomeHeadlineEm;

  /// No description provided for @welcomeSub.
  ///
  /// In en, this message translates to:
  /// **'House help, groceries, chores, meals and spends — shared between the phones in your home.'**
  String get welcomeSub;

  /// No description provided for @welcomeStartLabel.
  ///
  /// In en, this message translates to:
  /// **'How do you want to start?'**
  String get welcomeStartLabel;

  /// No description provided for @welcomeCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a home'**
  String get welcomeCreateTitle;

  /// No description provided for @welcomeCreateBody.
  ///
  /// In en, this message translates to:
  /// **'Set it up for your family. You’ll be the admin and invite the others.'**
  String get welcomeCreateBody;

  /// No description provided for @welcomeJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a home'**
  String get welcomeJoinTitle;

  /// No description provided for @welcomeJoinBody.
  ///
  /// In en, this message translates to:
  /// **'Someone at home already uses Nest Mojo : Flat. Scan their QR code or type their phrase.'**
  String get welcomeJoinBody;

  /// No description provided for @welcomeHint.
  ///
  /// In en, this message translates to:
  /// **'Only one person creates the home — everyone else joins it.'**
  String get welcomeHint;

  /// No description provided for @welcomeRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get welcomeRestore;

  /// No description provided for @welcomeFine.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud. Your home’s data stays on your family’s phones and syncs directly between them.'**
  String get welcomeFine;

  /// No description provided for @welcomeCreditLine1.
  ///
  /// In en, this message translates to:
  /// **'Made at home, for homes.'**
  String get welcomeCreditLine1;

  /// No description provided for @welcomeCreditLine2.
  ///
  /// In en, this message translates to:
  /// **'with {heart} by Nandini Srinivasan & Karthik Venkatesh'**
  String welcomeCreditLine2(Object heart);

  /// No description provided for @welcomeCreditA11y.
  ///
  /// In en, this message translates to:
  /// **'Made at home, for homes, with love by Nandini Srinivasan and Karthik Venkatesh'**
  String get welcomeCreditA11y;

  /// No description provided for @createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your home'**
  String get createTitle;

  /// No description provided for @createSub.
  ///
  /// In en, this message translates to:
  /// **'You’ll be its admin. Others join from their phones with a QR code or a short phrase.'**
  String get createSub;

  /// No description provided for @createYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get createYourName;

  /// No description provided for @createYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Anand Kumar'**
  String get createYourNameHint;

  /// No description provided for @createHomeName.
  ///
  /// In en, this message translates to:
  /// **'Home name'**
  String get createHomeName;

  /// No description provided for @createHomeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {surname} Home'**
  String createHomeNameHint(Object surname);

  /// No description provided for @createSuggestHome.
  ///
  /// In en, this message translates to:
  /// **'{surname} Home'**
  String createSuggestHome(Object surname);

  /// No description provided for @createSuggestFlat.
  ///
  /// In en, this message translates to:
  /// **'Our flat'**
  String get createSuggestFlat;

  /// No description provided for @createSuggestAmma.
  ///
  /// In en, this message translates to:
  /// **'Amma’s house'**
  String get createSuggestAmma;

  /// No description provided for @createSurnameFallback.
  ///
  /// In en, this message translates to:
  /// **'Our'**
  String get createSurnameFallback;

  /// No description provided for @createSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get createSuggestionsLabel;

  /// No description provided for @createHomeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Home ID'**
  String get createHomeIdLabel;

  /// No description provided for @createHomeIdNote.
  ///
  /// In en, this message translates to:
  /// **'Made on this phone · unique to your home'**
  String get createHomeIdNote;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create home'**
  String get createButton;

  /// No description provided for @createErrName.
  ///
  /// In en, this message translates to:
  /// **'Add your name.'**
  String get createErrName;

  /// No description provided for @createErrHome.
  ///
  /// In en, this message translates to:
  /// **'Give your home a name.'**
  String get createErrHome;

  /// No description provided for @todayGreetingLate.
  ///
  /// In en, this message translates to:
  /// **'Still up'**
  String get todayGreetingLate;

  /// No description provided for @todayGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get todayGreetingMorning;

  /// No description provided for @todayGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get todayGreetingAfternoon;

  /// No description provided for @todayGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get todayGreetingEvening;

  /// No description provided for @todayEyebrow.
  ///
  /// In en, this message translates to:
  /// **'{home} · {date}'**
  String todayEyebrow(Object home, Object date);

  /// No description provided for @todayHeadlineAllSet.
  ///
  /// In en, this message translates to:
  /// **'The house is {em} today.'**
  String todayHeadlineAllSet(Object em);

  /// No description provided for @todayAllSetEm.
  ///
  /// In en, this message translates to:
  /// **'all set'**
  String get todayAllSetEm;

  /// No description provided for @debugViewAsMember.
  ///
  /// In en, this message translates to:
  /// **'Viewing as member'**
  String get debugViewAsMember;

  /// No description provided for @debugViewAsMemberSub.
  ///
  /// In en, this message translates to:
  /// **'Hide admin-only controls (UI test only)'**
  String get debugViewAsMemberSub;

  /// No description provided for @debugIsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin on this phone: {value}'**
  String debugIsAdmin(Object value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
