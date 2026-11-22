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

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShortSun;

  /// No description provided for @weekdayLetters.
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get weekdayLetters;

  /// No description provided for @staffDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get staffDaily;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTitle;

  /// No description provided for @staffNotFound.
  ///
  /// In en, this message translates to:
  /// **'This house help isn’t in your home any more.'**
  String get staffNotFound;

  /// No description provided for @staffMarkedIn.
  ///
  /// In en, this message translates to:
  /// **'{name} marked in at {time}'**
  String staffMarkedIn(Object name, Object time);

  /// No description provided for @staffMarkedOut.
  ///
  /// In en, this message translates to:
  /// **'{name} out · {duration} today'**
  String staffMarkedOut(Object name, Object duration);

  /// No description provided for @staffExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected {times}'**
  String staffExpected(Object times);

  /// No description provided for @staffInSince.
  ///
  /// In en, this message translates to:
  /// **'In since {time} · {duration}'**
  String staffInSince(Object time, Object duration);

  /// No description provided for @staffDoneToday.
  ///
  /// In en, this message translates to:
  /// **'{duration} today · out {time}'**
  String staffDoneToday(Object duration, Object time);

  /// No description provided for @staffOnLeaveToday.
  ///
  /// In en, this message translates to:
  /// **'On leave today (informed)'**
  String get staffOnLeaveToday;

  /// No description provided for @staffDayOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get staffDayOff;

  /// No description provided for @staffMarkIn.
  ///
  /// In en, this message translates to:
  /// **'Mark in'**
  String get staffMarkIn;

  /// No description provided for @staffMarkOut.
  ///
  /// In en, this message translates to:
  /// **'Mark out'**
  String get staffMarkOut;

  /// No description provided for @staffVisitButton.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get staffVisitButton;

  /// No description provided for @staffChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get staffChange;

  /// No description provided for @staffStartAnother.
  ///
  /// In en, this message translates to:
  /// **'Start another visit for {name}'**
  String staffStartAnother(Object name);

  /// No description provided for @staffHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help at home'**
  String get staffHelpTitle;

  /// No description provided for @staffHelpSub.
  ///
  /// In en, this message translates to:
  /// **'Tap a name for attendance & pay'**
  String get staffHelpSub;

  /// No description provided for @staffNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No house help added yet.'**
  String get staffNoneYet;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get commonFix;

  /// No description provided for @staffAlertNotMarkedOut.
  ///
  /// In en, this message translates to:
  /// **'{name} wasn’t marked out on {day}'**
  String staffAlertNotMarkedOut(Object name, Object day);

  /// No description provided for @staffAlertTwoOpen.
  ///
  /// In en, this message translates to:
  /// **'{name} has 2 open visits'**
  String staffAlertTwoOpen(Object name);

  /// No description provided for @staffAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add house help'**
  String get staffAddTitle;

  /// No description provided for @staffAddLead.
  ///
  /// In en, this message translates to:
  /// **'They don’t need the app. Anyone at home marks them in and out; pay is worked out for you.'**
  String get staffAddLead;

  /// No description provided for @staffName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get staffName;

  /// No description provided for @staffAddNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kamala'**
  String get staffAddNameHint;

  /// No description provided for @staffRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffRole;

  /// No description provided for @staffRoleHouseHelp.
  ///
  /// In en, this message translates to:
  /// **'House help'**
  String get staffRoleHouseHelp;

  /// No description provided for @staffRoleCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get staffRoleCook;

  /// No description provided for @staffRoleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get staffRoleDriver;

  /// No description provided for @staffRoleNanny.
  ///
  /// In en, this message translates to:
  /// **'Nanny'**
  String get staffRoleNanny;

  /// No description provided for @staffRoleGardener.
  ///
  /// In en, this message translates to:
  /// **'Gardener'**
  String get staffRoleGardener;

  /// No description provided for @staffPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get staffPay;

  /// No description provided for @staffPayPerHour.
  ///
  /// In en, this message translates to:
  /// **'Per hour'**
  String get staffPayPerHour;

  /// No description provided for @staffPayPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Per month'**
  String get staffPayPerMonth;

  /// No description provided for @staffAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get staffAmount;

  /// No description provided for @staffAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 6000'**
  String get staffAmountHint;

  /// No description provided for @staffUsuallyAt.
  ///
  /// In en, this message translates to:
  /// **'Usually comes at'**
  String get staffUsuallyAt;

  /// No description provided for @staffMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile (optional, for WhatsApp)'**
  String get staffMobile;

  /// No description provided for @staffPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the number — 10 digits starting with 6, 7, 8 or 9.'**
  String get staffPhoneInvalid;

  /// No description provided for @staffAddInfo.
  ///
  /// In en, this message translates to:
  /// **'Works Mon–Sat by default; change days and pay rules later on their page.'**
  String get staffAddInfo;

  /// No description provided for @staffAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added · mark them in from Today'**
  String staffAdded(Object name);

  /// No description provided for @staffIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get staffIn;

  /// No description provided for @staffOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get staffOut;

  /// No description provided for @staffErrNoIn.
  ///
  /// In en, this message translates to:
  /// **'Add an in-time, or close this sheet.'**
  String get staffErrNoIn;

  /// No description provided for @staffErrOutBeforeIn.
  ///
  /// In en, this message translates to:
  /// **'Out time has to be after in time.'**
  String get staffErrOutBeforeIn;

  /// No description provided for @staffErrTooLong.
  ///
  /// In en, this message translates to:
  /// **'A visit can’t be longer than 16 hours.'**
  String get staffErrTooLong;

  /// No description provided for @staffOverlap.
  ///
  /// In en, this message translates to:
  /// **'This overlaps another visit at {time}.'**
  String staffOverlap(Object time);

  /// No description provided for @staffOnlyAdminsOlder.
  ///
  /// In en, this message translates to:
  /// **'Only admins can change older visits.'**
  String get staffOnlyAdminsOlder;

  /// No description provided for @staffVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {day}'**
  String staffVisitTitle(Object name, Object day);

  /// No description provided for @staffVisitLeadSome.
  ///
  /// In en, this message translates to:
  /// **'Tapped late or forgot? Fix the time — salary recalculates from this.'**
  String get staffVisitLeadSome;

  /// No description provided for @staffVisitLeadNone.
  ///
  /// In en, this message translates to:
  /// **'No visit recorded. Add one, or mark an informed leave so it isn’t counted as absent.'**
  String get staffVisitLeadNone;

  /// No description provided for @staffNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get staffNow;

  /// No description provided for @staffAddVisit.
  ///
  /// In en, this message translates to:
  /// **'Add visit'**
  String get staffAddVisit;

  /// No description provided for @staffEditVisit.
  ///
  /// In en, this message translates to:
  /// **'Edit visit'**
  String get staffEditVisit;

  /// No description provided for @staffRemoveVisit.
  ///
  /// In en, this message translates to:
  /// **'Remove visit'**
  String get staffRemoveVisit;

  /// No description provided for @staffSettledNotice.
  ///
  /// In en, this message translates to:
  /// **'{month} is settled — changes will show as a difference to pay'**
  String staffSettledNotice(Object month);

  /// No description provided for @staffVisitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Visit updated · salary recalculated'**
  String get staffVisitUpdated;

  /// No description provided for @staffVisitRemoved.
  ///
  /// In en, this message translates to:
  /// **'Visit removed'**
  String get staffVisitRemoved;

  /// No description provided for @staffInformedLeave.
  ///
  /// In en, this message translates to:
  /// **'Informed leave'**
  String get staffInformedLeave;

  /// No description provided for @staffUndoLeave.
  ///
  /// In en, this message translates to:
  /// **'Undo leave'**
  String get staffUndoLeave;

  /// No description provided for @staffLeaveMarked.
  ///
  /// In en, this message translates to:
  /// **'{day} marked as informed leave'**
  String staffLeaveMarked(Object day);

  /// No description provided for @staffLeaveRemoved.
  ///
  /// In en, this message translates to:
  /// **'Leave removed'**
  String get staffLeaveRemoved;

  /// No description provided for @staffCall.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String staffCall(Object name);

  /// No description provided for @staffWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp {name}'**
  String staffWhatsApp(Object name);

  /// No description provided for @staffEditDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get staffEditDetails;

  /// No description provided for @staffRoleWindow.
  ///
  /// In en, this message translates to:
  /// **'{role} · {window}'**
  String staffRoleWindow(Object role, Object window);

  /// No description provided for @staffPayHourlyLine.
  ///
  /// In en, this message translates to:
  /// **'{rate}/hour'**
  String staffPayHourlyLine(Object rate);

  /// No description provided for @staffPayMonthlyLine.
  ///
  /// In en, this message translates to:
  /// **'{amount}/month'**
  String staffPayMonthlyLine(Object amount);

  /// No description provided for @staffFormerTag.
  ///
  /// In en, this message translates to:
  /// **'Former house help'**
  String get staffFormerTag;

  /// No description provided for @staffUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI ID (optional)'**
  String get staffUpi;

  /// No description provided for @staffWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Work days'**
  String get staffWorkDays;

  /// No description provided for @staffAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add a second time'**
  String get staffAddTime;

  /// No description provided for @staffDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Details saved'**
  String get staffDetailsSaved;

  /// No description provided for @staffMonthAttendance.
  ///
  /// In en, this message translates to:
  /// **'{month} attendance'**
  String staffMonthAttendance(Object month);

  /// No description provided for @staffPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get staffPrevMonth;

  /// No description provided for @staffNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get staffNextMonth;

  /// No description provided for @staffCellWorked.
  ///
  /// In en, this message translates to:
  /// **'{day}: worked {duration}'**
  String staffCellWorked(Object day, Object duration);

  /// No description provided for @staffCellAbsent.
  ///
  /// In en, this message translates to:
  /// **'{day}: absent'**
  String staffCellAbsent(Object day);

  /// No description provided for @staffCellLeave.
  ///
  /// In en, this message translates to:
  /// **'{day}: informed leave'**
  String staffCellLeave(Object day);

  /// No description provided for @staffCellOff.
  ///
  /// In en, this message translates to:
  /// **'{day}: day off'**
  String staffCellOff(Object day);

  /// No description provided for @staffCellUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{day}: upcoming'**
  String staffCellUpcoming(Object day);

  /// No description provided for @staffCellNotMarked.
  ///
  /// In en, this message translates to:
  /// **'{day}: not marked yet'**
  String staffCellNotMarked(Object day);

  /// No description provided for @staffCellBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'{day}: before start'**
  String staffCellBeforeStart(Object day);

  /// No description provided for @staffLegendWorked.
  ///
  /// In en, this message translates to:
  /// **'Worked (stronger = longer)'**
  String get staffLegendWorked;

  /// No description provided for @staffLegendAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get staffLegendAbsent;

  /// No description provided for @staffLegendLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get staffLegendLeave;

  /// No description provided for @staffStatPresent.
  ///
  /// In en, this message translates to:
  /// **'Days present'**
  String get staffStatPresent;

  /// No description provided for @staffStatAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get staffStatAbsent;

  /// No description provided for @staffStatHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get staffStatHours;

  /// No description provided for @staffVisitLog.
  ///
  /// In en, this message translates to:
  /// **'Visit log'**
  String get staffVisitLog;

  /// No description provided for @staffVisitLogHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to fix a time'**
  String get staffVisitLogHint;

  /// No description provided for @staffSalaryButton.
  ///
  /// In en, this message translates to:
  /// **'{month} salary'**
  String staffSalaryButton(Object month);

  /// No description provided for @staffRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from home'**
  String staffRemoveButton(Object name);

  /// No description provided for @staffRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String staffRemoveTitle(Object name);

  /// No description provided for @staffRemoveLead.
  ///
  /// In en, this message translates to:
  /// **'They disappear from Today and attendance. Salary already paid stays in Money.'**
  String get staffRemoveLead;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @staffRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String staffRemoved(Object name);

  /// No description provided for @staffRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get staffRestore;

  /// No description provided for @staffRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored'**
  String staffRestored(Object name);

  /// No description provided for @staffFormerCount.
  ///
  /// In en, this message translates to:
  /// **'Former house help ({count})'**
  String staffFormerCount(int count);
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
