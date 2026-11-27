// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'इल्लम';

  @override
  String get tabToday => 'आज';

  @override
  String get tabLists => 'सूचियाँ';

  @override
  String get tabTasks => 'काम';

  @override
  String get tabMeals => 'भोजन';

  @override
  String get tabMoney => 'पैसे';

  @override
  String get commonUndo => 'वापस लें';

  @override
  String get commonBack => 'पीछे';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonDecrease => 'कम करें';

  @override
  String get commonIncrease => 'बढ़ाएँ';

  @override
  String commonArrivesIn(Object phase) {
    return '$phase में आएगा';
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
  String get dayToday => 'आज';

  @override
  String get dayTomorrow => 'कल';

  @override
  String get dayYesterday => 'बीता कल';

  @override
  String undoConflict(Object name) {
    return 'वापस नहीं हो सका — $name ने इसे बदल दिया।';
  }

  @override
  String get undoConflictYou => 'वापस नहीं हो सका — आपने इसे बदल दिया।';

  @override
  String get undoConflictSomeone =>
      'वापस नहीं हो सका — किसी और ने इसे बदल दिया।';

  @override
  String get debugDataLab => 'Data lab';

  @override
  String get debugDataLabSub => 'Notes, undo and the op log';

  @override
  String get labAddNote => 'नोट जोड़ें';

  @override
  String get labNoteHint => 'नोट का शीर्षक';

  @override
  String get labNoteAdded => 'नोट जोड़ा गया';

  @override
  String get labNoteRenamed => 'नोट का नाम बदला गया';

  @override
  String get labNoteDeleted => 'नोट हटाया गया';

  @override
  String get labPinned => 'पिन किया गया';

  @override
  String get labUnpinned => 'अनपिन किया गया';

  @override
  String labTaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टैप',
      one: '1 टैप',
    );
    return '$_temp0';
  }

  @override
  String get labRecent => 'हाल के बदलाव';

  @override
  String get labOpLog => 'ऑप लॉग';

  @override
  String labOpsTotal(int count) {
    return '$count ऑप्स';
  }

  @override
  String get labPin => 'पिन करें';

  @override
  String get labEdit => 'संपादित करें';

  @override
  String get labDelete => 'हटाएँ';

  @override
  String get commonSave => 'सहेजें';

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
  String get commonCancel => 'रद्द करें';

  @override
  String get errCantSecure =>
      'इल्लम इस फ़ोन पर डेटा सुरक्षित नहीं कर पा रहा है';

  @override
  String welcomeHeadline(Object em) {
    return 'अपना घर संभालें,\n$em';
  }

  @override
  String get welcomeHeadlineEm => 'साथ मिलकर।';

  @override
  String get welcomeSub =>
      'घरेलू सहायक, किराना, घर के काम, भोजन और खर्च — घर के सभी फ़ोनों में एक साथ साझा।';

  @override
  String get welcomeStartLabel => 'आप कैसे शुरू करना चाहते हैं?';

  @override
  String get welcomeCreateTitle => 'नया घर बनाएँ';

  @override
  String get welcomeCreateBody =>
      'अपने परिवार के लिए सेटअप करें। आप एडमिन होंगे और बाक़ी लोगों को आमंत्रित करेंगे।';

  @override
  String get welcomeJoinTitle => 'घर से जुड़ें';

  @override
  String get welcomeJoinBody =>
      'घर में कोई पहले से इल्लम इस्तेमाल कर रहा है। उनका QR कोड स्कैन करें या उनका वाक्यांश लिखें।';

  @override
  String get welcomeHint =>
      'केवल एक व्यक्ति घर बनाता है — बाक़ी सभी उससे जुड़ते हैं।';

  @override
  String get welcomeRestore => 'बैकअप से रीस्टोर करें';

  @override
  String get welcomeFine =>
      'न कोई खाता, न कोई क्लाउड। आपके घर का डेटा आपके परिवार के फ़ोनों में ही रहता है और सीधे आपस में सिंक होता है।';

  @override
  String get welcomeCreditLine1 => 'घर में बना, घरों के लिए।';

  @override
  String welcomeCreditLine2(Object heart) {
    return 'नंदिनी श्रीनिवासन और कार्तिक वेंकटेश द्वारा $heart से';
  }

  @override
  String get welcomeCreditA11y =>
      'घर में बना, घरों के लिए, नंदिनी श्रीनिवासन और कार्तिक वेंकटेश द्वारा प्यार से';

  @override
  String get createTitle => 'अपना घर बनाएँ';

  @override
  String get createSub =>
      'आप इसके एडमिन होंगे। बाक़ी लोग अपने फ़ोन से QR कोड या छोटे वाक्यांश से जुड़ेंगे।';

  @override
  String get createYourName => 'आपका नाम';

  @override
  String get createYourNameHint => 'जैसे, आनंद कुमार';

  @override
  String get createHomeName => 'घर का नाम';

  @override
  String createHomeNameHint(Object surname) {
    return 'जैसे, $surname निवास';
  }

  @override
  String createSuggestHome(Object surname) {
    return '$surname निवास';
  }

  @override
  String get createSuggestFlat => 'हमारा फ़्लैट';

  @override
  String get createSuggestAmma => 'अम्मा का घर';

  @override
  String get createSurnameFallback => 'हमारा';

  @override
  String get createSuggestionsLabel => 'सुझाव';

  @override
  String get createHomeIdLabel => 'होम ID';

  @override
  String get createHomeIdNote => 'इसी फ़ोन पर बना · सिर्फ़ आपके घर के लिए';

  @override
  String get createButton => 'घर बनाएँ';

  @override
  String get createErrName => 'अपना नाम लिखें।';

  @override
  String get createErrHome => 'अपने घर को एक नाम दें।';

  @override
  String get todayGreetingLate => 'अभी भी जाग रहे हैं';

  @override
  String get todayGreetingMorning => 'सुप्रभात';

  @override
  String get todayGreetingAfternoon => 'शुभ दोपहर';

  @override
  String get todayGreetingEvening => 'शुभ संध्या';

  @override
  String todayEyebrow(Object home, Object date) {
    return '$home · $date';
  }

  @override
  String todayHeadlineAllSet(Object em) {
    return 'आज घर $em है।';
  }

  @override
  String get todayAllSetEm => 'बिलकुल तैयार';

  @override
  String get debugViewAsMember => 'Viewing as member';

  @override
  String get debugViewAsMemberSub => 'Hide admin-only controls (UI test only)';

  @override
  String debugIsAdmin(Object value) {
    return 'Admin on this phone: $value';
  }

  @override
  String get weekdayShortMon => 'सोम';

  @override
  String get weekdayShortTue => 'मंगल';

  @override
  String get weekdayShortWed => 'बुध';

  @override
  String get weekdayShortThu => 'गुरु';

  @override
  String get weekdayShortFri => 'शुक्र';

  @override
  String get weekdayShortSat => 'शनि';

  @override
  String get weekdayShortSun => 'रवि';

  @override
  String get weekdayLetters => 'सो,मं,बु,गु,शु,श,र';

  @override
  String get staffDaily => 'रोज़ाना';

  @override
  String get staffTitle => 'स्टाफ़';

  @override
  String get staffNotFound => 'यह घरेलू सहायक अब आपके घर में नहीं हैं।';

  @override
  String staffMarkedIn(Object name, Object time) {
    return '$name का आना $time पर दर्ज हुआ';
  }

  @override
  String staffMarkedOut(Object name, Object duration) {
    return '$name गए · आज $duration';
  }

  @override
  String staffExpected(Object times) {
    return 'तय समय $times';
  }

  @override
  String staffInSince(Object time, Object duration) {
    return '$time से काम पर · $duration';
  }

  @override
  String staffDoneToday(Object duration, Object time) {
    return 'आज $duration · $time पर गए';
  }

  @override
  String get staffOnLeaveToday => 'आज छुट्टी पर (सूचित)';

  @override
  String get staffDayOff => 'छुट्टी का दिन';

  @override
  String get staffMarkIn => 'आना दर्ज करें';

  @override
  String get staffMarkOut => 'जाना दर्ज करें';

  @override
  String get staffVisitButton => 'विज़िट';

  @override
  String get staffChange => 'बदलें';

  @override
  String staffStartAnother(Object name) {
    return '$name की एक और विज़िट शुरू करें';
  }

  @override
  String get staffHelpTitle => 'घरेलू सहायक';

  @override
  String get staffHelpSub => 'हाज़िरी और वेतन के लिए नाम पर टैप करें';

  @override
  String get staffNoneYet => 'अभी कोई घरेलू सहायक नहीं जोड़ा गया है।';

  @override
  String get commonAdd => 'जोड़ें';

  @override
  String get commonFix => 'सुधारें';

  @override
  String staffAlertNotMarkedOut(Object name, Object day) {
    return '$day को $name का जाना दर्ज नहीं हुआ';
  }

  @override
  String staffAlertTwoOpen(Object name) {
    return '$name की 2 अधूरी विज़िट हैं';
  }

  @override
  String get staffAddTitle => 'घरेलू सहायक जोड़ें';

  @override
  String get staffAddLead =>
      'उन्हें ऐप की ज़रूरत नहीं है। घर का कोई भी सदस्य उनका आना-जाना दर्ज कर सकता है; वेतन अपने आप निकल आएगा।';

  @override
  String get staffName => 'नाम';

  @override
  String get staffAddNameHint => 'जैसे, कमला';

  @override
  String get staffRole => 'भूमिका';

  @override
  String get staffRoleHouseHelp => 'घरेलू सहायक';

  @override
  String get staffRoleCook => 'रसोइया';

  @override
  String get staffRoleDriver => 'ड्राइवर';

  @override
  String get staffRoleNanny => 'आया';

  @override
  String get staffRoleGardener => 'माली';

  @override
  String get staffPay => 'वेतन';

  @override
  String get staffPayPerHour => 'प्रति घंटा';

  @override
  String get staffPayPerMonth => 'प्रति माह';

  @override
  String get staffAmount => 'राशि (₹)';

  @override
  String get staffAmountHint => 'जैसे, 6000';

  @override
  String get staffUsuallyAt => 'आमतौर पर आने का समय';

  @override
  String get staffMobile => 'मोबाइल (वैकल्पिक, WhatsApp के लिए)';

  @override
  String get staffPhoneInvalid =>
      'नंबर जाँचें — 6, 7, 8 या 9 से शुरू होने वाले 10 अंक।';

  @override
  String get staffAddInfo =>
      'डिफ़ॉल्ट रूप से सोम–शनि काम; दिन और वेतन के नियम बाद में उनके पेज से बदल सकते हैं।';

  @override
  String staffAdded(Object name) {
    return '$name जुड़ गए · \'आज\' से आना दर्ज करें';
  }

  @override
  String get staffIn => 'आना';

  @override
  String get staffOut => 'जाना';

  @override
  String get staffErrNoIn => 'आने का समय डालें, या यह शीट बंद करें।';

  @override
  String get staffErrOutBeforeIn =>
      'जाने का समय आने के समय के बाद का होना चाहिए।';

  @override
  String get staffErrTooLong =>
      'एक विज़िट 16 घंटे से ज़्यादा लंबी नहीं हो सकती।';

  @override
  String staffOverlap(Object time) {
    return 'यह $time की दूसरी विज़िट के समय से टकरा रही है।';
  }

  @override
  String get staffOnlyAdminsOlder =>
      'पुरानी विज़िट केवल एडमिन ही बदल सकते हैं।';

  @override
  String staffVisitTitle(Object name, Object day) {
    return '$name · $day';
  }

  @override
  String get staffVisitLeadSome =>
      'देर से टैप किया या भूल गए? समय सुधारें — वेतन इसी से फिर से गिन लिया जाएगा।';

  @override
  String get staffVisitLeadNone =>
      'कोई विज़िट दर्ज नहीं है। एक जोड़ें, या सूचित छुट्टी दर्ज करें ताकि इसे अनुपस्थित न गिना जाए।';

  @override
  String get staffNow => 'अभी';

  @override
  String get staffAddVisit => 'विज़िट जोड़ें';

  @override
  String get staffEditVisit => 'विज़िट बदलें';

  @override
  String get staffRemoveVisit => 'विज़िट हटाएँ';

  @override
  String staffSettledNotice(Object month) {
    return '$month का हिसाब हो चुका है — बदलाव देय अंतर के रूप में दिखेंगे';
  }

  @override
  String get staffVisitUpdated => 'विज़िट अपडेट हुई · वेतन फिर से गिना गया';

  @override
  String get staffVisitRemoved => 'विज़िट हटाई गई';

  @override
  String get staffInformedLeave => 'सूचित छुट्टी';

  @override
  String get staffUndoLeave => 'छुट्टी वापस लें';

  @override
  String staffLeaveMarked(Object day) {
    return '$day सूचित छुट्टी के रूप में दर्ज';
  }

  @override
  String get staffLeaveRemoved => 'छुट्टी हटाई गई';

  @override
  String staffCall(Object name) {
    return '$name को कॉल करें';
  }

  @override
  String staffWhatsApp(Object name) {
    return '$name को WhatsApp करें';
  }

  @override
  String get staffEditDetails => 'विवरण बदलें';

  @override
  String staffRoleWindow(Object role, Object window) {
    return '$role · $window';
  }

  @override
  String staffPayHourlyLine(Object rate) {
    return '$rate/घंटा';
  }

  @override
  String staffPayMonthlyLine(Object amount) {
    return '$amount/माह';
  }

  @override
  String get staffFormerTag => 'पूर्व घरेलू सहायक';

  @override
  String get staffUpi => 'UPI ID (वैकल्पिक)';

  @override
  String get staffWorkDays => 'काम के दिन';

  @override
  String get staffAddTime => 'दूसरा समय जोड़ें';

  @override
  String get staffDetailsSaved => 'विवरण सहेजा गया';

  @override
  String staffMonthAttendance(Object month) {
    return '$month की हाज़िरी';
  }

  @override
  String get staffPrevMonth => 'पिछला महीना';

  @override
  String get staffNextMonth => 'अगला महीना';

  @override
  String staffCellWorked(Object day, Object duration) {
    return '$day: $duration काम किया';
  }

  @override
  String staffCellAbsent(Object day) {
    return '$day: अनुपस्थित';
  }

  @override
  String staffCellLeave(Object day) {
    return '$day: सूचित छुट्टी';
  }

  @override
  String staffCellOff(Object day) {
    return '$day: छुट्टी का दिन';
  }

  @override
  String staffCellUpcoming(Object day) {
    return '$day: आने वाला दिन';
  }

  @override
  String staffCellNotMarked(Object day) {
    return '$day: अभी दर्ज नहीं';
  }

  @override
  String staffCellBeforeStart(Object day) {
    return '$day: जुड़ने से पहले';
  }

  @override
  String get staffLegendWorked => 'काम किया (गहरा = ज़्यादा देर)';

  @override
  String get staffLegendAbsent => 'अनुपस्थित';

  @override
  String get staffLegendLeave => 'छुट्टी';

  @override
  String get staffStatPresent => 'उपस्थित दिन';

  @override
  String get staffStatAbsent => 'अनुपस्थित';

  @override
  String get staffStatHours => 'घंटे';

  @override
  String get staffVisitLog => 'विज़िट लॉग';

  @override
  String get staffVisitLogHint => 'समय सुधारने के लिए टैप करें';

  @override
  String staffSalaryButton(Object month) {
    return '$month का वेतन';
  }

  @override
  String staffRemoveButton(Object name) {
    return '$name को घर से हटाएँ';
  }

  @override
  String staffRemoveTitle(Object name) {
    return '$name को हटाएँ?';
  }

  @override
  String get staffRemoveLead =>
      'वे \'आज\' और हाज़िरी से हट जाएँगे। पहले दिया गया वेतन \'पैसे\' में बना रहेगा।';

  @override
  String get commonRemove => 'हटाएँ';

  @override
  String staffRemoved(Object name) {
    return '$name हटाए गए';
  }

  @override
  String get staffRestore => 'वापस लाएँ';

  @override
  String staffRestored(Object name) {
    return '$name वापस जोड़े गए';
  }

  @override
  String staffFormerCount(int count) {
    return 'पूर्व घरेलू सहायक ($count)';
  }

  @override
  String salaryTitle(Object name) {
    return '$name का वेतन';
  }

  @override
  String salarySubtitleSoFar(Object month, Object day) {
    return '1 – $day $month · अब तक';
  }

  @override
  String salarySubtitleProjected(Object month, Object day) {
    return '1 – $day $month · अनुमानित';
  }

  @override
  String salarySubtitlePast(Object month, Object day) {
    return '1 – $day $month';
  }

  @override
  String get salaryFootnote =>
      'हर अंक विज़िट लॉग से जुड़ा है। वहाँ गलत समय सुधारते ही यहाँ तुरंत अपडेट हो जाता है।';

  @override
  String salaryNotWorking(Object month) {
    return '$month में कार्यरत नहीं';
  }

  @override
  String get salaryNoRules => 'अभी कोई वेतन नियम नहीं';

  @override
  String get salaryNoRulesBody =>
      'कितना भुगतान करना है यह देखने के लिए प्रति घंटा दर या मासिक वेतन तय करें।';

  @override
  String get salarySetRules => 'वेतन नियम तय करें';

  @override
  String get salaryEyebrowPayable => 'देय';

  @override
  String get salaryEyebrowPaid => 'चुकाया गया';

  @override
  String salaryDaysLine(Object present, Object absent, Object leave) {
    return '$present दिन उपस्थित · $absent अनुपस्थित · $leave छुट्टी';
  }

  @override
  String salaryCarryPreview(Object amount, Object month) {
    return '₹0 देय · $amount $month में आगे जाएँगे';
  }

  @override
  String get salaryHoursWorked => 'काम के घंटे';

  @override
  String salaryHoursDetail(
    Object billed,
    Object rate,
    Object visits,
    Object actual,
    Object rounding,
    Object minimum,
  ) {
    return 'बिल $billed × $rate/घंटा · $visits विज़िट · असल $actual। हर विज़िट $rounding तक राउंड$minimum';
  }

  @override
  String salaryRoundMinutes(Object n) {
    return '$n मिनट';
  }

  @override
  String get salaryRoundTheMinute => 'सटीक मिनट';

  @override
  String salaryMinimumPart(Object hours) {
    return ', कम से कम $hours घंटे';
  }

  @override
  String get salaryMonthlyLine => 'मासिक वेतन';

  @override
  String salaryMonthlyDetail(Object workDays, Object perDay) {
    return '$workDays कार्य दिवस · $perDay/दिन';
  }

  @override
  String get salaryLeavesLine => 'छुट्टियाँ';

  @override
  String salaryLeavesDetail(Object taken, Object paid, Object unpaid) {
    return '$taken लीं · $paid सवेतन · $unpaid अवैतनिक';
  }

  @override
  String get salaryExtraDetail => 'अतिरिक्त काम';

  @override
  String get salaryAdvanceLine => 'एडवांस लिया';

  @override
  String get salaryAdvanceDetail => 'इस महीने काटा गया';

  @override
  String get salaryDeductionDetail => 'कटौती';

  @override
  String get salaryToPay => 'देय राशि';

  @override
  String salaryChipRate(Object rate) {
    return '$rate/घंटा';
  }

  @override
  String salaryChipMonthly(Object amount) {
    return '$amount/माह';
  }

  @override
  String salaryChipRound(Object n) {
    return 'राउंड $n मि';
  }

  @override
  String get salaryChipExact => 'सटीक मिनट';

  @override
  String salaryChipPaidLeaves(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n सवेतन छुट्टियाँ',
      one: '1 सवेतन छुट्टी',
    );
    return '$_temp0';
  }

  @override
  String get salaryEditRules => 'वेतन नियम बदलें';

  @override
  String get salaryAdminsSetRules => 'वेतन नियम एडमिन तय करते हैं';

  @override
  String get salaryPrevMonth => 'पिछला महीना';

  @override
  String get salaryNextMonth => 'अगला महीना';

  @override
  String salaryMarkPaidButton(Object amount) {
    return '$amount भुगतान दर्ज करें';
  }

  @override
  String salaryCloseAtZero(Object month) {
    return '$month को ₹0 पर बंद करें';
  }

  @override
  String salaryClosedSnack(Object month) {
    return '$month ₹0 पर बंद हुआ';
  }

  @override
  String salaryCarryNote(Object month) {
    return '$month से आगे लाया गया';
  }

  @override
  String salaryMemberNote(Object names) {
    return 'वेतन केवल एडमिन ही देते हैं। $names से कहें — भुगतान होते ही यहाँ दिखेगा।';
  }

  @override
  String get salaryYou => 'आप';

  @override
  String salaryNamesOr(Object first, Object second) {
    return '$first या $second';
  }

  @override
  String salaryPaidTag(Object amount, Object date, Object method) {
    return '$date को $amount का भुगतान · $method';
  }

  @override
  String salaryClosedTag(Object date) {
    return '$date को ₹0 पर बंद';
  }

  @override
  String get salaryUndoPayment => 'भुगतान वापस लें';

  @override
  String get salaryUndoTitle => 'भुगतान वापस लें?';

  @override
  String salaryUndoLead(Object amount, Object month) {
    return '$amount का वेतन खर्च हट जाएगा और $month का भुगतान फिर से किया जा सकेगा।';
  }

  @override
  String get salaryUndoneSnack => 'भुगतान वापस लिया गया';

  @override
  String get salaryMethodUpi => 'UPI';

  @override
  String get salaryMethodCash => 'नकद';

  @override
  String get salaryMethodBank => 'बैंक';

  @override
  String salaryDuplicateAlert(
    Object name,
    Object month,
    Object a,
    Object x,
    Object b,
    Object y,
  ) {
    return '$name का $month का वेतन दो बार भुगतान दर्ज हुआ ($x द्वारा $a, $y द्वारा $b)। पहला रखा गया है — जाँच लें कि दो बार भुगतान तो नहीं हुआ।';
  }

  @override
  String get salaryUndoSecond => 'दूसरा भुगतान वापस लें';

  @override
  String salaryDifferenceAlert(Object x, Object y, Object z) {
    return 'नई गणना $x — निपटारा $y पर हुआ। अंतर $z';
  }

  @override
  String salaryAddToMonth(Object month) {
    return '$month में जोड़ें';
  }

  @override
  String salaryDifferenceNote(Object month) {
    return '$month का अंतर';
  }

  @override
  String salaryDifferenceSnack(Object month) {
    return 'अंतर $month में जोड़ा गया';
  }

  @override
  String salarySharePaySlip(Object name) {
    return '$name के साथ वेतन पर्ची साझा करें';
  }

  @override
  String salaryRulesTitle(Object name) {
    return '$name के वेतन नियम';
  }

  @override
  String get salaryRulesLead =>
      'एक बार तय करें, हर महीने लागू होगा। वेतन पर्ची पर दिखता है ताकि कोई उलझन न रहे।';

  @override
  String get salaryPayType => 'वेतन प्रकार';

  @override
  String get salaryHourly => 'प्रति घंटा';

  @override
  String get salaryMonthly => 'मासिक';

  @override
  String get salaryRatePerHour => 'प्रति घंटा दर (₹)';

  @override
  String get salaryRoundTo => 'हर विज़िट राउंड करें';

  @override
  String get salaryRoundExactMinute => 'सटीक मिनट';

  @override
  String get salaryRound15 => '15 मिनट';

  @override
  String get salaryRound30 => '30 मिनट';

  @override
  String get salaryMinimum => 'प्रति विज़िट न्यूनतम';

  @override
  String get salaryMinNone => 'कोई नहीं';

  @override
  String get salaryMin1 => '1 घंटा';

  @override
  String get salaryMin2 => '2 घंटे';

  @override
  String get salaryMonthlyAmount => 'मासिक वेतन (₹)';

  @override
  String get salaryPaidLeaves => 'हर महीने सवेतन छुट्टियाँ';

  @override
  String get salaryWorkDays => 'काम के दिन';

  @override
  String get salaryDayMon => 'सोम';

  @override
  String get salaryDayTue => 'मंगल';

  @override
  String get salaryDayWed => 'बुध';

  @override
  String get salaryDayThu => 'गुरु';

  @override
  String get salaryDayFri => 'शुक्र';

  @override
  String get salaryDaySat => 'शनि';

  @override
  String get salaryDaySun => 'रवि';

  @override
  String get salaryApplyFrom => 'लागू करें';

  @override
  String get salaryThisMonth => 'इस महीने से';

  @override
  String get salaryNextMonthChip => 'अगले महीने से';

  @override
  String get salarySaveRules => 'नियम सहेजें';

  @override
  String get salaryRulesSaved => 'वेतन नियम सहेजे गए · वेतन फिर से गिना गया';

  @override
  String get salaryCheckAmount => 'राशि जाँचें';

  @override
  String salaryAdjustmentsFor(Object month) {
    return '$month के समायोजन';
  }

  @override
  String get salaryAddExtra => '+ अतिरिक्त जोड़ें';

  @override
  String get salaryAddAdvance => '+ एडवांस जोड़ें';

  @override
  String get salaryAddDeduction => '+ कटौती जोड़ें';

  @override
  String get salaryAdjNote => 'नोट';

  @override
  String get salaryAdjAmount => 'राशि (₹)';

  @override
  String get salaryAdjSave => 'सहेजें';

  @override
  String get salaryAdjRemove => 'हटाएँ';

  @override
  String get salaryAdjAdded => 'समायोजन जोड़ा गया · वेतन फिर से गिना गया';

  @override
  String get salaryAdjRemoved => 'समायोजन हटाया गया';

  @override
  String salaryAdjLocked(Object month) {
    return '$month का हिसाब हो चुका है — समायोजन लॉक हैं।';
  }

  @override
  String get salaryKindExtra => 'अतिरिक्त';

  @override
  String get salaryKindAdvance => 'एडवांस';

  @override
  String get salaryKindDeduction => 'कटौती';

  @override
  String salaryMarkPaidTitle(Object amount) {
    return '$amount का भुगतान दर्ज करें?';
  }

  @override
  String get salaryPaidWith => 'भुगतान का तरीका';

  @override
  String get salaryMarkPaidConfirm => 'भुगतान दर्ज करें';

  @override
  String salaryPaidSnack(Object amount, Object name) {
    return '$name को $amount का भुगतान · खर्च में जुड़ा';
  }

  @override
  String salaryExpenseMerchant(Object name, Object month) {
    return '$name — $month का वेतन';
  }

  @override
  String salarySlipHeader(Object month, Object name) {
    return '$month का वेतन — $name';
  }

  @override
  String salarySlipDaysHours(Object present, Object billed) {
    return 'दिन: $present · घंटे: $billed';
  }

  @override
  String salarySlipHoursCalc(Object billed, Object rate, Object gross) {
    return '$billed × $rate = $gross';
  }

  @override
  String salarySlipExtra(Object label, Object amount) {
    return '+ $label: $amount';
  }

  @override
  String salarySlipAdvance(Object amount) {
    return '− एडवांस: $amount';
  }

  @override
  String salarySlipDeduction(Object label, Object amount) {
    return '− $label: $amount';
  }

  @override
  String salarySlipSalary(Object amount) {
    return 'वेतन: $amount';
  }

  @override
  String salarySlipLeaves(Object taken, Object paid) {
    return 'छुट्टियाँ: $taken ($paid वेतन-सहित)';
  }

  @override
  String salarySlipTotal(Object amount) {
    return 'कुल: $amount';
  }

  @override
  String get salarySlipTitle => 'वेतन पर्ची';

  @override
  String get salarySlipLead =>
      'साफ़ हिसाब से भरोसा बढ़ता है और “यह हिसाब कैसे लगाया?” जैसी बातें नहीं होतीं।';

  @override
  String get salarySlipSend => 'WhatsApp पर भेजें';

  @override
  String salaryRuleHourlyRounded(Object rate, Object n) {
    return '$rate/घंटा · $n मिनट पर राउंड';
  }

  @override
  String salaryRuleHourlyExact(Object rate) {
    return '$rate/घंटा · सटीक मिनट';
  }

  @override
  String salaryRuleMonthly(Object amount, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n वेतन-सहित छुट्टियाँ',
      one: '1 वेतन-सहित छुट्टी',
    );
    return '$amount/माह · $_temp0';
  }

  @override
  String salaryStaffButton(Object month, Object amount) {
    return '$month वेतन · $amount';
  }

  @override
  String get listsChannelZepto => 'Zepto';

  @override
  String get listsChannelBlinkit => 'Blinkit';

  @override
  String get listsChannelBigbasket => 'BigBasket';

  @override
  String get listsChannelAmazon => 'Amazon';

  @override
  String get listsChannelFlipkart => 'Flipkart';

  @override
  String get listsChannelMeesho => 'Meesho';

  @override
  String get listsChannelOffline => 'ऑफ़लाइन';

  @override
  String get listsEtaZepto => '~10 मिनट';

  @override
  String get listsEtaBlinkit => '~10 मिनट';

  @override
  String get listsEtaBigbasket => 'कल सुबह 7–9 बजे';

  @override
  String get listsEtaAmazon => '1–2 दिन';

  @override
  String get listsEtaFlipkart => '2–3 दिन';

  @override
  String get listsEtaMeesho => '4–6 दिन';

  @override
  String get listsEtaOffline => 'पास की दुकान / D-Mart';

  @override
  String get listsEyebrow => 'खरीदारी';

  @override
  String get listsTitle => 'सूचियाँ';

  @override
  String get listsStoreMode => 'स्टोर मोड';

  @override
  String get listsGrocery => 'किराना';

  @override
  String get listsShopping => 'शॉपिंग';

  @override
  String get listsPlaceholderGrocery => '“दूध 2L”, “प्याज़ 1kg” जोड़ें…';

  @override
  String get listsPlaceholderShopping => '“फ़ोन चार्जर” जोड़ें…';

  @override
  String listsStoreButton(Object store) {
    return '$store से खरीदें। बदलें';
  }

  @override
  String get listsAddTooltip => 'जोड़ें';

  @override
  String get listsHintIdle =>
      'सुझाव: मात्रा अपने आप समझ ली जाती है — “चावल 5kg”।';

  @override
  String listsHint(Object item, Object store, Object usual) {
    return '$item → $store$usual';
  }

  @override
  String listsHintItemQty(Object name, Object qty) {
    return '$name · $qty';
  }

  @override
  String get listsHintUsual => ' (जहाँ से आप अक्सर खरीदते हैं)';

  @override
  String listsAdded(Object name, Object store) {
    return '$name जोड़ा गया → $store';
  }

  @override
  String listsMerged(Object name, Object qty) {
    return '$name पहले से सूची में था — अब $qty';
  }

  @override
  String listsAlready(Object name, Object qty) {
    return '$name पहले से सूची में है ($qty)';
  }

  @override
  String get listsPickerTitle => 'इसे कहाँ से खरीदेंगे?';

  @override
  String get listsPickerLead =>
      'नया सामान यहाँ जाएगा। पहले खरीदा गया सामान अपने आप अपने तय स्टोर में चला जाता है।';

  @override
  String get listsAll => 'सभी';

  @override
  String listsToBuy(int n, Object eta) {
    return '$n खरीदना है · $eta';
  }

  @override
  String get listsOrder => 'ऑर्डर करें';

  @override
  String get listsShop => 'खरीदें';

  @override
  String listsGotSemantics(Object name) {
    return '$name ले लिया';
  }

  @override
  String get listsLess => 'कम';

  @override
  String get listsMore => 'ज़्यादा';

  @override
  String get listsCheckQty => 'मात्रा जांचें';

  @override
  String listsGot(Object name) {
    return '$name ले लिया';
  }

  @override
  String listsAllBought(Object store) {
    return '$store से सब खरीद लिया।';
  }

  @override
  String listsGotFooter(Object names) {
    return 'ले लिया: $names';
  }

  @override
  String get listsClear => 'साफ़ करें';

  @override
  String listsCleared(int n) {
    return '$n साफ़ किए · ‘फिर खरीदें’ में हैं';
  }

  @override
  String listsItemLead(Object qty, Object category, String list) {
    String _temp0 = intl.Intl.selectLogic(list, {
      'grocery': 'किराना',
      'other': 'शॉपिंग',
    });
    return '$qty · $category · $_temp0 सूची में';
  }

  @override
  String get listsName => 'नाम';

  @override
  String get listsQuantity => 'मात्रा';

  @override
  String get listsUnit => 'इकाई';

  @override
  String get listsCategory => 'श्रेणी';

  @override
  String get listsMoveTo => 'यहाँ ले जाएँ';

  @override
  String get listsRemove => 'हटाएँ';

  @override
  String get listsRemoved => 'हटाया गया';

  @override
  String get listsSave => 'सहेजें';

  @override
  String get listsSaved => 'सहेजा गया';

  @override
  String listsMoved(Object name, Object store) {
    return '$name → $store। हम यह याद रखेंगे।';
  }

  @override
  String listsMergeAsk(Object name, Object qty) {
    return '$name ($qty) में मिलाएँ?';
  }

  @override
  String get listsMerge => 'मिलाएँ';

  @override
  String get listsCancel => 'रद्द करें';

  @override
  String get listsBuyAgain => 'फिर खरीदें';

  @override
  String listsBuyAgainChip(Object name) {
    return '+ $name';
  }

  @override
  String get todayReadyToOrder => 'ऑर्डर के लिए तैयार';

  @override
  String get todayListsLink => 'सूचियाँ';

  @override
  String todayPillCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get todayStoreRun => 'स्टोर खरीदारी';

  @override
  String get storeTitle => 'स्टोर मोड';

  @override
  String get storeBack => 'वापस';

  @override
  String storeProgress(int done, int total) {
    return '$total में से $done लिए · स्क्रीन चालू रहेगी';
  }

  @override
  String get storeEmptyTitle => 'ऑफ़लाइन खरीदने को कुछ नहीं';

  @override
  String get storeEmptyBody => 'किसी भी सूची से सामान यहाँ ले आएँ।';

  @override
  String get storeDoneLogBill => 'हो गया · बिल दर्ज करें';

  @override
  String get storeLogTitle => 'यह बिल दर्ज करें';

  @override
  String get storeLogLead =>
      'ऑफ़लाइन खरीदारी भी आपके मासिक खर्च में जुड़ती रहेगी।';

  @override
  String get storeBillAmount => 'बिल की राशि (₹)';

  @override
  String get storeStore => 'स्टोर';

  @override
  String get storeDMart => 'D-Mart';

  @override
  String get storeKirana => 'किराना';

  @override
  String get storeSabzi => 'सब्ज़ी मंडी';

  @override
  String get storeReliance => 'Reliance Fresh';

  @override
  String get storeOther => 'अन्य…';

  @override
  String get storeOtherName => 'स्टोर का नाम';

  @override
  String get storePaidWith => 'भुगतान का तरीका';

  @override
  String get storeCash => 'नकद';

  @override
  String get storeUpi => 'UPI';

  @override
  String get storeCard => 'कार्ड';

  @override
  String get storeSkip => 'छोड़ें';

  @override
  String get storeSave => 'सहेजें';

  @override
  String get storeCheckAmount => 'राशि जांचें';

  @override
  String get storeNameRequired => 'यह कौन-सा स्टोर था?';

  @override
  String storeLogged(Object amount, Object store) {
    return '$store पर $amount दर्ज';
  }

  @override
  String get storeTripDone => 'खरीदारी पूरी · लिया हुआ सामान साफ़ किया';

  @override
  String storeOpenFailed(Object store) {
    return '$store खुल नहीं सका। सूची कॉपी हो गई है — ऐप में पेस्ट करें।';
  }

  @override
  String storeBackFrom(Object store) {
    return '$store से वापस आ गए?';
  }

  @override
  String storeBackLead(Object store) {
    return 'हमने सूची कॉपी करके $store खोला था। इल्लम पर लौटने पर यह दिखता है, ताकि सूची सटीक रहे।';
  }

  @override
  String storeUnitChanged(Object qty) {
    return 'अब $qty — सभी को ऑर्डर हुआ मानने के लिए टिक करें';
  }

  @override
  String get storeNotYet => 'अभी नहीं';

  @override
  String get storeOrderedAll => 'सब ऑर्डर हुए';

  @override
  String storeOrderedN(int n) {
    return '$n ऑर्डर हुए';
  }

  @override
  String storeOrderedNote(Object qty, Object store) {
    return '$store पर $qty ऑर्डर किए';
  }

  @override
  String get storeMarkedOrdered => 'ऑर्डर दर्ज हुआ';

  @override
  String storeOrderedOn(Object store) {
    return '$store पर ऑर्डर हुआ ✓';
  }

  @override
  String get storeHowMuch =>
      'यह कितने का था? अभी जोड़ें ताकि इस महीने का कुल सही रहे।';

  @override
  String get storeAmount => 'राशि (₹)';

  @override
  String get storeCashOnDelivery => 'कैश ऑन डिलीवरी';

  @override
  String get storeAddLater => 'बाद में जोड़ें';

  @override
  String storeOrderAdded(Object amount, Object store) {
    return '$store का $amount ऑर्डर जोड़ा गया';
  }

  @override
  String get tasksYou => 'आप';

  @override
  String get tasksEyebrow => 'घर की देखभाल';

  @override
  String get tasksTitle => 'काम';

  @override
  String get tasksCleaningTab => 'नियमित काम';

  @override
  String get tasksTodosTab => 'टू-डू';

  @override
  String get tasksEveryone => 'सभी';

  @override
  String tasksOverdue(int n) {
    return '$n दिन देर';
  }

  @override
  String get tasksDueToday => 'आज करना है';

  @override
  String get tasksDueTomorrow => 'कल करना है';

  @override
  String tasksInDays(int n) {
    return '$n दिन में';
  }

  @override
  String get tasksFreqDaily => 'रोज़';

  @override
  String get tasksFreqWeekly => 'हर हफ़्ते';

  @override
  String get tasksFreqFortnightly => 'हर 2 हफ़्ते';

  @override
  String get tasksFreqMonthly => 'हर महीने';

  @override
  String get tasksFreqEvery3Months => 'हर 3 महीने';

  @override
  String tasksFreqEveryN(int n) {
    return 'हर $n दिन';
  }

  @override
  String tasksRoutineMeta(Object who, Object room, Object freq) {
    return '$who · $room · $freq';
  }

  @override
  String get tasksFreshness => 'ताज़गी';

  @override
  String get tasksDone => 'हो गया';

  @override
  String tasksMarkDone(Object name) {
    return '$name को पूरा चिह्नित करें';
  }

  @override
  String tasksRoutineDone(Object name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n दिन में',
      one: 'कल',
    );
    return '$name हो गया · अगला $_temp0';
  }

  @override
  String get tasksNoRoutines => 'यहाँ कोई नियमित काम नहीं';

  @override
  String tasksNoRoutinesBody(Object who) {
    return 'ज़िम्मेदारी सौंपें: $who।';
  }

  @override
  String get tasksAnyone => 'कोई भी';

  @override
  String get tasksNewRoutine => 'नया नियमित काम';

  @override
  String get tasksNewRoutineTitle => 'नया नियमित काम';

  @override
  String get tasksRoutineLead =>
      'यह अपने आप दोहराता रहेगा — बार-बार जोड़ने की ज़रूरत नहीं।';

  @override
  String get tasksWhatNeedsDoing => 'क्या काम करना है?';

  @override
  String get tasksRoutinePlaceholder =>
      'जैसे: वॉटर फ़िल्टर जांचना, चिमनी साफ़ करना';

  @override
  String get tasksNameRequired => 'लिखें कि क्या काम करना है।';

  @override
  String get tasksWhere => 'कहाँ';

  @override
  String get tasksRoomKitchen => 'रसोई';

  @override
  String get tasksRoomLiving => 'लिविंग रूम';

  @override
  String get tasksRoomBedrooms => 'बेडरूम';

  @override
  String get tasksRoomBathrooms => 'बाथरूम';

  @override
  String get tasksRoomBalcony => 'बालकनी';

  @override
  String get tasksRoomWhole => 'पूरा घर';

  @override
  String get tasksOther => 'अन्य…';

  @override
  String get tasksRoomName => 'कमरा या जगह';

  @override
  String get tasksHowOften => 'कितनी बार';

  @override
  String get tasksEvery2 => 'हर 2 दिन';

  @override
  String get tasksEvery3 => 'हर 3 दिन';

  @override
  String get tasksCustom => 'कस्टम…';

  @override
  String get tasksEveryHowMany => 'हर कितने दिन में?';

  @override
  String get tasksDaysRange => '1 से 365 दिन के बीच लिखें।';

  @override
  String get tasksWhoDoesIt => 'कौन करेगा';

  @override
  String get tasksAddRoutine => 'नियमित काम जोड़ें';

  @override
  String get tasksRoutineAdded => 'नियमित काम जुड़ा · पहला काम आज का है';

  @override
  String get tasksEditRoutineTitle => 'नियमित काम बदलें';

  @override
  String get tasksSaveChanges => 'बदलाव सहेजें';

  @override
  String get tasksRoutineUpdated => 'नियमित काम अपडेट हुआ';

  @override
  String get tasksDeleteRoutine => 'नियमित काम हटाएँ';

  @override
  String get tasksRoutineDeleted => 'नियमित काम हटाया गया';

  @override
  String get tasksGroupOverdue => 'पिछला बाकी';

  @override
  String get tasksGroupToday => 'आज';

  @override
  String get tasksGroupTomorrow => 'कल';

  @override
  String get tasksGroupLater => 'बाद में';

  @override
  String tasksTodoMeta(Object day, Object who) {
    return '$day · $who';
  }

  @override
  String tasksCompleteTodo(Object title) {
    return '“$title” पूरा करें';
  }

  @override
  String tasksTodoDone(Object title) {
    return 'पूरा हुआ: $title';
  }

  @override
  String get tasksAllDone => 'सब पूरा हुआ';

  @override
  String get tasksNothingPending => 'कुछ बाकी नहीं है।';

  @override
  String tasksNothingPendingFor(Object name) {
    return '$name के लिए कुछ बाकी नहीं है।';
  }

  @override
  String tasksCompleted(int n) {
    return 'पूरे हुए ($n)';
  }

  @override
  String tasksReopenTodo(Object title) {
    return '“$title” फिर से खोलें';
  }

  @override
  String get tasksMovedBack => 'फिर से बाकी काम में जुड़ा';

  @override
  String get tasksNewTodo => 'नया टू-डू';

  @override
  String get tasksEditTodo => 'टू-डू बदलें';

  @override
  String get tasksWhat => 'क्या काम';

  @override
  String get tasksTodoPlaceholder => 'जैसे: AC सर्विस बुक करना';

  @override
  String get tasksTodoRequired => 'लिखें कि क्या काम करना है।';

  @override
  String get tasksWhen => 'कब';

  @override
  String get tasksToday => 'आज';

  @override
  String get tasksTomorrow => 'कल';

  @override
  String get tasksWeekend => 'वीकेंड';

  @override
  String get tasksNextWeek => 'अगले हफ़्ते';

  @override
  String get tasksPickDate => 'तारीख चुनें…';

  @override
  String get tasksWho => 'कौन';

  @override
  String get tasksAddTodo => 'टू-डू जोड़ें';

  @override
  String get tasksTodoAdded => 'टू-डू जोड़ा गया';

  @override
  String get tasksTodoUpdated => 'टू-डू अपडेट हुआ';

  @override
  String get tasksDeleteTodo => 'टू-डू हटाएँ';

  @override
  String get tasksTodoDeleted => 'टू-डू हटाया गया';

  @override
  String tasksSendList(Object name) {
    return '$name को आज की सूची भेजें';
  }

  @override
  String tasksJobs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n काम',
      one: '1 काम',
    );
    return '$_temp0 · उन्हें ऐप की ज़रूरत नहीं';
  }

  @override
  String get tasksPreview => 'झलक';

  @override
  String tasksListFor(Object name) {
    return '$name के लिए आज की सूची';
  }

  @override
  String get tasksShareLead =>
      'उनकी भाषा में WhatsApp संदेश की तरह भेजा जाएगा। उन्हें ऐप की ज़रूरत नहीं।';

  @override
  String get tasksLanguage => 'भाषा';

  @override
  String get tasksLangEnglish => 'English';

  @override
  String get tasksLangHindi => 'हिंदी';

  @override
  String get tasksLangTamil => 'தமிழ்';

  @override
  String get tasksCopy => 'कॉपी करें';

  @override
  String get tasksCopied => 'कॉपी हुआ — किसी भी चैट में पेस्ट करें';

  @override
  String get tasksWhatsApp => 'WhatsApp';

  @override
  String get todayDueToday => 'आज के काम';

  @override
  String get todayAllTasks => 'सभी काम';

  @override
  String get todayTodoKind => 'टू-डू';

  @override
  String todayMoreDue(int n) {
    return '+ $n और बाकी';
  }

  @override
  String get todayNothingDue => 'कुछ बाकी नहीं';

  @override
  String get todayEnjoyQuiet => 'शांति का आनंद लें।';

  @override
  String get tasksRemoveStaffMoves =>
      'उनके नियमित काम और बाकी टू-डू आपके नाम आ जाएँगे।';

  @override
  String get moneyEyebrow => 'घर का खर्च';

  @override
  String get moneyTitle => 'पैसे';

  @override
  String moneySpentIn(Object month) {
    return '$month में खर्च';
  }

  @override
  String moneyLeftOf(Object left, Object budget) {
    return '$budget में से $left बाकी';
  }

  @override
  String moneyDaysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन बाकी',
      one: '1 दिन बाकी',
    );
    return '$_temp0';
  }

  @override
  String moneyBelowPrev(Object amount, Object month) {
    return '$month के कुल से $amount कम';
  }

  @override
  String moneyAbovePrev(Object amount, Object month) {
    return '$month के कुल से $amount ज़्यादा';
  }

  @override
  String moneyOverBudget(Object amount) {
    return 'बजट से $amount ज़्यादा';
  }

  @override
  String get moneySetBudget => 'मासिक बजट तय करें';

  @override
  String get moneyNoBudget => 'कोई बजट तय नहीं';

  @override
  String get moneyBudgetTitle => 'मासिक बजट';

  @override
  String get moneyBudgetSaved => 'बजट सहेजा गया';

  @override
  String get moneySave => 'सहेजें';

  @override
  String get moneyAddSpend => '＋ खर्च जोड़ें';

  @override
  String get moneyQuickAddHint =>
      'या किसी भी टैब से तुरंत जोड़ें में “₹450 Swiggy” लिखें।';

  @override
  String get moneyBills => 'इस महीने के बिल';

  @override
  String moneyBillsPaid(int k, int n) {
    return '$n में से $k भरे';
  }

  @override
  String get moneyAddBill => '＋ बिल जोड़ें';

  @override
  String moneyBillDue(Object date, Object amount) {
    return 'देय $date · पिछली बार $amount';
  }

  @override
  String get moneyOverdue => 'बकाया';

  @override
  String get moneyToday => 'आज';

  @override
  String get moneyPaid => 'भुगतान हुआ';

  @override
  String moneyBillPaidOn(Object date, Object method) {
    return '$date को भुगतान · $method';
  }

  @override
  String get moneyPaidTwice => 'दो बार भुगतान दर्ज हुआ — जांचें';

  @override
  String moneyFirstDue(Object date, Object amount) {
    return 'पहली बार देय $date · $amount';
  }

  @override
  String moneyMarkBillPaid(Object bill) {
    return '$bill का भुगतान दर्ज करें';
  }

  @override
  String get moneyBillsEmpty =>
      'किराया, बिजली, दूध, इंटरनेट… जोड़ें — समय आने पर हम याद दिला देंगे।';

  @override
  String moneyStoppedBills(int count) {
    return 'बंद बिल ($count)';
  }

  @override
  String moneyStoppedRow(Object amount, int day) {
    return '$amount · $day तारीख';
  }

  @override
  String get moneyTrackAgain => 'फिर से ट्रैक करें';

  @override
  String moneyTrackingAgain(Object bill) {
    return '$bill फिर से ट्रैक हो रहा है';
  }

  @override
  String get moneyMethodUpi => 'UPI';

  @override
  String get moneyMethodCash => 'नकद';

  @override
  String get moneyMethodCard => 'कार्ड';

  @override
  String get moneyMethodBank => 'बैंक';

  @override
  String get moneyErrAmount => 'राशि जांचें';

  @override
  String get moneyWhereItWent => 'खर्च कहाँ हुआ';

  @override
  String moneyStaffPay(Object month) {
    return 'स्टाफ वेतन · $month';
  }

  @override
  String moneyBilledRate(Object billed, Object rate) {
    return '$billed का हिसाब · $rate/घंटा';
  }

  @override
  String moneyMonthlyLeaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'मासिक · $count छुट्टियाँ',
      one: 'मासिक · 1 छुट्टी',
    );
    return '$_temp0';
  }

  @override
  String get moneyRecent => 'हालिया';

  @override
  String get moneySeeAll => 'सभी देखें';

  @override
  String moneyRowSub(Object day, Object category, Object source) {
    return '$day · $category · $source';
  }

  @override
  String moneySrcManual(Object name) {
    return '$name ने जोड़ा';
  }

  @override
  String get moneySrcYou => 'आपने जोड़ा';

  @override
  String moneySrcOrder(Object channel) {
    return '$channel ऑर्डर';
  }

  @override
  String get moneySrcStore => 'स्टोर बिल';

  @override
  String get moneySrcBill => 'बिल';

  @override
  String get moneySrcSalary => 'वेतन';

  @override
  String get moneyEmptyTitle => 'इस महीने अभी कोई खर्च नहीं';

  @override
  String get moneyEmptyBody =>
      '“＋ खर्च जोड़ें” पर टैप करें, या किसी बिल को भुगतान किया हुआ चिह्नित करें।';

  @override
  String get moneyAddSpendTitle => 'खर्च जोड़ें';

  @override
  String get moneyEditSpendTitle => 'खर्च संपादित करें';

  @override
  String get moneyAmountLabel => 'राशि (रुपयों में)';

  @override
  String get moneyPaidTo => 'किसे / किसलिए दिया';

  @override
  String get moneyCategory => 'श्रेणी';

  @override
  String get moneyCustomCategoryChip => '＋ कस्टम';

  @override
  String get moneyCustomCategoryLabel => 'कस्टम श्रेणी';

  @override
  String get moneyCustomCategoryHint => 'जैसे: दवाई, यात्रा, ईंधन';

  @override
  String get moneyErrCategory => 'श्रेणी का नाम दर्ज करें';

  @override
  String get moneyShowChart => 'चार्ट दिखाएं';

  @override
  String get moneyHideChart => 'चार्ट छिपाएं';

  @override
  String get moneyChartByItem => 'वस्तु अनुसार';

  @override
  String get moneyChartByCategory => 'श्रेणी अनुसार';

  @override
  String get moneyChartByPeople => 'व्यक्ति अनुसार';

  @override
  String get moneyChartOther => 'अन्य';

  @override
  String get moneyChartUnknown => 'अज्ञात';

  @override
  String get moneyDraftsCollapse => 'ड्राफ़्ट खर्च समेटें';

  @override
  String get moneyDraftsExpand => 'ड्राफ़्ट खर्च खोलें';

  @override
  String moneyDraftsShowAll(int count) {
    return 'सभी दिखाएं ($count)';
  }

  @override
  String moneyDraftsShowLess(int count) {
    return 'पहले $count दिखाएं';
  }

  @override
  String moneyDraftsShowingCount(int shown, int total) {
    return '$total में से $shown दिख रहे हैं';
  }

  @override
  String get moneyPaidWith => 'भुगतान माध्यम';

  @override
  String get moneyWhen => 'कब';

  @override
  String get moneyYesterday => 'कल';

  @override
  String get moneyOtherDay => 'कोई अन्य दिन';

  @override
  String get moneyMore => 'अधिक';

  @override
  String get moneyPaidBy => 'किसने दिया';

  @override
  String get moneyYou => 'आप';

  @override
  String get moneyNote => 'नोट';

  @override
  String get moneyRepeat => 'हर महीने दोहराएं — यह बिल बन जाएगा';

  @override
  String get moneySaveChanges => 'बदलाव सहेजें';

  @override
  String get moneyDelete => 'हटाएं';

  @override
  String moneyAdded(Object amount) {
    return '$amount जोड़ा गया';
  }

  @override
  String moneyAddedBill(Object amount, Object merchant) {
    return '$amount जोड़ा गया · $merchant अब मासिक बिल है';
  }

  @override
  String moneyLearned(Object merchant, Object category) {
    return 'सहेजा गया · अब से $merchant, $category श्रेणी में जाएगा।';
  }

  @override
  String get moneySpendUpdated => 'खर्च अपडेट हुआ';

  @override
  String get moneySpendDeleted => 'खर्च हटाया गया';

  @override
  String get moneyErrMerchant => 'भुगतान किसे किया गया?';

  @override
  String moneyReadOnly(Object name) {
    return '$name द्वारा जोड़ा गया · इसे केवल $name या एडमिन ही बदल सकते हैं।';
  }

  @override
  String moneySalaryManaged(Object name) {
    return 'वेतन के खर्च $name के वेतन में प्रबंधित होते हैं।';
  }

  @override
  String get moneyOpenSalary => 'वेतन खोलें';

  @override
  String moneyDuplicate(
    Object who,
    Object amount,
    Object merchant,
    Object when,
  ) {
    return 'लगता है $who $when $amount · $merchant पहले ही जोड़ चुके हैं।';
  }

  @override
  String get moneyWhoYou => 'आप';

  @override
  String get moneyWhenToday => 'आज';

  @override
  String get moneyWhenYesterday => 'कल';

  @override
  String moneyWhenOn(Object day) {
    return '$day को';
  }

  @override
  String get moneyAddAnyway => 'फिर भी जोड़ें';

  @override
  String get moneyDontAdd => 'न जोड़ें';

  @override
  String get moneyCashSpend => 'नकद खर्च';

  @override
  String moneyOrdinal(String n) {
    String _temp0 = intl.Intl.selectLogic(n, {
      '1': '1 तारीख',
      '2': '2 तारीख',
      '3': '3 तारीख',
      '21': '21 तारीख',
      '22': '22 तारीख',
      '23': '23 तारीख',
      '31': '31 तारीख',
      'other': '$n तारीख',
    });
    return '$_temp0';
  }

  @override
  String get moneyAddBillTitle => 'बिल जोड़ें';

  @override
  String get moneyEditBillTitle => 'बिल संपादित करें';

  @override
  String get moneyBillName => 'नाम';

  @override
  String get moneyUsualAmount => 'सामान्य राशि (₹)';

  @override
  String get moneyDueDay => 'देय तिथि';

  @override
  String moneyDueHelper(Object nth) {
    return 'हर महीने $nth के आसपास भुगतान';
  }

  @override
  String get moneyRemind => 'देय तिथि पर याद दिलाएं';

  @override
  String get moneyBillErrName => 'बिल का नाम लिखें।';

  @override
  String get moneyBillErrDay => '1 से 31 के बीच कोई दिन चुनें।';

  @override
  String moneyBillAdded(Object bill) {
    return '$bill जोड़ा गया';
  }

  @override
  String get moneyBillSaved => 'बिल सहेजा गया';

  @override
  String get moneyStopTracking => 'इस बिल को ट्रैक करना बंद करें';

  @override
  String moneyStopped(Object bill) {
    return '$bill को ट्रैक करना बंद किया';
  }

  @override
  String get moneyDeleteBill => 'बिल हटाएं';

  @override
  String moneyDeleteBillTitle(Object bill) {
    return '$bill हटाएं?';
  }

  @override
  String get moneyDeleteBillLead => 'पिछले खर्चों पर “बिल” लेबल बना रहेगा।';

  @override
  String get moneyKeep => 'रखें';

  @override
  String moneyBillDeleted(Object bill) {
    return '$bill हटाया गया';
  }

  @override
  String moneyPaidTitle(Object bill) {
    return '$bill — भुगतान हो गया?';
  }

  @override
  String moneyPaidLead(Object amount, Object nth) {
    return 'आमतौर पर $nth के आसपास $amount।';
  }

  @override
  String moneyForMonth(Object month) {
    return '$month के लिए';
  }

  @override
  String get moneyMarkPaid => 'भुगतान चिह्नित करें';

  @override
  String moneyBillPaidSnack(Object bill, Object amount) {
    return '$bill भुगतान हुआ · $amount जोड़ा गया';
  }

  @override
  String get moneyAllSpends => 'सभी खर्च';

  @override
  String get moneySearch => 'खर्च खोजें';

  @override
  String moneyCount(int count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खर्च · $total',
      one: '1 खर्च · $total',
    );
    return '$_temp0';
  }

  @override
  String get moneyNoMatch => 'कोई मिलता-जुलता खर्च नहीं।';

  @override
  String moneyClearFilter(Object category) {
    return '$category फ़िल्टर हटाएं';
  }

  @override
  String todayMonthSoFar(Object month) {
    return '$month में अब तक';
  }

  @override
  String get todayMoneyLink => 'पैसे';

  @override
  String todayOfBudget(Object budget, int pct) {
    return '$budget बजट में से · $pct% उपयोग';
  }

  @override
  String todayBillsDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बिल देय',
      one: '1 बिल देय',
    );
    return '$_temp0';
  }

  @override
  String todaySpentSoFar(Object amount) {
    return 'अब तक $amount खर्च';
  }

  @override
  String get todaySetBudget => 'बजट तय करें';

  @override
  String get recipeAPinch => 'चुटकी भर';

  @override
  String get onboardingAddStarterRecipes => '9 लोकप्रिय रेसिपी जोड़ें';

  @override
  String get mealsTitle => 'भोजन';

  @override
  String mealsWeekOf(String date) {
    return '$date का सप्ताह';
  }

  @override
  String get mealsPrevWeek => 'पिछला सप्ताह';

  @override
  String get mealsNextWeek => 'अगला सप्ताह';

  @override
  String get mealsThisWeek => 'यह सप्ताह';

  @override
  String mealsDaySemantics(String weekday, String date, int count) {
    return '$weekday $date, 3 में से $count भोजन तय';
  }

  @override
  String mealsMissingWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सप्ताह के बाकी दिनों के लिए $count सामग्रियाँ कम हैं',
      one: 'सप्ताह के बाकी दिनों के लिए 1 सामग्री कम है',
    );
    return '$_temp0';
  }

  @override
  String get mealsAddAll => 'सभी जोड़ें';

  @override
  String get mealsPastDay => 'बीता दिन';

  @override
  String mealsSlotTitle(String slot) {
    String _temp0 = intl.Intl.selectLogic(slot, {
      'breakfast': 'नाश्ता',
      'lunch': 'दोपहर का खाना',
      'other': 'रात का खाना',
    });
    return '$_temp0';
  }

  @override
  String mealsSlotLower(String slot) {
    String _temp0 = intl.Intl.selectLogic(slot, {
      'breakfast': 'नाश्ता',
      'lunch': 'दोपहर का खाना',
      'other': 'रात का खाना',
    });
    return '$_temp0';
  }

  @override
  String mealsPlanSlot(String slot) {
    return '$slot तय करें';
  }

  @override
  String mealsChangeSlot(String slot) {
    return '$slot बदलें';
  }

  @override
  String get mealsPickFromBook => 'अपनी रेसिपी बुक से चुनें';

  @override
  String mealsMinutes(int min) {
    return '$min मिनट';
  }

  @override
  String get mealsReadyToCook => 'पकाने के लिए तैयार';

  @override
  String mealsMissingCount(int count) {
    return '$count कम';
  }

  @override
  String get mealsEatingOut => 'बाहर खाना';

  @override
  String get mealsLeftovers => 'बचा हुआ खाना';

  @override
  String mealsRemoved(String name) {
    return '$name (हटाया गया)';
  }

  @override
  String get mealsRecipeBook => 'रेसिपी बुक';

  @override
  String get mealsAdd => 'जोड़ें';

  @override
  String mealsCardMeta(int min, String tag) {
    return '$min मिनट · $tag';
  }

  @override
  String get mealsEmptyTitle => 'अभी कोई रेसिपी नहीं';

  @override
  String get mealsEmptyBody =>
      'अपनी पहली रेसिपी जोड़ें, या 9 लोकप्रिय रेसिपी जोड़ें।';

  @override
  String get mealsAddStarter => '9 लोकप्रिय रेसिपी जोड़ें';

  @override
  String get mealsTypeRecipe => 'रेसिपी लिखें';

  @override
  String mealsStarterAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रेसिपी जोड़ी गईं',
      one: '1 रेसिपी जोड़ी गई',
    );
    return '$_temp0';
  }

  @override
  String mealsPickerTitle(String slot, String day) {
    return '$slot · $day';
  }

  @override
  String mealsPickerLead(String slot) {
    return 'पहले $slot के सुझाव दिए गए हैं। कम सामग्री किराना सूची में चली जाएगी।';
  }

  @override
  String get mealsOptEatingOut => '🍽 बाहर खाना';

  @override
  String get mealsOptLeftovers => '♻ बचा हुआ खाना';

  @override
  String get mealsOptNote => '✎ नोट…';

  @override
  String get mealsNoteHint => 'जैसे: अम्मा से आया डोसा';

  @override
  String get mealsNoteSave => 'नोट सहेजें';

  @override
  String get mealsSearchRecipes => 'रेसिपी खोजें';

  @override
  String mealsClearSlot(String slot) {
    return '$slot खाली करें';
  }

  @override
  String mealsPlanned(String dish) {
    return '$dish तय किया गया';
  }

  @override
  String mealsPlannedMissing(String dish, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामग्रियाँ कम हैं',
      one: '1 सामग्री कम है',
    );
    return '$dish तय · $_temp0';
  }

  @override
  String mealsPlannedKind(String slot, String what) {
    return '$slot · $what';
  }

  @override
  String get mealsSlotCleared => 'स्लॉट खाली किया गया';

  @override
  String get mealsReviewTitle => 'किराना सूची में जोड़ें';

  @override
  String get mealsReviewLead =>
      'जो चीज़ पहले से घर में है उसे अनटिक करें — हम याद रखेंगे।';

  @override
  String mealsReviewAdd(int count) {
    return '$count जोड़ें';
  }

  @override
  String mealsAddedToGrocery(int count) {
    return 'किराना सूची में $count जोड़े गए';
  }

  @override
  String get recipeTitle => 'रेसिपी';

  @override
  String get recipeAddToPlan => 'भोजन योजना में जोड़ें';

  @override
  String get recipeMoreOptions => 'अधिक विकल्प';

  @override
  String get recipeEdit => 'संपादित करें';

  @override
  String get recipeDelete => 'हटाएं';

  @override
  String recipeServes(int n) {
    return '$n लोगों के लिए';
  }

  @override
  String get recipeIngredients => 'सामग्री';

  @override
  String get recipeServings => 'सर्विंग्स';

  @override
  String recipePpl(int n) {
    return '$n लोग';
  }

  @override
  String get recipeFewer => 'कम सर्विंग्स';

  @override
  String get recipeMoreServings => 'अधिक सर्विंग्स';

  @override
  String get recipeInKitchen => 'रसोई में है';

  @override
  String get recipeOnList => 'सूची में';

  @override
  String get recipeMissing => 'कम है';

  @override
  String get recipeSrHave => 'रसोई में है';

  @override
  String get recipeSrOnList => 'किराना सूची में पहले से है';

  @override
  String get recipeSrMissing => 'कम है';

  @override
  String recipeMarkedHave(String name) {
    return '$name रसोई में उपलब्ध चिह्नित';
  }

  @override
  String recipeMarkedMissing(String name) {
    return '$name कम चिह्नित';
  }

  @override
  String recipeAddMissing(int count) {
    return '🛒 $count कम सामग्री किराना में जोड़ें';
  }

  @override
  String get recipeAllThere => '✓ सब कुछ रसोई में या सूची में है';

  @override
  String get recipeMethod => 'बनाने की विधि';

  @override
  String get recipeStartCook => '🔥 कुक मोड शुरू करें';

  @override
  String recipePlanTitle(String dish) {
    return '$dish की योजना बनाएं';
  }

  @override
  String get recipePlanDay => 'दिन';

  @override
  String get recipePlanMeal => 'भोजन';

  @override
  String get recipePlanAdd => 'योजना में जोड़ें';

  @override
  String recipePlannedFor(String day, String slot) {
    return '$day के लिए $slot तय';
  }

  @override
  String recipeDeletePlanned(String dish, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिनों',
      one: '1 दिन',
    );
    return '$dish $_temp0 के लिए तय है। उन दिनों से भी हटाएं?';
  }

  @override
  String get recipeKeepPlans => 'उन दिनों पर रखें';

  @override
  String get recipeRemoveToo => 'वहाँ से भी हटाएं';

  @override
  String get recipeDeleted => 'रेसिपी हटाई गई';

  @override
  String get recipeAddTitle => 'रेसिपी जोड़ें';

  @override
  String get recipeAddLead =>
      'सबसे तेज़ तरीका चुनें — बाद में इसे संवार सकते हैं।';

  @override
  String get recipeTypeIt => 'खुद लिखें';

  @override
  String get recipeTypeItSub => 'नाम, सामग्री, चरण';

  @override
  String get recipePasteLink => 'लिंक पेस्ट करें';

  @override
  String get recipePasteLinkSub =>
      'YouTube, Instagram या ब्लॉग — सामग्री अपने आप निकल आएगी';

  @override
  String get recipeSnap => 'पन्ने की फ़ोटो लें';

  @override
  String get recipeSnapSub => 'किताब या हाथ से लिखे कार्ड की फ़ोटो';

  @override
  String get recipeComingSoon => 'जल्द आ रहा है';

  @override
  String get recipeFormNew => 'नई रेसिपी';

  @override
  String get recipeFormEdit => 'रेसिपी संपादित करें';

  @override
  String get recipeFieldName => 'नाम';

  @override
  String get recipeFieldTime => 'समय (मिनटों में)';

  @override
  String get recipeFieldServes => 'कितने लोगों के लिए';

  @override
  String get recipeFieldMealType => 'भोजन का प्रकार';

  @override
  String get recipeFieldTags => 'टैग';

  @override
  String get recipeTagsHint => 'जैसे: झटपट, बच्चों की पसंद';

  @override
  String get recipeFieldIngredients => 'सामग्री';

  @override
  String get recipeIngName => 'सामग्री';

  @override
  String get recipeIngQty => 'मात्रा';

  @override
  String get recipeIngUnit => 'इकाई';

  @override
  String get recipeUnitNone => '(कोई नहीं)';

  @override
  String get recipeAddIngredient => '+ सामग्री जोड़ें';

  @override
  String get recipeFieldSteps => 'चरण';

  @override
  String recipeStepLabel(int n) {
    return 'चरण $n';
  }

  @override
  String get recipeAddStep => '+ चरण जोड़ें';

  @override
  String get recipeMoveUp => 'ऊपर ले जाएं';

  @override
  String get recipeMoveDown => 'नीचे ले जाएं';

  @override
  String get recipeRemoveRow => 'हटाएं';

  @override
  String get recipeSave => 'सहेजें';

  @override
  String get recipeSaved => 'रेसिपी सहेजी गई';

  @override
  String get recipeErrName => 'नाम लिखें।';

  @override
  String get recipeErrIngredients => 'कम से कम एक सामग्री जोड़ें।';

  @override
  String get recipeErrSteps => 'कम से कम एक चरण जोड़ें।';

  @override
  String get recipeErrQty => 'मात्रा 0 से अधिक होनी चाहिए।';

  @override
  String get recipeErrIngName => 'सामग्री का नाम लिखें।';

  @override
  String get recipeErrTime => 'समय 1–600 मिनट होना चाहिए।';

  @override
  String get recipeErrServes => 'लोगों की संख्या 1–20 होनी चाहिए।';

  @override
  String get recipeErrStepLong => 'एक चरण अधिकतम 500 अक्षरों का हो सकता है।';

  @override
  String get recipeDiscardTitle => 'बदलाव छोड़ें?';

  @override
  String get recipeKeepEditing => 'संपादन जारी रखें';

  @override
  String get recipeDiscard => 'छोड़ें';

  @override
  String get cookSub => 'कुक मोड · स्क्रीन चालू रहेगी';

  @override
  String cookOf(int total) {
    return '/$total';
  }

  @override
  String cookStepSemantics(int n, int total, String text) {
    return '$total में से चरण $n: $text';
  }

  @override
  String get cookBack => 'पीछे';

  @override
  String get cookNext => 'अगला चरण';

  @override
  String get cookFinished => '✓ पूरा हुआ';

  @override
  String get todayMenuTitle => 'आज का मेन्यू';

  @override
  String get todayWeekPlan => 'सप्ताह की योजना';

  @override
  String get todayPlan => '+ योजना';

  @override
  String todayMissingToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🛒 आज $count सामग्रियाँ कम हैं',
      one: '🛒 आज 1 सामग्री कम है',
    );
    return '$_temp0';
  }

  @override
  String get todayAddToList => 'सूची में जोड़ें';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String profileRoleHome(String role, String home) {
    return '$role · $home';
  }

  @override
  String get roleAdmin => 'एडमिन';

  @override
  String get roleMember => 'सदस्य';

  @override
  String get profileName => 'नाम';

  @override
  String get profileNameSheetTitle => 'आपका नाम';

  @override
  String get profileNameSheetLead =>
      'आपके घर में सभी को दिखेगा। उनके फ़ोन पर सिंक होता है।';

  @override
  String get profileNameError => 'अपना नाम लिखें।';

  @override
  String get profileSave => 'सहेजें';

  @override
  String get profileNameUpdated => 'नाम अपडेट हुआ';

  @override
  String get profileEditName => 'नाम बदलें';

  @override
  String get profileThisPhone => 'यह फ़ोन';

  @override
  String get profileOnlyThisPhone => 'केवल यह फ़ोन';

  @override
  String get profileDeviceKey => 'डिवाइस कुंजी';

  @override
  String get profileDeviceKeySub =>
      'दूसरे यह देखकर पक्का करते हैं कि यह वाकई आपका फ़ोन है';

  @override
  String get profileYourHomes => 'आपके घर';

  @override
  String get profileCurrent => 'मौजूदा';

  @override
  String profileHomeSub(int family, int help, String role) {
    String _temp0 = intl.Intl.pluralLogic(
      family,
      locale: localeName,
      other: '$family परिवार सदस्य',
      one: '1 परिवार सदस्य',
    );
    String _temp1 = intl.Intl.pluralLogic(
      help,
      locale: localeName,
      other: '$help घरेलू सहायक',
      one: '1 घरेलू सहायक',
    );
    return '$_temp0 · $_temp1 · आप $role हैं';
  }

  @override
  String get profileNotifications => 'सूचनाएं';

  @override
  String get notifArrival => 'घरेलू सहायक का आना';

  @override
  String get notifArrivalSub =>
      'जब वे आमतौर पर आते हैं, तब उपस्थिति दर्ज करने की याद दिलाता है';

  @override
  String get notifDigest => 'सुबह के कामों का सारांश';

  @override
  String get notifDigestSub => 'सुबह 8 बजे · आज क्या करना है';

  @override
  String get notifBillDue => 'बिल देय';

  @override
  String get notifBillDueSub => 'देय तिथि पर · “बिजली ₹1,980 — भुगतान हो गया?”';

  @override
  String get notifEvening => 'शाम का खर्च रिमाइंडर';

  @override
  String get notifEveningSub =>
      'रात 9 बजे, केवल तब जब उस दिन कुछ न जोड़ा गया हो';

  @override
  String get profileOnThisPhone => 'इस फ़ोन पर';

  @override
  String get profileBackup => 'बैकअप';

  @override
  String get profileBackupNotSetUp => 'सेटअप नहीं हुआ';

  @override
  String get profileBackupArrives => 'बैकअप P18 में आएगा';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileEnglish => 'अंग्रेज़ी';

  @override
  String get profileAppearance => 'दिखावट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get profileDevTools => 'डेवलपर टूल्स';

  @override
  String profileRemoveHome(String home) {
    return '🗑 इस फ़ोन से $home हटाएं';
  }

  @override
  String profileRemoveTitle(String home) {
    return 'इस फ़ोन से $home हटाएं?';
  }

  @override
  String get profileRemoveLead =>
      'यह फ़ोन घर से हट जाएगा और इसमें मौजूद डेटा की कॉपी मिट जाएगी। बाकी सभी के पास सारा डेटा सुरक्षित रहेगा।';

  @override
  String get profileOnlyAdminLead =>
      'आप अकेले एडमिन हैं। पहले किसी और को एडमिन बनाएं, ताकि घर बिना एडमिन के न रहे।';

  @override
  String get profileGoToMembers => 'सदस्यों पर जाएं';

  @override
  String get profileKeep => 'रखें';

  @override
  String get profileRemove => 'हटाएं';

  @override
  String get profileFinePrint =>
      '🔒 कोई खाता नहीं, कोई क्लाउड नहीं। डेटा आपके घर के फ़ोनों के बीच सीधे एन्क्रिप्टेड रूप से सिंक होता है।';

  @override
  String get profilePrivacy => 'गोपनीयता नीति';

  @override
  String get profileHelp => 'सहायता';

  @override
  String get profileVersion => 'संस्करण';

  @override
  String homeSubtitle(int count, String id) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count परिवार सदस्य',
      one: '1 परिवार सदस्य',
    );
    return '$_temp0 · घर ID $id';
  }

  @override
  String get homeRename => 'घर का नाम बदलें';

  @override
  String get homeSyncPlaceholderTitle => 'अभी तक केवल यह फ़ोन';

  @override
  String get homeSyncPlaceholderSub =>
      'फ़ोन सिंक करने के लिए अपने परिवार को आमंत्रित करें।';

  @override
  String homeYourPhone(String model) {
    return 'आपका $model';
  }

  @override
  String get homeThisPhone => 'यह फ़ोन';

  @override
  String get homeSyncFootnote =>
      'ⓘ एक ही Wi-Fi पर, या दोनों फ़ोनों पर इल्लम खुला होने पर इंटरनेट के ज़रिए फ़ोन सीधे सिंक होते हैं।';

  @override
  String get homeBackupNone => 'अभी कोई बैकअप नहीं';

  @override
  String get homeBackupNotThisPhone =>
      'इस फ़ोन से बैकअप नहीं हो रहा — अपनी कॉपी जोड़ें';

  @override
  String get homeInvite => '+ किसी को आमंत्रित करें';

  @override
  String get homeInviteArrives => 'आमंत्रण P14 में आएगा';

  @override
  String homeAskAdmins(String names) {
    return '🔒 केवल एडमिन ही लोगों को आमंत्रित कर सकते हैं या हटा सकते हैं। $names से पूछें।';
  }

  @override
  String homeOr(String a, String b) {
    return '$a या $b';
  }

  @override
  String get homeFamily => 'परिवार · ऐप इस्तेमाल करते हैं';

  @override
  String get homeYou => '(आप)';

  @override
  String homeMemberSub(String model, String month) {
    return '$model · $month में जुड़े';
  }

  @override
  String get homeHouseHelp => 'घरेलू सहायक · ऐप की ज़रूरत नहीं';

  @override
  String get homeNoHelp => 'अभी कोई घरेलू सहायक नहीं जोड़ा गया है।';

  @override
  String get homeAddHelp => '+ घरेलू सहायक जोड़ें';

  @override
  String get homeRolesTitle => 'एडमिन और सदस्य क्या कर सकते हैं?';

  @override
  String get homeRolesAdmin =>
      'सदस्य के सभी काम, और साथ ही: लोगों को आमंत्रित करना व हटाना, भूमिका बदलना, स्टाफ़ के वेतन नियम तय करना, वेतन देना, घर का नाम बदलना या घर हटाना।';

  @override
  String get homeRolesMember =>
      'लिस्ट, काम और भोजन; घरेलू सहायक का आना-जाना दर्ज करना; खर्च जोड़ना और देखना; बजट और कुल वेतन देखना।';

  @override
  String get homeRolesFootnote =>
      'हर फ़ोन इन नियमों की जांच खुद करता है, इसलिए बिना अनुमति किए गए बदलाव को बाकी सभी फ़ोन अनदेखा कर देते हैं।';

  @override
  String get homeLeaveDelete => 'छोड़ें या हटाएं';

  @override
  String homeLeave(String home) {
    return '$home छोड़ें';
  }

  @override
  String get homeDelete => '🗑 सभी फ़ोन से यह घर हटाएं';

  @override
  String memberJoined(String month, String how) {
    return '$month में जुड़े · $how';
  }

  @override
  String get memberHowCreated => 'घर बनाया';

  @override
  String memberHowInvited(String name) {
    return '$name द्वारा आमंत्रित';
  }

  @override
  String get memberHowQr => 'QR कोड से जुड़े';

  @override
  String get memberHowPhrase => 'फ़्रेज़ से जुड़े';

  @override
  String memberDeviceKey(String fp) {
    return 'डिवाइस कुंजी $fp';
  }

  @override
  String get memberEditProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get memberStepDown => 'एडमिन पद छोड़ें';

  @override
  String get memberStepDownLead =>
      'आपको दोबारा एडमिन बनने के लिए किसी दूसरे एडमिन की ज़रूरत होगी।';

  @override
  String get memberCancel => 'रद्द करें';

  @override
  String get memberStepDownConfirm => 'पद छोड़ें';

  @override
  String get memberNowMemberSelf => 'अब आप एक सदस्य हैं।';

  @override
  String get homeLastAdmin => 'घर में कम से कम एक एडमिन होना ज़रूरी है।';

  @override
  String get memberMakeAdmin => '🛡 एडमिन बनाएं';

  @override
  String get memberRemoveAdmin => 'एडमिन अधिकार हटाएं';

  @override
  String get memberRemove => 'हटाएं';

  @override
  String memberNowAdmin(String name) {
    return '$name अब एडमिन हैं';
  }

  @override
  String memberNowMember(String name) {
    return '$name अब सदस्य हैं';
  }

  @override
  String get homeOnlyAdminsRoles =>
      'सिर्फ़ एडमिन ही भूमिका बदल सकते हैं या लोगों को हटा सकते हैं।';

  @override
  String get homeNameLength => 'अपने घर को कोई नाम दें।';

  @override
  String get homeChooseAdmin => 'पहले नया एडमिन चुनें';

  @override
  String memberRemoveTitle(String name) {
    return '$name को हटाएं?';
  }

  @override
  String memberRemoveLeadWork(String home, String work) {
    return 'उनका फ़ोन $home से सिंक करना बंद कर देगा और उन्हें कोई नया बदलाव नहीं मिलेगा। उनका काम ($work) आपके पास आ जाएगा।';
  }

  @override
  String memberRemoveLead(String home) {
    return 'उनका फ़ोन $home से सिंक करना बंद कर देगा और उन्हें कोई नया बदलाव नहीं मिलेगा।';
  }

  @override
  String get memberRemoveInfo =>
      'जब उनका फ़ोन अगली बार आपके किसी फ़ोन से जुड़ेगा, तो उस पर से यह घर मिट जाएगा। तब तक — या अगर वह कभी न जुड़े — पहले से मौजूद डेटा बना रहेगा। बाकी सभी लोग घर की नई कुंजी पर शिफ्ट हो जाएंगे।';

  @override
  String memberRemoved(String name) {
    return '$name को हटा दिया गया';
  }

  @override
  String workRoutines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रूटीन',
      one: '1 रूटीन',
    );
    return '$_temp0';
  }

  @override
  String workTodos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बाकी टू-डू',
      one: '1 बाकी टू-डू',
    );
    return '$_temp0';
  }

  @override
  String workAnd(String a, String b) {
    return '$a और $b';
  }

  @override
  String get homeRenameLead => 'फ़ोन सिंक होने के बाद सभी को नया नाम दिखेगा।';

  @override
  String get homeRenamed => 'घर का नाम बदला गया';

  @override
  String get homeOnlyOneTitle => 'यहां सिर्फ़ आप ही हैं';

  @override
  String homeOnlyOneLead(String home) {
    return 'आपके छोड़ने पर $home में कोई फ़ोन नहीं बचेगा, इसलिए यह घर हट जाएगा।';
  }

  @override
  String get homeStay => 'बने रहें';

  @override
  String get homeDeleteHome => 'घर हटाएं';

  @override
  String homeLeaveTitle(String home) {
    return '$home छोड़ें?';
  }

  @override
  String homeLeaveLeadWork(String work, String admin) {
    return 'यह फ़ोन सिंक करना बंद कर देगा और इसकी कॉपी मिट जाएगी। आपका काम ($work) $admin के पास चला जाएगा। कोई एडमिन आपको कभी भी वापस आमंत्रित कर सकता है।';
  }

  @override
  String get homeLeaveLead =>
      'यह फ़ोन सिंक करना बंद कर देगा और इसकी कॉपी मिट जाएगी। कोई एडमिन आपको कभी भी वापस आमंत्रित कर सकता है।';

  @override
  String get homeLeaveConfirm => 'छोड़ें';

  @override
  String homeLeft(String home) {
    return 'आपने $home छोड़ दिया है। आगे बढ़ने के लिए नया घर बनाएं या किसी घर से जुड़ें।';
  }

  @override
  String homeDeleteTitle(String home) {
    return '$home को हटाएं?';
  }

  @override
  String get homeDeleteLead =>
      'सिंक होते ही घर के हर फ़ोन से इसकी कॉपी — लिस्ट, काम, भोजन, हाज़िरी, वेतन और खर्च — मिट जाएगी। इसे वापस नहीं लाया जा सकता।';

  @override
  String get homeDeleteInfo =>
      'जो फ़ोन फिर कभी सिंक न हो, उस पर इसकी कॉपी तब तक बनी रहती है जब तक कोई उसे खोलता नहीं।';

  @override
  String homeTypeToConfirm(String home) {
    return 'पुष्टि के लिए $home टाइप करें';
  }

  @override
  String get homeDeleteConfirm => 'सभी फ़ोन से हटाएं';

  @override
  String todayFamilyButton(String home, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'परिवार के $count सदस्य',
      one: 'परिवार का 1 सदस्य',
    );
    return '$home: $_temp0। घर प्रबंधित करें';
  }

  @override
  String get todayYourProfile => 'आपकी प्रोफ़ाइल';

  @override
  String todayThingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count काम',
      one: '1 काम',
    );
    return '$_temp0';
  }

  @override
  String todayThingsNeed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' आज घर पर करने हैं।',
      one: ' आज घर पर करना है।',
    );
    return '$_temp0';
  }

  @override
  String todayStaffAtHome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'अभी घर पर $count स्टाफ़ हैं',
      one: 'अभी घर पर 1 स्टाफ़ है',
    );
    return '$_temp0';
  }

  @override
  String get todayNoStaff => 'घर पर कोई स्टाफ़ नहीं';

  @override
  String todayBudgetLeft(String amount) {
    return 'बजट में $amount बाकी';
  }

  @override
  String todayBudgetOver(String amount) {
    return 'बजट से $amount ज़्यादा';
  }

  @override
  String get todaySetABudget => 'बजट तय करें';

  @override
  String get qaGrocery => 'Grocery';

  @override
  String get qaShopping => 'Shopping';

  @override
  String get qaTodo => 'To-do';

  @override
  String get qaSpend => 'Spend';

  @override
  String get qaEmpty => '✨ Start typing — we’ll pick the right place.';

  @override
  String qaPreviewTodo(String title, String day, String who) {
    return 'To-do · “$title” · $day · $who';
  }

  @override
  String qaPreviewSpend(String amount, String merchant, String category) {
    return 'Spend · $amount · $merchant · $category';
  }

  @override
  String get qaPreviewSpendNoAmount => 'Spend · add an amount, like “₹450”';

  @override
  String qaPreviewItem(String type, String name, String qty, String store) {
    return '$type · $name $qty → $store';
  }

  @override
  String get qaUsual => ' (usual)';

  @override
  String get qaNeedAmount => 'ⓘ Add an amount, like “₹450 Swiggy”';

  @override
  String get qaTitle => 'Quick add';

  @override
  String get qaLead => 'Type it the way you’d say it.';

  @override
  String get qaPlaceholder => 'Milk 2L · Pay water bill tomorrow · ₹450 Swiggy';

  @override
  String get qaAdd => 'Add';

  @override
  String get qaFabLabel => 'Add';

  @override
  String get qaFabTooltip => 'Quick add';

  @override
  String get qaTodoAddedToday => 'To-do added for today';

  @override
  String get qaTodoAddedTomorrow => 'To-do added for tomorrow';

  @override
  String qaTodoAddedOn(String day) {
    return 'To-do added for $day';
  }

  @override
  String qaSpendAdded(String amount) {
    return '$amount added to spends';
  }

  @override
  String get notifChannelStaff => 'घरेलू सहायक';

  @override
  String get notifChannelTasks => 'काम और रिमाइंडर';

  @override
  String get notifChannelMoney => 'बिल और खर्च';

  @override
  String get notifChannelBackup => 'बैकअप';

  @override
  String get notifChannelHome => 'घर और सदस्य';

  @override
  String get notifAppName => 'इल्लम';

  @override
  String notifArrivalBody(String name, String time) {
    return '$name आमतौर पर $time तक आते हैं — आना दर्ज करें?';
  }

  @override
  String get notifMarkInNow => 'अभी आना दर्ज करें';

  @override
  String get notifOnLeaveToday => 'आज छुट्टी पर';

  @override
  String notifDigestBody(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आज $count काम हैं: $titles…',
      one: 'आज 1 काम है: $titles',
    );
    return '$_temp0';
  }

  @override
  String notifBillBody(String bill, String amount) {
    return 'आज $bill भरना है · पिछली बार $amount';
  }

  @override
  String notifPaidAmount(String amount) {
    return '$amount चुकाए';
  }

  @override
  String get notifOpen => 'खोलें';

  @override
  String get notifEveningBody => 'आज कुछ खर्च किया? कुछ ही सेकंड में जोड़ें।';

  @override
  String get notifExplainerTitle => 'रिमाइंडर चालू करें?';

  @override
  String notifExplainerBody(String name) {
    return 'जब $name के आने का समय हो तब रिमाइंडर पाएं, और सुबह आज के कामों की लिस्ट देखें।';
  }

  @override
  String get notifYourHelp => 'आपके घरेलू सहायक';

  @override
  String get notifNotNow => 'अभी नहीं';

  @override
  String get notifContinue => 'आगे बढ़ें';

  @override
  String get notifOffBanner => 'इल्लम के लिए सूचनाएं बंद हैं';

  @override
  String get notifTurnOn => 'चालू करें';

  @override
  String get debugRunJobs => 'Run background jobs now';

  @override
  String get debugPlanReminders => 'Plan reminders';

  @override
  String get debugRanJobs => 'Ran background jobs';

  @override
  String syncChangeNotApplied(String reason) {
    return 'आपका बदलाव लागू नहीं हुआ: $reason';
  }

  @override
  String get syncReasonAdminOnly => 'इसे सिर्फ़ एडमिन बदल सकते हैं';

  @override
  String get syncReasonOwnOnly => 'आप सिर्फ़ अपनी प्रविष्टियां बदल सकते हैं';

  @override
  String get syncReasonTooOld => 'यह 48 घंटे से ज़्यादा पुराना है';

  @override
  String get syncReasonLastAdmin => 'घर में कम से कम एक एडमिन होना ज़रूरी है।';

  @override
  String get syncReasonOther => 'कुछ गड़बड़ हो गई। फिर से कोशिश करें।';

  @override
  String get syncLabTitle => 'सिंक लैब';

  @override
  String syncLabCounts(int applied, int pending, int quarantined) {
    return 'बदलाव: $applied लागू · $pending प्रतीक्षा में · $quarantined क्वारंटीन';
  }

  @override
  String get syncLabMemberLog => 'सदस्यता लॉग';

  @override
  String get syncLabVerify => 'सभी हस्ताक्षर जांचें';

  @override
  String syncLabVerifyResult(int ok, int bad, int unsigned) {
    return '$ok ✓ हस्ताक्षरित · $bad ग़लत · $unsigned बिना हस्ताक्षर';
  }

  @override
  String get syncLabExport => 'बंडल एक्सपोर्ट करें';

  @override
  String syncLabExported(int n) {
    return 'बंडल कॉपी हुआ · $n बदलाव';
  }

  @override
  String get syncLabImport => 'क्लिपबोर्ड से बंडल इम्पोर्ट करें';

  @override
  String syncLabImportResult(
    int applied,
    int already,
    int pending,
    int quarantined,
  ) {
    return 'लागू $applied · पहले से मौजूद $already · प्रतीक्षा में $pending · क्वारंटीन $quarantined';
  }

  @override
  String get syncLabOtherHome => 'यह बंडल किसी दूसरे घर का है।';

  @override
  String get syncLabReplace => 'इस फ़ोन का घर बदलें';

  @override
  String get syncLabBadBundle => 'यह इल्लम बंडल नहीं है।';

  @override
  String get syncLabTamper => 'छेड़छाड़ जांच';

  @override
  String get syncLabAsArjunTick =>
      'अर्जुन के रूप में: किराने का सामान टिक करें';

  @override
  String get syncLabAsArjunRename => 'अर्जुन के रूप में: घर का नाम बदलें';

  @override
  String get syncLabSigned => '✓ हस्ताक्षरित';

  @override
  String get syncLabUnsigned => '✕ बिना हस्ताक्षर';

  @override
  String get syncLabShare => 'शेयर करें';

  @override
  String syncLabRecentOps(int count) {
    return 'पिछले $count कार्य';
  }

  @override
  String syncLabMemberCounts(
    int applied,
    int ignored,
    int pending,
    int devices,
  ) {
    return '$applied लागू · $ignored अनदेखे · $pending प्रतीक्षा में · $devices डिवाइस';
  }

  @override
  String get inviteTitle => 'किसी को आमंत्रित करें';

  @override
  String inviteFirstRunTitle(String home) {
    return '$home तैयार है';
  }

  @override
  String inviteFirstRunSub(String homeId) {
    return 'होम ID $homeId';
  }

  @override
  String get inviteFirstRunLead =>
      'अपने परिवार को अपने फ़ोन से इसे स्कैन करने दें, या उन्हें फ़्रेज़ भेजें। आप यहां हर व्यक्ति को मंज़ूरी देंगे।';

  @override
  String inviteQrLabel(String home) {
    return '$home से जुड़ने के लिए QR कोड';
  }

  @override
  String get inviteOrTypePhrase => 'या यह फ़्रेज़ टाइप करें';

  @override
  String get inviteSendWhatsApp => 'WhatsApp पर फ़्रेज़ भेजें';

  @override
  String inviteWhatsAppText(String home, String phrase) {
    return 'इल्लम पर \"$home\" से जुड़ें। ऐप खोलें → घर से जुड़ें → टाइप करें: $phrase\n(10 मिनट तक मान्य)';
  }

  @override
  String get inviteCopyPhrase => 'फ़्रेज़ कॉपी करें';

  @override
  String get invitePhraseCopied =>
      'फ़्रेज़ कॉपी हो गया — यह एक बार, 10 मिनट के लिए काम करता है';

  @override
  String inviteValidFor(String time) {
    return '$time तक मान्य · एक बार काम करता है';
  }

  @override
  String get inviteExpired => 'यह कोड समाप्त हो गया है।';

  @override
  String get inviteMakeNew => 'नया कोड बनाएं';

  @override
  String get inviteVisibleWifi => 'इस Wi-Fi पर दिख रहा है';

  @override
  String get inviteVisibleWifiSub => 'एक ही Wi-Fi वाले फ़ोन सीधे जुड़ते हैं';

  @override
  String get inviteNoWifi =>
      'Wi-Fi पर नहीं — बाकी लोग फिर भी इंटरनेट से जुड़ सकते हैं';

  @override
  String get inviteWaiting => 'किसी के जुड़ने का इंतज़ार है…';

  @override
  String get inviteWaitingSub => 'उनके जुड़ने तक यह स्क्रीन खुली रखें';

  @override
  String get inviteRequestEyebrow => 'जुड़ने का अनुरोध';

  @override
  String inviteRequestVia(String model) {
    return '$model · इसी Wi-Fi पर';
  }

  @override
  String inviteRequestSas(String emojis) {
    return 'उनके फ़ोन पर $emojis दिखना चाहिए';
  }

  @override
  String get inviteRequestSasHint => 'अगर ऐसा न दिखे, तो मना करें पर टैप करें।';

  @override
  String get inviteJoinsAs => 'किस रूप में जुड़ेंगे';

  @override
  String get inviteAdminNote =>
      'एडमिन लोगों को आमंत्रित कर सकते हैं, हटा सकते हैं और वेतन संभाल सकते हैं।';

  @override
  String get inviteDeny => 'मना करें';

  @override
  String get inviteAllow => '✓ अनुमति दें';

  @override
  String inviteAdding(String name) {
    return '$name को जोड़ा जा रहा है';
  }

  @override
  String inviteSending(int pct) {
    return 'घर का डेटा भेजा जा रहा है… $pct%';
  }

  @override
  String get inviteSendingSub =>
      'सीधे उनके फ़ोन पर, एन्क्रिप्टेड रूप में। यह स्क्रीन खुली रखें।';

  @override
  String inviteJoined(String name) {
    return '$name जुड़ गए';
  }

  @override
  String get inviteJoinedSub => 'उनका फ़ोन अब इस घर से सिंक होता है।';

  @override
  String get inviteAnother => 'किसी और को आमंत्रित करें';

  @override
  String inviteDeclinedSnack(String name) {
    return '$name का अनुरोध अस्वीकार किया गया। पुराना फ़्रेज़ दोबारा इस्तेमाल न हो, इसलिए नया फ़्रेज़ बनाया गया है।';
  }

  @override
  String get inviteSkip => 'अभी छोड़ें — बाद में आमंत्रित करें';

  @override
  String get inviteContinue => 'मेरे घर पर जाएं';

  @override
  String get inviteDone => 'हो गया';

  @override
  String inviteWelcomeSnack(String home) {
    return '$home में आपका स्वागत है';
  }

  @override
  String inviteMembersOnly(String admins) {
    return 'सिर्फ़ एडमिन ही लोगों को आमंत्रित कर सकते हैं। $admins से पूछें।';
  }

  @override
  String debugInvitePort(int port) {
    return 'Debug: listening on port $port';
  }

  @override
  String get joinTitle => 'घर से जुड़ें';

  @override
  String get joinSub =>
      'घर के किसी व्यक्ति से अपने फ़ोन में आमंत्रण खोलने को कहें। फिर उनका QR कोड स्कैन करें या उनका भेजा फ़्रेज़ टाइप करें।';

  @override
  String get joinYourName => 'आपका नाम';

  @override
  String get joinNameRequired =>
      'पहले अपना नाम जोड़ें — परिवार को आप इसी नाम से दिखेंगे।';

  @override
  String get joinScanTitle => 'QR कोड स्कैन करें';

  @override
  String get joinScanSub =>
      'पास होने पर सबसे तेज़ तरीका। एक ही Wi-Fi या इंटरनेट दोनों पर काम करता है।';

  @override
  String get joinPhraseTitle => 'जॉइन फ़्रेज़ टाइप करें';

  @override
  String get joinPhraseSub =>
      'जैसे 47-mango-river-tulip — जब उन्होंने इसे WhatsApp पर भेजा हो, तो यह आसान रहता है।';

  @override
  String get phraseSub =>
      'एक संख्या और तीन शब्द, जो उनके फ़ोन की आमंत्रण स्क्रीन पर दिखते हैं।';

  @override
  String get phraseField => 'जॉइन फ़्रेज़';

  @override
  String get phraseHint => '47-mango-river-tulip';

  @override
  String get phraseNote =>
      'स्पेस भी चलेगा: ‘47 mango river tulip’। यह फ़्रेज़ एक बार काम करता है और 10 मिनट में समाप्त हो जाता है।';

  @override
  String get phraseConnect => 'कनेक्ट करें';

  @override
  String get phraseBadFormat =>
      'यह सही नहीं लग रहा। इसमें एक संख्या और तीन शब्द होने चाहिए, जैसे 47-mango-river-tulip।';

  @override
  String get phraseBadWord =>
      'इनमें से एक शब्द फ़्रेज़ सूची में नहीं है — स्पेलिंग जांचें।';

  @override
  String get debugPort => 'Debug port';

  @override
  String get scanTitle => 'QR कोड स्कैन करें';

  @override
  String get scanHint => 'उनके फ़ोन पर: प्रोफ़ाइल → घर → किसी को आमंत्रित करें';

  @override
  String get scanTypeInstead => 'इसके बजाय फ़्रेज़ टाइप करें';

  @override
  String get scanNote =>
      '🔒 कैमरा सिर्फ़ कोड पढ़ने के लिए इस्तेमाल होता है। कुछ भी रिकॉर्ड नहीं होता।';

  @override
  String get scanDenied =>
      'स्कैन करने के लिए कैमरे की अनुमति दें, या फ़्रेज़ टाइप करें।';

  @override
  String get scanOpenSettings => 'सेटिंग्स खोलें';

  @override
  String get scanTorch => 'टॉर्च';

  @override
  String get whoTheir => 'उनका';

  @override
  String whoName(String name) {
    return '$name का';
  }

  @override
  String get connectEyebrow => 'जुड़ रहे हैं';

  @override
  String connectEyebrowHome(String home) {
    return 'जुड़ रहे हैं · $home';
  }

  @override
  String get connectTitle => 'कनेक्ट हो रहा है…';

  @override
  String connectWelcome(String home) {
    return '$home में आपका स्वागत है';
  }

  @override
  String get connectFailed => 'जुड़ने में कोई रुकावट आ गई';

  @override
  String stepFindActive(String who) {
    return 'इस Wi-Fi पर $who फ़ोन खोजा जा रहा है…';
  }

  @override
  String stepFindDone(String who) {
    return 'इस Wi-Fi पर $who फ़ोन मिल गया';
  }

  @override
  String get stepCodeActive => 'कोड जांचा जा रहा है…';

  @override
  String get stepCodeDone => 'कोड मिल गया · कनेक्शन एन्क्रिप्टेड है';

  @override
  String stepApproveActive(String inviter) {
    return '$inviter की मंज़ूरी का इंतज़ार है…';
  }

  @override
  String stepApproveSas(String inviter, String emojis) {
    return 'जांचें कि $inviter के फ़ोन पर $emojis दिख रहा है';
  }

  @override
  String stepApproveDone(String inviter, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'एडमिन',
      'other': 'सदस्य',
    });
    return '$inviter ने आपको $_temp0 के रूप में मंज़ूरी दी';
  }

  @override
  String stepCopyActive(int pct) {
    return 'घर का डेटा कॉपी हो रहा है… $pct%';
  }

  @override
  String stepCopyDone(int n) {
    return '$n आइटम कॉपी हुए · अब आप सिंक में हैं';
  }

  @override
  String successBody(String names) {
    return 'आप $names के साथ जुड़ गए हैं। अब बदलाव आपके फ़ोनों के बीच सिंक होंगे।';
  }

  @override
  String goHome(String home) {
    return '$home पर जाएं';
  }

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get useDifferentCode => 'दूसरा कोड इस्तेमाल करें';

  @override
  String get finishLater => 'बाद में पूरा करें';

  @override
  String get finishLaterNote =>
      'आप पहले ही जुड़ चुके हैं — कॉपी अगली बार जारी रहेगी।';

  @override
  String get stoppedSnack => 'रोका गया। कुछ भी साझा नहीं हुआ।';

  @override
  String joinedSnack(String home, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'एडमिन',
      'other': 'सदस्य',
    });
    return 'आप $home में $_temp0 के रूप में जुड़ गए';
  }

  @override
  String errNotFound(String who) {
    return '$who फ़ोन मिल नहीं सका';
  }

  @override
  String errNotFoundHelp(String inviter) {
    return 'सुझाव: $inviter के फ़ोन पर आमंत्रण स्क्रीन खुली रखें, और पक्का करें कि दोनों फ़ोन में Wi-Fi या मोबाइल डेटा चालू है। फ़्रेज़ 10 मिनट तक मान्य रहता है।';
  }

  @override
  String get errWrongCode => 'फ़्रेज़ मेल नहीं खाया';

  @override
  String errWrongCodeHelp(String inviter) {
    return '$inviter से फ़्रेज़ दोबारा जांचें — 3 ग़लत प्रयासों के बाद यह काम करना बंद कर देता है और उन्हें नया बनाना होगा।';
  }

  @override
  String get errExpired =>
      'यह फ़्रेज़ समाप्त हो गया है या पहले ही इस्तेमाल हो चुका है। नया फ़्रेज़ मांगें।';

  @override
  String errDeclined(String inviter) {
    return '$inviter ने अनुरोध अस्वीकार कर दिया';
  }

  @override
  String errDeclinedHelp(String inviter) {
    return 'अगर यह ग़लती से हुआ हो, तो $inviter से फिर से कोशिश करने को कहें।';
  }

  @override
  String errVersion(String inviter) {
    return '$inviter का इल्लम अलग वर्ज़न का है। Play Store से दोनों ऐप अपडेट करें, फिर कोशिश करें।';
  }

  @override
  String get errCopy => 'कॉपी बीच में रुक गई';

  @override
  String setupBanner(int pct) {
    return 'सेटअप पूरा हो रहा है… $pct% — परिवार के किसी फ़ोन पर इल्लम खुला रखें';
  }

  @override
  String get agoNow => 'अभी';

  @override
  String agoMinutes(int m) {
    return '$m मिनट पहले';
  }

  @override
  String agoHours(int h) {
    return '$h घंटे पहले';
  }

  @override
  String agoDays(int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$d दिन पहले',
      one: '1 दिन पहले',
    );
    return '$_temp0';
  }

  @override
  String get syncTagOnlyThisPhone => 'सिर्फ़ इस फ़ोन पर';

  @override
  String syncTagJustNow(String name) {
    return '$name के साथ अभी सिंक हुआ';
  }

  @override
  String syncTagLast(String ago) {
    return 'आखिरी सिंक $ago';
  }

  @override
  String syncTagLabel(String text) {
    return '$text। सिंक विवरण खोलें';
  }

  @override
  String get syncNotYet => 'अभी तक सिंक नहीं हुआ';

  @override
  String get todayOffline => 'ऑफ़लाइन — बदलाव बाद में सिंक होंगे';

  @override
  String get syncCardAllInSync => 'सभी फ़ोन सिंक में हैं';

  @override
  String syncCardBehind(int k) {
    String _temp0 = intl.Intl.pluralLogic(
      k,
      locale: localeName,
      other: '$k फ़ोन अपडेट नहीं हैं',
      one: '1 फ़ोन अपडेट नहीं है',
    );
    return '$_temp0';
  }

  @override
  String syncCardLastSynced(String ago) {
    return 'आखिरी सिंक $ago';
  }

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get syncing => 'सिंक हो रहा है…';

  @override
  String get syncedSnack => 'अभी उपलब्ध फ़ोनों के साथ सिंक हो गया';

  @override
  String get syncNoPeers => 'अभी परिवार का कोई फ़ोन उपलब्ध नहीं है';

  @override
  String syncRowTheirs(String name, String model) {
    return '$name का $model';
  }

  @override
  String get syncOnWifiNow => 'अभी इसी Wi-Fi पर';

  @override
  String syncSyncedAgo(String ago) {
    return 'सिंक हुआ: $ago';
  }

  @override
  String syncNotForDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n दिनों से सिंक नहीं हुआ',
      one: '1 दिन से सिंक नहीं हुआ',
    );
    return '$_temp0';
  }

  @override
  String syncMissing(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: ' · आपके $n बदलाव बाकी हैं',
      one: ' · आपका 1 बदलाव बाकी है',
    );
    return '$_temp0';
  }

  @override
  String get syncClockWrong =>
      'आपके फ़ोन की घड़ी ग़लत लग रही है — सिंक में दिक्कत आ सकती है';

  @override
  String get syncWifiBlocked =>
      'हो सकता है आपका Wi-Fi फ़ोनों को आपस में जुड़ने से रोक रहा हो — इसके बजाय इंटरनेट से सिंक हो रहा है।';

  @override
  String syncUpdateNeeded(String name) {
    return '$name के साथ सिंक जारी रखने के लिए इल्लम अपडेट करें';
  }

  @override
  String get profileInSync => '✓ सिंक में है';

  @override
  String profileOneBehind(String name) {
    return '$name का फ़ोन पीछे है';
  }

  @override
  String profileManyBehind(int n) {
    return '$n फ़ोन पीछे हैं';
  }

  @override
  String get notifOutOfSync =>
      'इल्लम 3 दिनों से आपके परिवार के साथ सिंक नहीं हुआ है। अपडेट होने के लिए एक ही Wi-Fi पर ऐप खोलें।';

  @override
  String get notifTodoAssignedTitle => 'आपको एक काम सौंपा गया';

  @override
  String notifTodoAssignedBody(String title, String name) {
    return '$title · $name की ओर से';
  }

  @override
  String get notifTodoDoneTitle => 'काम पूरा चिह्नित किया गया';

  @override
  String notifTodoDoneBody(String title, String name) {
    return '$title · $name ने पूरा किया';
  }

  @override
  String notifJoinedTitle(String name, String home) {
    return '$name $home में जुड़े';
  }

  @override
  String get notifJoinedBody => 'उनका फ़ोन अब इस घर से सिंक होता है।';

  @override
  String syncLabPort(int port) {
    return 'पोर्ट $port पर सुन रहा है';
  }

  @override
  String get syncLabPeers => 'साथी डिवाइस';

  @override
  String get syncLabVector => 'मेरा वर्ज़न वेक्टर';

  @override
  String get syncLabConnectLocal => '127.0.0.1 से कनेक्ट करें';

  @override
  String homeGoneRemoved(String home) {
    return 'अब आप $home में नहीं हैं';
  }

  @override
  String homeGoneDeleted(String home, String name) {
    return '$name ने $home को हटा दिया';
  }

  @override
  String get homeGoneOk => 'ठीक है';

  @override
  String memberRemovedNewKey(String name) {
    return '$name को हटाया गया · घर की नई कुंजी बाकी लोगों को भेज दी गई';
  }

  @override
  String leaveChooseAdminLead(String home) {
    return 'आप अकेले एडमिन हैं। आपके जाने के बाद $home की देखरेख के लिए किसी को चुनें।';
  }

  @override
  String get leaveWaiting => 'छोड़ रहे हैं… परिवार के किसी फ़ोन का इंतज़ार है';

  @override
  String get leaveRemoveNow =>
      'अभी इस फ़ोन से हटाएं — जब यह फ़ोन अगली बार परिवार के किसी फ़ोन से जुड़ेगा तब उन्हें सूचना मिल जाएगी';

  @override
  String deleteDone(String home) {
    return '$home हटा दिया गया। बाकी फ़ोन सिंक होने पर इसे मिटा देंगे।';
  }

  @override
  String get opIgnoredRoleChanged => 'किसी ने पहले ही आपकी भूमिका बदल दी है।';

  @override
  String get inviteTipSecondAdmin =>
      'सुझाव: एक दूसरा एडमिन भी बनाएं, ताकि घर कभी बिना एडमिन के न अटके।';

  @override
  String inviteBackupNow(String home) {
    return '$home का अभी बैकअप लें';
  }

  @override
  String backupHealthOk(Object ago, Object provider, Object name) {
    return '$provider पर बैकअप: $ago · $name द्वारा';
  }

  @override
  String get backupOnlyOnPhone => 'सिर्फ़ इस फ़ोन पर — कोई दूसरी जगह जोड़ें';

  @override
  String get backupNoRecoveryReady => 'रिकवरी के लिए तैयार कोई बैकअप नहीं';

  @override
  String backupNoBackupDays(int n) {
    return '$n दिनों से कोई बैकअप नहीं';
  }

  @override
  String backupThisPhoneOn(Object provider) {
    return 'इस फ़ोन से बैकअप लिया जा रहा है · $provider';
  }

  @override
  String backupAlso(Object name, Object provider, Object ago) {
    return 'साथ ही: $name भी $provider पर बैकअप लेते हैं ($ago)';
  }

  @override
  String get backupNoAdminHint =>
      'अभी किसी एडमिन के पास बैकअप नहीं है — अगर सभी एडमिन फ़ोन खो जाएं, तो रीस्टोर करने पर सभी लोग सदस्य के रूप में वापस आएंगे।';

  @override
  String get backupProviderFolderShort => 'एक फ़ोल्डर';

  @override
  String get backupJustNow => 'अभी-अभी';

  @override
  String backupAttention(Object reason) {
    return 'बैकअप पर ध्यान दें — $reason';
  }

  @override
  String backupReasonAuth(Object provider) {
    return 'बैकअप जारी रखने के लिए $provider में फिर से साइन इन करें।';
  }

  @override
  String backupReasonFull(Object provider) {
    return '$provider भर गया है — जगह खाली करें या कोई दूसरी जगह चुनें।';
  }

  @override
  String get backupErrNoPermission =>
      'उस फ़ोल्डर में सेव करने की अनुमति नहीं है';

  @override
  String backupStatusStale(int n) {
    return '$n दिनों से बैकअप नहीं हुआ';
  }

  @override
  String get backupTitle => 'बैकअप';

  @override
  String backupProfileRow(Object provider, Object frequency, Object ago) {
    return 'बैकअप — $provider · $frequency · पिछला $ago';
  }

  @override
  String get backupProfileNotSetUp => 'बैकअप — सेट नहीं है';

  @override
  String get backupDaily => 'रोज़ाना';

  @override
  String get backupWeekly => 'साप्ताहिक';

  @override
  String get backupMonthly => 'मासिक';

  @override
  String get notifBackupAttention => 'बैकअप पर ध्यान देना ज़रूरी है';

  @override
  String get notifBackupAttentionSub => 'सिर्फ़ तब जब बैकअप काम करना बंद कर दे';

  @override
  String backupHeroTitle(Object home) {
    return '$home को सुरक्षित रखें';
  }

  @override
  String get backupHeroLead =>
      'इल्लम का अपना कोई क्लाउड नहीं है। अगर घर के सभी फ़ोन खो जाएं, तो बैकअप ही वापस पाने का एकमात्र रास्ता है।';

  @override
  String get backupPromise1Title => 'इस फ़ोन से निकलने से पहले लॉक हो जाता है';

  @override
  String get backupPromise1 =>
      'यह सिर्फ़ आपके पासवर्ड से एन्क्रिप्ट होता है। आपके क्लाउड को सिर्फ़ एक लॉक की हुई फ़ाइल दिखती है।';

  @override
  String get backupPromise2Title => 'अपने आप चलता है';

  @override
  String get backupPromise2 =>
      'हर हफ़्ते चार्जिंग के समय Wi-Fi पर। हम आपको तभी बताएँगे जब यह काम करना बंद करे।';

  @override
  String get backupPromise3Title => 'सब कुछ वापस लाता है';

  @override
  String get backupPromise3 =>
      'लिस्ट, स्टाफ़, हाज़िरी, सैलरी, खाना और खर्च, साथ ही आपकी रिकवरी कुंजी — ताकि नए फ़ोन पर भी आप अपनी मौजूदा भूमिका के साथ वापस आ सकें।';

  @override
  String get backupWhere => 'बैकअप कहाँ सेव हों?';

  @override
  String get backupGroupSignIn => 'साइन इन';

  @override
  String get backupGroupServer => 'आपका अपना सर्वर';

  @override
  String get backupGroupDevice => 'इस फ़ोन पर';

  @override
  String get backupDontSee => 'आपकी सेवा नहीं दिख रही?';

  @override
  String get backupDontSeeBody =>
      'आपकी सेवा नहीं दिख रही? Proton Drive और MEGA बाद में आएँगे। iCloud, Box, Terabox और JioCloud को Android ऐप से नहीं जोड़ा जा सकता — यदि आपकी सेवा WebDAV देती है तो उसका उपयोग करें, या इस फ़ोन का कोई फ़ोल्डर चुनें।';

  @override
  String backupAlsoIn(Object home, Object name, Object provider, Object ago) {
    return '$home में $name भी $provider पर बैकअप लेते हैं ($ago)।';
  }

  @override
  String get backupArrivesP19 => 'P19 में आएगा';

  @override
  String get backupArrivesP20 => 'P20 में आएगा';

  @override
  String get backupProvFolder => 'इस फ़ोन या किसी अन्य ऐप का फ़ोल्डर';

  @override
  String get backupProvFolderSub =>
      'SD कार्ड, USB ड्राइव, या फ़ोल्डर देने वाला कोई क्लाउड ऐप';

  @override
  String get backupProvGdrive => 'Google Drive';

  @override
  String get backupProvGdriveSub => 'साइन इन · आपके Drive में छिपा ऐप फ़ोल्डर';

  @override
  String get backupProvOnedrive => 'OneDrive';

  @override
  String get backupProvOnedriveSub => 'साइन इन · Apps › Illam';

  @override
  String get backupProvDropbox => 'Dropbox';

  @override
  String get backupProvDropboxSub => 'साइन इन · Apps › Illam';

  @override
  String get backupProvPcloud => 'pCloud';

  @override
  String get backupProvPcloudSub => 'साइन इन · ऐप फ़ोल्डर · EU या US क्षेत्र';

  @override
  String get backupProvNextcloud => 'Nextcloud';

  @override
  String get backupProvNextcloudSub => 'आपका अपना या होस्ट किया गया Nextcloud';

  @override
  String get backupProvWebdav => 'WebDAV';

  @override
  String get backupProvWebdavSub =>
      'ownCloud, Synology, QNAP, Koofr, Yandex Disk, कोई भी WebDAV';

  @override
  String get backupProvS3 => 'S3-संगत';

  @override
  String get backupProvS3Sub =>
      'AWS S3, Backblaze B2, Wasabi, Cloudflare R2, MinIO';

  @override
  String get backupProvSftp => 'SFTP';

  @override
  String get backupProvSftpSub => 'घर का NAS या आपका अपना सर्वर';

  @override
  String get backupChecking => 'जाँच हो रही है… एक टेस्ट फ़ाइल लिखी है';

  @override
  String get backupErrUnreachable => 'उस सर्वर से संपर्क नहीं हो सका';

  @override
  String get backupLocalCopy => 'लोकल कॉपी — फ़ोन खोने पर मिट जाएगी';

  @override
  String get backupPwTitle => 'बैकअप पासवर्ड सेट करें';

  @override
  String get backupPwField => 'बैकअप पासवर्ड';

  @override
  String get backupPwConfirm => 'पासवर्ड की पुष्टि करें';

  @override
  String get backupPwTooShort => 'बहुत छोटा';

  @override
  String get backupPwOkay => 'ठीक है';

  @override
  String get backupPwStrong => 'मज़बूत';

  @override
  String get backupPwSuggest => 'सुझाव दें';

  @override
  String get backupPwWarning =>
      'हम इस पासवर्ड को रीसेट नहीं कर सकते। इसके बिना बैकअप नहीं खुल पाएँगे। इसे अपने पासवर्ड मैनेजर में सेव करें या कहीं लिख लें।';

  @override
  String get backupPwSaved => 'मैंने यह पासवर्ड सुरक्षित जगह सेव कर लिया है';

  @override
  String get backupPwSave => 'पासवर्ड सेव करें और बैकअप लें';

  @override
  String get backupPwMismatch => 'दोनों पासवर्ड मेल नहीं खाते।';

  @override
  String get backupPwMissing =>
      'अभी कोई बैकअप नहीं है। शुरू करने के लिए बैकअप पासवर्ड सेट करें।';

  @override
  String backupStatusOk(Object ago) {
    return 'बैकअप हुआ · $ago';
  }

  @override
  String backupStatusRunning(int pct) {
    return 'बैकअप हो रहा है… $pct%';
  }

  @override
  String backupStatusFailed(Object reason) {
    return 'पिछला बैकअप विफल रहा — $reason';
  }

  @override
  String get backupStatusUnchanged => 'पिछले बैकअप के बाद कोई बदलाव नहीं';

  @override
  String backupNext(Object when, Object conditions) {
    return 'अगला: $when · $conditions';
  }

  @override
  String get backupOnWifi => 'Wi-Fi पर';

  @override
  String get backupWhileCharging => 'चार्जिंग के समय';

  @override
  String get backupNow => 'अभी बैकअप लें';

  @override
  String get backupWhereGo => 'बैकअप कहाँ सेव होते हैं';

  @override
  String backupPlacesCount(int k) {
    return '3 में से $k';
  }

  @override
  String backupDestLast(Object ago, int k) {
    return 'पिछला: $ago · $k रखे गए';
  }

  @override
  String get backupDisconnect => 'डिस्कनेक्ट करें';

  @override
  String get backupStayThere => 'वहाँ पहले से मौजूद बैकअप वहीं रहेंगे।';

  @override
  String get backupAddPlace => '＋ एक और जगह जोड़ें';

  @override
  String get backupSchedule => 'शेड्यूल';

  @override
  String get backupHowOften => 'कितनी बार';

  @override
  String get backupWifiOnly => 'केवल Wi-Fi पर';

  @override
  String get backupWifiOnlySub => 'मोबाइल डेटा कभी उपयोग नहीं करता';

  @override
  String get backupCharging => 'केवल चार्जिंग के समय';

  @override
  String get backupChargingSub => 'आमतौर पर रात में';

  @override
  String get backupKeep => 'हाल के बैकअप रखें';

  @override
  String backupKeepN(int n) {
    return '$n बैकअप';
  }

  @override
  String get backupKeepSub =>
      'सफल बैकअप के बाद पुराने बैकअप उस जगह से हटा दिए जाते हैं।';

  @override
  String backupProgressNotif(Object home) {
    return '$home का बैकअप हो रहा है…';
  }

  @override
  String get backupLocalTag => 'लोकल कॉपी';

  @override
  String get backupPwRow => 'बैकअप पासवर्ड';

  @override
  String backupPwRowSub(Object date) {
    return 'सेट किया: $date · इस फ़ोन पर सेव है';
  }

  @override
  String get backupPwChangeTitle => 'बैकअप पासवर्ड बदलें';

  @override
  String get backupPwChangeNote =>
      'नए बैकअप में नया पासवर्ड लगेगा। पुराने बैकअप खोलने के लिए पुराना पासवर्ड ही चाहिए।';

  @override
  String get backupPwChangeSave => 'नया पासवर्ड सेव करें';

  @override
  String get backupCheck => 'बैकअप जाँचें';

  @override
  String get backupCheckSub =>
      'सबसे नया बैकअप खोलकर जाँचता है कि वह ठीक काम कर रहा है';

  @override
  String backupCheckOk(int n, Object size) {
    return 'सबसे नया बैकअप ठीक खुल रहा है · $n आइटम · $size';
  }

  @override
  String get backupDamaged =>
      'यह बैकअप खराब हो गया है — कोई पुराना बैकअप आज़माएँ।';

  @override
  String get backupCheckUnreachable =>
      'बैकअप वाली जगह से संपर्क नहीं हो सका — बाद में फिर कोशिश करें।';

  @override
  String get backupRecent => 'हाल के बैकअप';

  @override
  String backupRecentRow(Object ago, Object size, Object place) {
    return '$ago · $size · $place';
  }

  @override
  String get backupRecentEmpty => 'अभी कोई बैकअप नहीं है।';

  @override
  String get backupKits => 'रिकवरी कुंजियाँ';

  @override
  String backupKitRow(Object name, Object model) {
    return '$name का $model';
  }

  @override
  String get backupKitThisPhone => 'यह फ़ोन';

  @override
  String backupKitSub(Object date, Object name, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'एडमिन',
      'other': 'सदस्य',
    });
    return 'बनी: $date · $name को $_temp0 के रूप में रीस्टोर करती है';
  }

  @override
  String get backupKitTurnOff => 'बंद करें';

  @override
  String backupKitOffTitle(Object name) {
    return '$name की रिकवरी कुंजी बंद करें?';
  }

  @override
  String backupKitOffLead(Object name, Object home) {
    return 'इससे बने बैकअप अभी भी खोले जा सकते हैं, लेकिन केवल एक अलग कॉपी के रूप में — वे $name को वापस $home में नहीं जोड़ सकते। अगले बैकअप पर $name का फ़ोन एक नई कुंजी बना लेगा।';
  }

  @override
  String get backupKitKeep => 'रखें';

  @override
  String get backupKitDead =>
      'नया बैकअप बनाएँ — पुरानी रिकवरी कुंजी अब काम नहीं करती।';

  @override
  String backupFinePrint(Object home, String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'एडमिन',
      'other': 'सदस्य',
    });
    return 'बैकअप में आपकी रिकवरी कुंजी शामिल होती है। फ़ाइल और पासवर्ड वाला कोई भी व्यक्ति $home को $_temp0 के रूप में रीस्टोर कर सकता है — पासवर्ड को गुप्त रखें।';
  }

  @override
  String get debugDamageBackup => 'Write a damaged copy of the latest backup';

  @override
  String get debugFolderOffPhone => 'Count folders as off-phone';

  @override
  String get restoreTitle => 'बैकअप से रीस्टोर करें';

  @override
  String get restoreSub => 'चुनें कि आपका बैकअप कहाँ है।';

  @override
  String get restoreNote =>
      '🔒 आपका बैकअप इसी फ़ोन पर खोला जाता है। इल्लम को कुछ भी नहीं भेजा जाता।';

  @override
  String get restorePickTitle => 'बैकअप चुनें';

  @override
  String restoreFoundIn(Object provider, Object account) {
    return '$provider में मिला · $account';
  }

  @override
  String restoreVault(Object vault) {
    return 'घर का बैकअप · $vault';
  }

  @override
  String restoreRow(Object date, Object size) {
    return '$date · $size';
  }

  @override
  String get restoreTagKit => 'रिकवरी कुंजी';

  @override
  String get restoreTagData => 'केवल डेटा';

  @override
  String restoreOlder(int n) {
    return 'पुराने बैकअप ($n)';
  }

  @override
  String get restoreEmpty =>
      'यहाँ इल्लम का कोई बैकअप नहीं मिला — जाँच लें कि आपने सही अकाउंट या फ़ोल्डर चुना है।';

  @override
  String get restoreChooseAnother => 'दूसरी जगह चुनें';

  @override
  String get restoreUnlockTitle => 'यह बैकअप अनलॉक करें';

  @override
  String get restoreUnlocking => 'अनलॉक हो रहा है…';

  @override
  String get restoreWrongPw =>
      'गलत पासवर्ड — पासवर्ड में बड़े-छोटे अक्षरों का ध्यान रखें।';

  @override
  String restoreHeaderCard(
    Object home,
    Object homeId,
    Object date,
    Object model,
    Object name,
  ) {
    return '$home · $homeId · $date · $model ($name) से';
  }

  @override
  String get restoreStepDownload => 'डाउनलोड हो रहा है';

  @override
  String get restoreStepUnlock => 'अनलॉक हो रहा है';

  @override
  String get restoreStepCheck => 'घर का इतिहास जाँच रहे हैं';

  @override
  String get restoreStepSetup => 'यह फ़ोन सेट कर रहे हैं';

  @override
  String restoreWelcome(Object home) {
    return '$home में फिर से स्वागत है';
  }

  @override
  String restoreOthersNote(Object home) {
    return '$home में मौजूद अन्य फ़ोनों पर दिखेगा कि आपने नए फ़ोन पर रीस्टोर किया है।';
  }

  @override
  String restoreKeepBackingUp(Object provider) {
    return '$provider पर बैकअप जारी रखें';
  }

  @override
  String restoreGo(Object home) {
    return '$home पर जाएँ';
  }

  @override
  String restoreAlreadyHere(Object home) {
    return '$home पहले से इस फ़ोन पर है।';
  }

  @override
  String get restoreOpen => 'खोलें';

  @override
  String get restoreDownloadFail =>
      'डाउनलोड नहीं हो सका — अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String restoreBanner(Object date, Object home) {
    return '$date को बने बैकअप से रीस्टोर हुआ। $home के बाकी हिस्से से जुड़ रहे हैं…';
  }

  @override
  String restoreDeadKit(Object date, Object home) {
    return 'इस बैकअप की रिकवरी कुंजी $date को बंद कर दी गई थी। $home के किसी एडमिन से आपको आमंत्रित करने को कहें।';
  }

  @override
  String get restoreSeparateCopy => 'अलग कॉपी के रूप में रखें';

  @override
  String get restoreRemoveFromPhone => 'इस फ़ोन से हटाएँ';

  @override
  String restoreSeparateName(Object home, Object date) {
    return '$home ($date को रीस्टोर)';
  }

  @override
  String restoreOtherAdmin(Object name, Object home) {
    return '$name ने बैकअप से नए फ़ोन पर $home को रीस्टोर किया';
  }

  @override
  String get restoreKeep => 'रखें';

  @override
  String get restoreRemove => 'हटाएँ';

  @override
  String get bkSrvErrAuth => 'गलत यूज़रनेम या ऐप पासवर्ड';

  @override
  String get bkSrvErrBucket => 'बकेट नहीं मिला';

  @override
  String get bkSrvErrOther =>
      'यह काम नहीं किया — जानकारी जाँचें और फिर कोशिश करें।';

  @override
  String get bkSrvErrHttps => 'https:// से शुरू होने वाला पता दर्ज करें';

  @override
  String get bkSrvErrHostKeyChanged =>
      'इस सर्वर का फ़िंगरप्रिंट बदल गया है। यदि आपने सर्वर नहीं बदला है, तो कनेक्ट न करें।';

  @override
  String get bkSrvConnect => 'कनेक्ट करें';

  @override
  String get bkSrvTrustTitle => 'इस सर्वर पर भरोसा करें?';

  @override
  String bkSrvTrustLead(Object host) {
    return '$host से पहली बार कनेक्ट हो रहे हैं। जाँच लें कि यह फ़िंगरप्रिंट आपके सर्वर वाले फ़िंगरप्रिंट से मेल खाता है।';
  }

  @override
  String get bkSrvTrust => 'भरोसा करें';

  @override
  String get bkSrvWebdavTitle => 'WebDAV';

  @override
  String get bkSrvServerAddress => 'सर्वर पता';

  @override
  String get bkSrvUsername => 'यूज़रनेम';

  @override
  String get bkSrvAppPassword => 'ऐप पासवर्ड';

  @override
  String get bkSrvWebdavHint =>
      'ownCloud, Synology, QNAP, Koofr, Yandex Disk, pCloud और किसी भी WebDAV सर्वर के साथ काम करता है। मुख्य पासवर्ड के बजाय ऐप पासवर्ड का उपयोग करें।';

  @override
  String bkSrvAccount(Object user, Object host) {
    return '$user @ $host';
  }

  @override
  String get bkSrvNextcloudTitle => 'Nextcloud';

  @override
  String get bkSrvNextcloudHint =>
      'हम ब्राउज़र में आपका Nextcloud लॉगिन खोलेंगे। वहाँ इल्लम को मंज़ूरी दें — इसे अपना अलग ऐप पासवर्ड मिलता है जिसे आप कभी भी रद्द कर सकते हैं।';

  @override
  String get bkSrvNextcloudAccessNote =>
      'यह ऐप पासवर्ड आपके पूरे Nextcloud अकाउंट तक पहुँच सकता है। केवल बैकअप के लिए एक अलग Nextcloud यूज़र बनाना ज़्यादा सुरक्षित है।';

  @override
  String get bkSrvContinueInBrowser => 'ब्राउज़र में आगे बढ़ें';

  @override
  String get bkSrvOpeningLogin => 'आपका Nextcloud लॉगिन खुल रहा है…';

  @override
  String get bkSrvApproveTitle => 'अपने ब्राउज़र में मंज़ूरी दें';

  @override
  String bkSrvApproveLead(Object host) {
    return '$host में लॉग इन करें और इल्लम के लिए \'Grant access\' पर टैप करें। फिर यहाँ वापस आएँ।';
  }

  @override
  String get bkSrvWaitingApproval => 'मंज़ूरी की प्रतीक्षा है…';

  @override
  String get bkSrvS3Title => 'S3-संगत';

  @override
  String get bkSrvService => 'सेवा';

  @override
  String get bkSrvPresetAws => 'AWS';

  @override
  String get bkSrvPresetB2 => 'Backblaze B2';

  @override
  String get bkSrvPresetWasabi => 'Wasabi';

  @override
  String get bkSrvPresetR2 => 'Cloudflare R2';

  @override
  String get bkSrvPresetMinio => 'MinIO';

  @override
  String get bkSrvPresetOther => 'अन्य';

  @override
  String get bkSrvRegion => 'रीजन';

  @override
  String get bkSrvEndpoint => 'एंडपॉइंट';

  @override
  String get bkSrvBucket => 'बकेट';

  @override
  String get bkSrvAccessKeyId => 'एक्सेस की ID';

  @override
  String get bkSrvSecretKey => 'सीक्रेट एक्सेस की';

  @override
  String get bkSrvS3Hint =>
      'ऐसी कुंजी बनाएँ जो केवल इस बकेट में लिख सके। फ़ाइलें illam/ फ़ोल्डर में जाएँगी।';

  @override
  String bkSrvS3Account(Object bucket, Object service) {
    return '$bucket · $service';
  }

  @override
  String get bkSrvSftpTitle => 'SFTP';

  @override
  String get bkSrvHost => 'होस्ट';

  @override
  String get bkSrvPort => 'पोर्ट';

  @override
  String get bkSrvPassword => 'पासवर्ड';

  @override
  String get bkSrvFolder => 'फ़ोल्डर';

  @override
  String get bkSrvSignInWith => 'इसके साथ साइन इन करें';

  @override
  String get bkSrvAuthPassword => 'पासवर्ड';

  @override
  String get bkSrvAuthKey => 'इस फ़ोन पर बनी कुंजी';

  @override
  String get bkSrvKeyHint =>
      'इस कुंजी को सर्वर पर इस यूज़र की authorized_keys फ़ाइल में जोड़ें, फिर \'कनेक्ट करें\' पर टैप करें।';

  @override
  String get bkSrvCopyKey => 'कुंजी कॉपी करें';

  @override
  String get bkSrvKeyCopied => 'कुंजी कॉपी हो गई';

  @override
  String get bkSrvSftpAccessNote =>
      'सुझाव: ऐसा सर्वर यूज़र ज़्यादा सुरक्षित होता है जो केवल अपना फ़ोल्डर देख सके।';

  @override
  String bkSrvSftpAccount(Object user, Object host, Object port) {
    return '$user@$host:$port';
  }

  @override
  String get bkSrvSignInAgain => 'फिर से साइन इन करें';

  @override
  String get bkCloudGdriveAccess =>
      'आपके Google Drive के एक छिपे ऐप फ़ोल्डर में अपना डेटा देख, बना और हटा सकता है। यह आपकी अन्य फ़ाइलें नहीं देख सकता।';

  @override
  String get bkCloudGdriveWhere => 'आपके Drive में छिपा ऐप फ़ोल्डर';

  @override
  String bkCloudConnected(Object provider) {
    return '$provider से जुड़ गया';
  }

  @override
  String bkCloudSignedInAgain(Object provider) {
    return '$provider में फिर से साइन इन हो गया';
  }

  @override
  String get bkCloudSignInAgainSub =>
      'यदि बैकअप में साइन-इन समाप्त होने का संदेश दिखे, तो इसका उपयोग करें';

  @override
  String get bkCloudExpiredRow => 'साइन-इन समाप्त — फिर से साइन इन करें';

  @override
  String bkCloudNotConfigured(Object provider) {
    return 'यह बिल्ड अभी $provider के लिए सेट नहीं है।';
  }

  @override
  String bkCloudSignInFailed(Object provider) {
    return '$provider में साइन इन नहीं हो सका — फिर कोशिश करें।';
  }

  @override
  String get bkCloudDropboxAccess =>
      'केवल Apps › Illam में फ़ाइलें पढ़ और लिख सकता है। यह आपकी अन्य फ़ाइलें नहीं देख सकता।';

  @override
  String get bkCloudOnedriveAccess =>
      'केवल अपने फ़ोल्डर Apps › Illam में फ़ाइलें पढ़ और लिख सकता है। यह आपकी अन्य फ़ाइलें नहीं देख सकता।';

  @override
  String get bkCloudAppsFolder => 'Apps › Illam';

  @override
  String get bkCloudOrgApproval =>
      'इस OneDrive का उपयोग करने से पहले आपके संगठन को इल्लम को मंज़ूरी देनी होगी। अपने IT एडमिन से कहें, या कोई दूसरी जगह चुनें।';

  @override
  String get bkCloudPcloudAccess =>
      'केवल अपने ऐप फ़ोल्डर में फ़ाइलें पढ़ और लिख सकता है।';

  @override
  String get bkCloudPcloudWhere => 'ऐप फ़ोल्डर · EU या US क्षेत्र';

  @override
  String bkCloudPcloudAccount(Object email, Object region) {
    return '$email · $region';
  }

  @override
  String get debugBackupLab => 'Backup lab';

  @override
  String get debugGoogleSilent => 'Google silent sign-in now';

  @override
  String get debugExpireTokens => 'Expire Dropbox/OneDrive tokens';

  @override
  String get debugBreakTokens => 'Break Dropbox/OneDrive refresh token';

  @override
  String get debugResultOk => 'ok';

  @override
  String get debugResultNeedsSignIn => 'needs sign-in';

  @override
  String get debugAdd200Items => 'Add 200 test items';

  @override
  String get remoteSyncTitle => 'रिमोट सिंक';

  @override
  String get remoteSyncExperimental => 'प्रयोगात्मक';

  @override
  String get remoteSyncToggleTitle => 'रिमोट सिंक (प्रयोगात्मक)';

  @override
  String get remoteSyncToggleSub =>
      'अपने खुद के Firebase प्रोजेक्ट के ज़रिए एंड-टू-एंड एन्क्रिप्टेड अपडेट साझा करें';

  @override
  String get remoteSyncOffTitle => 'अपना खुद का Firebase उपयोग करें';

  @override
  String get remoteSyncOffBody =>
      'डिफ़ॉल्ट रूप से इल्लम केवल घर के Wi-Fi पर सिंक करता है। अपना मुफ़्त Firebase प्रोजेक्ट जोड़ने के लिए रिमोट सिंक चालू करें, ताकि परिवार के फ़ोन मोबाइल डेटा पर भी सिंक कर सकें — बिना किसी डेवलपर सर्वर के और एंड-टू-एंड एन्क्रिप्शन के साथ।';

  @override
  String get remoteSyncStatusTitle => 'Firebase रिले';

  @override
  String remoteSyncStatusConnected(Object projectId) {
    return 'जुड़ा हुआ · $projectId';
  }

  @override
  String remoteSyncStatusLastSynced(Object ago) {
    return 'पिछला सिंक · $ago';
  }

  @override
  String get remoteSyncStatusNever => 'चालू · अभी सिंक नहीं हुआ';

  @override
  String get remoteSyncStatusNeedsSetup => 'चालू · नीचे Firebase विवरण जोड़ें';

  @override
  String get remoteSyncStatusOff => 'बंद · केवल घर का Wi-Fi';

  @override
  String remoteSyncStatusError(Object projectId) {
    return 'ध्यान दें · $projectId';
  }

  @override
  String get remoteSyncSyncNow => 'अभी सिंक करें';

  @override
  String get remoteSyncSyncing => 'सिंक हो रहा है…';

  @override
  String remoteSyncSyncedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'रिमोट सिंक अपडेट हुआ ($count आइटम)',
      one: 'रिमोट सिंक अपडेट हुआ (1 आइटम)',
    );
    return '$_temp0';
  }

  @override
  String get remoteSyncSyncedNone => 'रिमोट रिले पहले से अपडेट है';

  @override
  String get remoteSyncShareFamily => 'परिवार से साझा करें';

  @override
  String get remoteSyncGuideTitle => 'अपना Firebase प्रोजेक्ट कैसे सेटअप करें';

  @override
  String get remoteSyncGuideStep1 =>
      '1. console.firebase.google.com पर एक मुफ़्त Firebase प्रोजेक्ट बनाएँ और अपना प्रोजेक्ट ID व Web API की देखने के लिए एक Web app (</>) जोड़ें।';

  @override
  String get remoteSyncGuideStep2 =>
      '2. Authentication → Sign-in method में जाकर Anonymous साइन-इन चालू करें।';

  @override
  String get remoteSyncGuideStep3 =>
      '3. Firestore Database में जाकर डेटाबेस बनाएँ, Rules खोलें और इल्लम के सुरक्षा नियम पेस्ट करें।';

  @override
  String get remoteSyncGuideStep4 =>
      '4. नीचे अपनी कॉन्फ़िगरेशन दर्ज करें, कनेक्शन जाँचें और परिवार के फ़ोनों के साथ QR कोड साझा करें।';

  @override
  String get remoteSyncCopyRules => 'सुरक्षा नियम कॉपी करें';

  @override
  String get remoteSyncRulesCopied => 'सुरक्षा नियम कॉपी हो गए';

  @override
  String get remoteSyncShowRules => 'सुरक्षा नियम देखें';

  @override
  String get remoteSyncHideRules => 'सुरक्षा नियम छिपाएँ';

  @override
  String get remoteSyncConfigTitle => 'Firebase कॉन्फ़िगरेशन';

  @override
  String get remoteSyncConfigLead =>
      'अपने प्रोजेक्ट का विवरण दर्ज करें, या Firebase Console से firebaseConfig स्निपेट पेस्ट करें।';

  @override
  String get remoteSyncPasteConfig => 'कॉन्फ़िग पेस्ट करें';

  @override
  String get remoteSyncScanQr => 'QR स्कैन करें';

  @override
  String get remoteSyncPasteSheetTitle => 'Firebase कॉन्फ़िग पेस्ट करें';

  @override
  String get remoteSyncPasteSheetLead =>
      'firebaseConfig JS/JSON स्निपेट या इल्लम रिमोट सिंक लिंक पेस्ट करें।';

  @override
  String get remoteSyncPasteFieldLabel => 'कॉन्फ़िग स्निपेट या लिंक';

  @override
  String get remoteSyncApplyConfig => 'फ़ील्ड भरें';

  @override
  String get remoteSyncConfigApplied => 'Firebase फ़ील्ड भर गए';

  @override
  String get remoteSyncConfigNotFound =>
      'पेस्ट किए गए टेक्स्ट में projectId और apiKey नहीं मिले';

  @override
  String get remoteSyncProjectIdLabel => 'प्रोजेक्ट ID';

  @override
  String get remoteSyncProjectIdHint => 'my-family-illam';

  @override
  String get remoteSyncApiKeyLabel => 'Web API की';

  @override
  String get remoteSyncApiKeyHint => 'AIzaSy...';

  @override
  String get remoteSyncShowApiKey => 'API की दिखाएँ';

  @override
  String get remoteSyncHideApiKey => 'API की छिपाएँ';

  @override
  String get remoteSyncDatabaseIdLabel => 'डेटाबेस ID (वैकल्पिक)';

  @override
  String get remoteSyncDatabaseIdHint => '(default)';

  @override
  String get remoteSyncErrProjectEmpty =>
      'अपना Firebase प्रोजेक्ट ID दर्ज करें';

  @override
  String get remoteSyncErrProjectInvalid =>
      'केवल छोटे अंग्रेज़ी अक्षर, अंक और हाइफ़न का उपयोग करें';

  @override
  String get remoteSyncErrKeyEmpty => 'अपनी Firebase Web API की दर्ज करें';

  @override
  String get remoteSyncErrKeyInvalid => 'Web API की का फ़ॉर्मैट जाँचें';

  @override
  String get remoteSyncErrDbInvalid =>
      '(default) रहने दें या छोटे अंग्रेज़ी अक्षर, अंक और हाइफ़न का उपयोग करें';

  @override
  String get remoteSyncTestBtn => 'कनेक्शन जाँचें';

  @override
  String get remoteSyncTestingBtn => 'जाँच हो रही है…';

  @override
  String get remoteSyncTestOk =>
      'कनेक्शन ठीक है — Anonymous Auth और Firestore नियम सत्यापित हो गए।';

  @override
  String get remoteSyncSaveBtn => 'सेव और कनेक्ट करें';

  @override
  String get remoteSyncSavingBtn => 'सेव हो रहा है…';

  @override
  String get remoteSyncSavedSnack => 'Firebase कॉन्फ़िगरेशन सेव हो गई';

  @override
  String get remoteSyncRemoveBtn => 'Firebase कॉन्फ़िग हटाएँ';

  @override
  String get remoteSyncRemoveTitle => 'Firebase कॉन्फ़िग हटाएँ?';

  @override
  String get remoteSyncRemoveBody =>
      'यह फ़ोन रिमोट सिंक बंद कर देगा और सेव किए गए Firebase विवरण हटा देगा। फ़ोन में मौजूद घर का डेटा सुरक्षित रहेगा।';

  @override
  String get remoteSyncRemoveConfirm => 'हटाएँ';

  @override
  String get remoteSyncShareTitle => 'Firebase सेटअप साझा करें';

  @override
  String get remoteSyncShareLead =>
      'दूसरे पारिवारिक फ़ोन पर रिमोट सिंक चालू करने के बाद यह QR कोड स्कैन करें।';

  @override
  String get remoteSyncShareWarning =>
      'इसे केवल इस घर के परिवारजनों के साथ साझा करें — आपके प्रोजेक्ट ID और API की वाला कोई भी व्यक्ति आपके Firebase प्रोजेक्ट के अनाम रिले का उपयोग कर सकता है।';

  @override
  String get remoteSyncCopyShareLink => 'सेटअप लिंक कॉपी करें';

  @override
  String get remoteSyncShareLinkCopied => 'सेटअप लिंक कॉपी हो गया';

  @override
  String get remoteSyncScanTitle => 'रिमोट सिंक QR स्कैन करें';

  @override
  String get remoteSyncScanHint =>
      'अपने परिवार के सदस्य के फ़ोन पर दिख रहे रिमोट सिंक QR कोड की ओर कैमरा करें।';

  @override
  String get remoteSyncScanInvalid =>
      'यह QR कोड इल्लम रिमोट सिंक कॉन्फ़िग नहीं है';

  @override
  String get remoteSyncErrInvalidApiKey =>
      'Firebase ने Web API की अस्वीकार कर दी।';

  @override
  String get remoteSyncErrAnonDisabled =>
      'Firebase Authentication → Sign-in method में जाकर Anonymous साइन-इन चालू करें।';

  @override
  String get remoteSyncErrPermissionDenied =>
      'Firestore ने अनुमति नहीं दी। Firestore → Rules में इल्लम के सुरक्षा नियम पेस्ट करें।';

  @override
  String get remoteSyncErrDatabaseNotFound =>
      'Firestore डेटाबेस या प्रोजेक्ट ID नहीं मिला।';

  @override
  String get remoteSyncErrQuota =>
      'Firebase का दैनिक Spark कोटा पूरा हो गया है। बाद में फिर कोशिश करें।';

  @override
  String get remoteSyncErrNetwork =>
      'Firebase से संपर्क नहीं हो सका। अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String get remoteSyncErrOther =>
      'Firebase सिंक विफल रहा — अपनी कॉन्फ़िगरेशन और नियम जाँचें।';

  @override
  String get remoteSyncCardTitle => 'रिमोट सिंक';

  @override
  String get remoteSyncProfileSubOff => 'बंद';

  @override
  String get remoteSyncProfileSubNeedsSetup => 'सेटअप बाकी है';

  @override
  String remoteSyncProfileSubConnected(Object projectId) {
    return 'जुड़ा हुआ · $projectId';
  }

  @override
  String get remoteSyncNoHomeKey => 'घर की एन्क्रिप्शन कुंजी अभी तैयार नहीं है';

  @override
  String get remoteSyncCombinedSynced => 'सिंक हुए फ़ोन और रिमोट रिले';

  @override
  String get gmailImportTitle => 'Gmail इनवॉइस इम्पोर्ट';

  @override
  String get gmailImportExperimental => 'प्रयोगात्मक';

  @override
  String get gmailImportCardTitle => 'Gmail इनवॉइस इम्पोर्ट';

  @override
  String get gmailImportToggleTitle => 'Gmail इनवॉइस इम्पोर्ट';

  @override
  String get gmailImportToggleSubtitle =>
      'अपने हिसाब में जोड़ने से पहले Zepto, Blinkit, Amazon और Flipkart के ईमेल और PDF बिल स्कैन करके ड्राफ़्ट में लाएँ।';

  @override
  String get gmailImportOffHint =>
      'अपना Google Desktop App OAuth क्लाइंट जोड़ने, स्टोर ऑर्डर ईमेल स्कैन करने और ड्राफ़्ट खर्चों की समीक्षा करने के लिए Gmail बिल आयात चालू करें।';

  @override
  String get gmailImportProfileSubOff => 'बंद';

  @override
  String get gmailImportProfileSubNeedsSetup => 'सेटअप ज़रूरी';

  @override
  String gmailImportProfileSubConnected(Object email) {
    return 'जुड़ा हुआ · $email';
  }

  @override
  String gmailImportProfileSubDrafts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'समीक्षा के लिए $count ड्राफ़्ट',
      one: 'समीक्षा के लिए 1 ड्राफ़्ट',
    );
    return '$_temp0';
  }

  @override
  String get gmailImportStatusTitle => 'Gmail कनेक्शन';

  @override
  String get gmailImportStatusNeedsOAuth =>
      'नीचे अपनी डेस्कटॉप OAuth क्लाइंट ID और सीक्रेट जोड़ें।';

  @override
  String get gmailImportStatusReadyToConnect =>
      'OAuth क्रेडेंशियल सहेजे गए — अब अपना Gmail खाता जोड़ें।';

  @override
  String gmailImportStatusConnected(Object email) {
    return '$email के रूप में जुड़ा हुआ';
  }

  @override
  String get gmailImportStatusConnectedFallback => 'Gmail से जुड़ा हुआ';

  @override
  String gmailImportLastScan(Object ago) {
    return 'पिछला स्कैन $ago';
  }

  @override
  String get gmailImportNeverScanned => 'अभी तक स्कैन नहीं किया गया';

  @override
  String get gmailImportConnectBtn => 'Gmail जोड़ें';

  @override
  String get gmailImportConnectingBtn => 'Google साइन-इन की प्रतीक्षा…';

  @override
  String get gmailImportCancelAuthBtn => 'साइन-इन रद्द करें';

  @override
  String get gmailImportScanNowBtn => 'ईमेल स्कैन करें';

  @override
  String get gmailImportScanningBtn => 'स्कैन हो रहा है…';

  @override
  String get gmailImportDisconnectBtn => 'Gmail डिस्कनेक्ट करें';

  @override
  String get gmailImportDisconnectedSnack => 'Gmail खाता डिस्कनेक्ट किया गया';

  @override
  String gmailImportConnectedSnack(Object email) {
    return '$email से जुड़ गया';
  }

  @override
  String get gmailImportWindowLabel => 'स्कैन अवधि';

  @override
  String gmailImportWindowDays(Object days) {
    return 'पिछले $days दिन';
  }

  @override
  String gmailImportScanSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gmail से $count नए ड्राफ़्ट खर्च जोड़े गए',
      one: 'Gmail से 1 नया ड्राफ़्ट खर्च जोड़ा गया',
      zero: 'ईमेल स्कैन किए — कोई नया बिल नहीं मिला',
    );
    return '$_temp0';
  }

  @override
  String get gmailImportGuideTitle =>
      'अपना Google डेस्कटॉप OAuth कैसे सेटअप करें';

  @override
  String get gmailImportGuideStep1 =>
      '1. console.cloud.google.com खोलें, एक प्रोजेक्ट बनाएँ और Gmail API चालू करें।';

  @override
  String get gmailImportGuideStep2 =>
      '2. Google Auth platform → Audience में, अपना Gmail पता Test user के रूप में जोड़ें।';

  @override
  String get gmailImportGuideStep3 =>
      '3. Clients → Create client में जाकर Desktop app चुनें (लोकल लूपबैक साइन-इन के लिए ज़रूरी)।';

  @override
  String get gmailImportGuideStep4 =>
      '4. डाउनलोड की गई JSON (या क्लाइंट ID और सीक्रेट) नीचे पेस्ट करें, \'Gmail जोड़ें\' पर टैप करें और दर्ज करने से पहले ड्राफ़्ट की समीक्षा करें।';

  @override
  String get gmailImportOAuthTitle => 'Google डेस्कटॉप OAuth';

  @override
  String get gmailImportOAuthLead =>
      'आपके क्रेडेंशियल और Gmail टोकन इस फ़ोन पर एन्क्रिप्टेड रहते हैं।';

  @override
  String get gmailImportPasteJsonBtn => 'OAuth JSON पेस्ट करें';

  @override
  String get gmailImportPasteJsonTitle => 'OAuth क्लाइंट JSON पेस्ट करें';

  @override
  String get gmailImportPasteJsonLead =>
      'Google Cloud Console से डाउनलोड की गई Desktop app क्लाइंट JSON यहाँ पेस्ट करें।';

  @override
  String get gmailImportPasteJsonField => 'डेस्कटॉप ऐप JSON';

  @override
  String get gmailImportApplyJsonBtn => 'फ़ील्ड भरें';

  @override
  String get gmailImportJsonApplied => 'OAuth क्रेडेंशियल भर दिए गए';

  @override
  String get gmailImportClientIdLabel => 'क्लाइंट ID';

  @override
  String get gmailImportClientIdHint => '123456-abc.apps.googleusercontent.com';

  @override
  String get gmailImportClientSecretLabel => 'क्लाइंट सीक्रेट';

  @override
  String get gmailImportClientSecretHint => 'GOCSPX-...';

  @override
  String get gmailImportShowSecret => 'क्लाइंट सीक्रेट दिखाएँ';

  @override
  String get gmailImportHideSecret => 'क्लाइंट सीक्रेट छिपाएँ';

  @override
  String get gmailImportSaveOAuthBtn => 'क्रेडेंशियल सहेजें';

  @override
  String get gmailImportOAuthSavedSnack => 'OAuth क्रेडेंशियल सहेजे गए';

  @override
  String get gmailImportRemoveConfigBtn => 'OAuth और ड्राफ़्ट साफ़ करें';

  @override
  String get gmailImportRemoveTitle => 'Gmail आयात डेटा साफ़ करें?';

  @override
  String get gmailImportRemoveBody =>
      'इस फ़ोन पर सहेजे गए OAuth क्रेडेंशियल, टोकन और बकाया ड्राफ़्ट मिटा देता है। पहले से दर्ज खर्च \'पैसे\' में बने रहेंगे।';

  @override
  String get gmailImportRemoveConfirm => 'साफ़ करें';

  @override
  String get gmailImportPasteInvoiceBtn => 'बिल टेक्स्ट पेस्ट करें';

  @override
  String get gmailImportPasteInvoiceTitle => 'पेस्ट किए गए बिल को पढ़ें';

  @override
  String get gmailImportPasteInvoiceLead =>
      'Zepto, Blinkit, Amazon या Flipkart के ईमेल या PDF बिल का टेक्स्ट पेस्ट करके ऑफ़लाइन पार्सिंग टेस्ट करें या ऑर्डर आयात करें।';

  @override
  String get gmailImportPasteInvoiceField => 'ईमेल या बिल का टेक्स्ट';

  @override
  String get gmailImportParseToDraftBtn => 'ड्राफ़्ट बनाएँ';

  @override
  String get gmailImportPasteNotMatched =>
      'उस टेक्स्ट में Zepto, Blinkit, Amazon या Flipkart की कुल राशि नहीं मिली।';

  @override
  String gmailImportPasteAddedSnack(Object channel) {
    return 'ड्राफ़्ट खर्च बनाया गया ($channel)';
  }

  @override
  String gmailImportDraftsSectionTitle(Object count) {
    return 'ड्राफ़्ट खर्च ($count)';
  }

  @override
  String get gmailImportDraftsEmpty =>
      'कोई बकाया ड्राफ़्ट नहीं। Zepto, Blinkit, Amazon या Flipkart से खरीदारी के बाद अपना Gmail स्कैन करें।';

  @override
  String get gmailImportDraftBadge => 'ड्राफ़्ट';

  @override
  String get gmailImportDraftsMoneyNote =>
      'जब तक आप समीक्षा करके \'दर्ज करें\' पर टैप नहीं करते, तब तक यह खर्च या बजट में नहीं गिना जाता।';

  @override
  String get gmailImportReviewAllAction => 'इम्पोर्टर खोलें';

  @override
  String get gmailImportAccountItBtn => 'दर्ज करें';

  @override
  String get gmailImportAccountingBtn => 'दर्ज हो रहा है…';

  @override
  String get gmailImportDiscardBtn => 'हटाएँ';

  @override
  String get gmailImportEditDraftBtn => 'जाँचें';

  @override
  String gmailImportDraftItemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम निकाले गए',
      one: '1 आइटम निकाला गया',
      zero: 'केवल ऑर्डर की कुल राशि',
    );
    return '$_temp0';
  }

  @override
  String gmailImportReviewSheetTitle(Object channel) {
    return '$channel ड्राफ़्ट';
  }

  @override
  String get gmailImportSplitByItemLabel => 'हर आइटम अलग-अलग लिखें';

  @override
  String gmailImportSplitByItemSub(Object channel) {
    return '$channel का एक संयुक्त खर्च जोड़ने के लिए इसे बंद करें।';
  }

  @override
  String gmailImportFeesDiscountInfo(Object fees, Object discount) {
    return 'डिलीवरी/शुल्क $fees · छूट $discount (चुकाई कुल राशि से मिलान किया गया)';
  }

  @override
  String get gmailImportOrderTotalLabel => 'चुकाई कुल राशि';

  @override
  String gmailImportSelectedTotalLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'एंट्रियाँ',
      one: 'एंट्री',
    );
    return 'दर्ज करने के लिए ($count $_temp0)';
  }

  @override
  String gmailImportAccountedSnack(num count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खर्च दर्ज किए गए ($total)',
      one: '1 खर्च दर्ज किया गया ($total)',
    );
    return '$_temp0';
  }

  @override
  String get gmailImportNothingSelected =>
      'कम से कम एक 0 से अधिक राशि वाला आइटम चुनें या संयुक्त ऑर्डर योग पर स्विच करें।';

  @override
  String get gmailImportItemAmountInvalid =>
      'शामिल हर आइटम के लिए 0 से अधिक राशि दर्ज करें।';

  @override
  String gmailImportDuplicateWarning(Object date) {
    return '$date के आसपास ऐसा ही एक खर्च पहले से मौजूद है। आप इसे फिर भी दर्ज कर सकते हैं या यह ड्राफ़्ट हटा सकते हैं।';
  }

  @override
  String gmailImportOrderIdLabel(Object id) {
    return 'ऑर्डर $id';
  }

  @override
  String get gmailImportErrOAuthEmpty =>
      'Google Desktop App OAuth JSON पेस्ट करें या दोनों फ़ील्ड भरें।';

  @override
  String get gmailImportErrOAuthMalformed =>
      'उस इनपुट से क्लाइंट ID और सीक्रेट पढ़ा नहीं जा सका।';

  @override
  String get gmailImportErrWebClient =>
      'यह Web OAuth क्लाइंट है। Google Cloud Console में Desktop app क्लाइंट बनाएँ।';

  @override
  String get gmailImportErrInvalidClientId =>
      'क्लाइंट ID का प्रारूप जाँचें (अंत में .apps.googleusercontent.com होना चाहिए)।';

  @override
  String get gmailImportErrMissingSecret =>
      'अपना Google OAuth क्लाइंट सीक्रेट दर्ज करें।';

  @override
  String get gmailImportErrUnauthorized =>
      'Gmail सत्र समाप्त हो गया या एक्सेस रद्द कर दिया गया। Gmail फिर से जोड़ें।';

  @override
  String get gmailImportErrForbidden =>
      'Gmail ने एक्सेस अस्वीकार किया — सुनिश्चित करें कि Gmail API चालू है और आपका पता Test user के रूप में जुड़ा है।';

  @override
  String get gmailImportErrRateLimited =>
      'Gmail की सीमा पूरी हो गई है। कुछ देर बाद फिर कोशिश करें।';

  @override
  String get gmailImportErrNetwork =>
      'Google से संपर्क नहीं हो सका। अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String get gmailImportErrAuthUnsupported =>
      'Gmail ब्राउज़र साइन-इन के लिए Android या डेस्कटॉप ज़रूरी है; यहाँ टेस्ट करने के लिए बिल टेक्स्ट पेस्ट करें।';

  @override
  String get gmailImportErrAuthBrowser =>
      'Google साइन-इन के लिए ब्राउज़र नहीं खुल सका।';

  @override
  String get gmailImportErrAuthDenied =>
      'Google साइन-इन रद्द किया गया या अस्वीकार कर दिया गया।';

  @override
  String get gmailImportErrAuthTimeout =>
      'Google साइन-इन का समय समाप्त हो गया। फिर से कोशिश करने के लिए \'Gmail जोड़ें\' पर टैप करें।';

  @override
  String get gmailImportErrAuthOther =>
      'Google साइन-इन पूरा नहीं हुआ — अपनी डेस्कटॉप OAuth क्लाइंट सेटिंग्स जाँचें।';

  @override
  String get smsImportTitle => 'SMS खर्च आयात';

  @override
  String get smsImportExperimental => 'प्रयोगात्मक';

  @override
  String get smsImportCardTitle => 'SMS खर्च आयात';

  @override
  String get smsImportTagLabel => 'SMS';

  @override
  String get smsImportToggleTitle => 'SMS खर्च आयात';

  @override
  String get smsImportToggleSubtitle =>
      'हिसाब में जोड़ने से पहले बैंक, UPI और कार्ड भुगतान SMS को फ़ोन पर पहचानकर ड्राफ़्ट में रखें।';

  @override
  String get smsImportOffHint =>
      'फ़ोन पर लेन-देन अलर्ट स्कैन करने या बैकग्राउंड में भुगतान SMS अपने-आप पकड़ने के लिए SMS खर्च आयात चालू करें। जब तक आप \'दर्ज करें\' पर टैप नहीं करते, कुछ भी \'पैसे\' में नहीं जुड़ता।';

  @override
  String get smsImportProfileSubOff => 'बंद';

  @override
  String smsImportProfileSubDrafts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'समीक्षा के लिए $count ड्राफ़्ट',
      one: 'समीक्षा के लिए 1 ड्राफ़्ट',
    );
    return '$_temp0';
  }

  @override
  String get smsImportProfileSubAuto => 'ऑटो-कैप्चर चालू';

  @override
  String get smsImportProfileSubManual => 'मैन्युअल स्कैन';

  @override
  String get smsImportProfileSubPermission => 'अनुमति ज़रूरी';

  @override
  String get smsImportStatusTitle => 'SMS एक्सेस';

  @override
  String get smsImportStatusGranted =>
      'SMS अनुमति मिली हुई है — अलर्ट इसी फ़ोन पर रहते हैं।';

  @override
  String get smsImportStatusPartial =>
      'इनबॉक्स पढ़ने की अनुमति है — बैकग्राउंड कैप्चर के लिए SMS पाने की अनुमति दें।';

  @override
  String get smsImportStatusNeeded =>
      'इल्लम को इस फ़ोन पर लेन-देन वाले SMS अलर्ट पढ़ने की अनुमति दें।';

  @override
  String get smsImportStatusRestricted =>
      'Android ने SMS एक्सेस रोका है। साइडलोड किए गए ऐप में, App info → ⋮ → Allow restricted settings खोलें, फिर SMS चालू करें।';

  @override
  String get smsImportStatusUnsupported =>
      'SMS पढ़ना केवल Android पर उपलब्ध है; यहाँ टेस्ट करने के लिए \'SMS टेक्स्ट पेस्ट करें\' उपयोग करें।';

  @override
  String get smsImportGrantBtn => 'SMS अनुमति दें';

  @override
  String get smsImportOpenSettingsBtn => 'ऐप सेटिंग्स खोलें';

  @override
  String get smsImportAutoCaptureTitle => 'आने वाले SMS अपने-आप पकड़ें';

  @override
  String get smsImportAutoCaptureSub =>
      'नए बैंक, UPI और कार्ड भुगतान अलर्ट को अपने-आप ड्राफ़्ट में रखें।';

  @override
  String get smsImportWindowLabel => 'स्कैन अवधि';

  @override
  String smsImportWindowDays(Object days) {
    return 'पिछले $days दिन';
  }

  @override
  String smsImportLastScan(Object ago) {
    return 'पिछला स्कैन $ago';
  }

  @override
  String get smsImportNeverScanned => 'अभी तक स्कैन नहीं किया गया';

  @override
  String get smsImportScanNowBtn => 'SMS स्कैन करें';

  @override
  String get smsImportScanningBtn => 'स्कैन हो रहा है…';

  @override
  String smsImportScanSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'SMS से $count नए ड्राफ़्ट खर्च जोड़े गए',
      one: 'SMS से 1 नया ड्राफ़्ट खर्च जोड़ा गया',
      zero: 'SMS स्कैन किए — कोई नया भुगतान अलर्ट नहीं मिला',
    );
    return '$_temp0';
  }

  @override
  String get smsImportPasteBtn => 'SMS टेक्स्ट पेस्ट करें';

  @override
  String get smsImportPasteTitle => 'पेस्ट किया बैंक SMS पढ़ें';

  @override
  String get smsImportPasteLead =>
      'ड्राफ़्ट में निकालने की जाँच के लिए किसी भी भारतीय बैंक, UPI या कार्ड डेबिट SMS अलर्ट को पेस्ट करें।';

  @override
  String get smsImportPasteField => 'लेन-देन SMS टेक्स्ट';

  @override
  String get smsImportPasteNotMatched =>
      'इस संदेश में कोई पूरा हुआ डेबिट/खर्च नहीं मिला (OTP, क्रेडिट, प्रचार और कार्ड बिल भुगतान अनदेखे किए जाते हैं)।';

  @override
  String smsImportPasteAddedSnack(Object merchant) {
    return 'SMS ड्राफ़्ट बनाया गया ($merchant)';
  }

  @override
  String get smsImportDraftsEmpty =>
      'कोई बकाया SMS ड्राफ़्ट नहीं। अपना इनबॉक्स स्कैन करें या नए भुगतान अलर्ट के लिए ऑटो-कैप्चर चालू करें।';

  @override
  String get smsImportClearBtn => 'SMS आयात डेटा साफ़ करें';

  @override
  String get smsImportClearTitle => 'SMS आयात डेटा साफ़ करें?';

  @override
  String get smsImportClearBody =>
      'इस फ़ोन पर बकाया SMS ड्राफ़्ट और प्रोसेस किया गया इतिहास मिटा देता है और बैकग्राउंड SMS कैप्चर बंद कर देता है। पहले से दर्ज खर्च \'पैसे\' में बने रहेंगे।';

  @override
  String get smsImportClearConfirm => 'साफ़ करें';

  @override
  String get smsImportReviewTitle => 'SMS खर्च की समीक्षा करें';

  @override
  String smsImportAccountMeta(Object bank, Object when) {
    return '$bank · $when';
  }

  @override
  String get smsImportRawLabel => 'मूल SMS अंश';

  @override
  String smsImportGmailOverlapWarning(Object channel, Object date) {
    return '$date के आसपास इस राशि से मेल खाता एक बकाया Gmail ड्राफ़्ट ($channel) मौजूद है।';
  }

  @override
  String get smsImportErrAmount => '₹10,00,000 तक 0 से अधिक राशि दर्ज करें।';

  @override
  String get smsImportErrMerchant =>
      'यह भुगतान किसे या कहाँ किया गया, वह दर्ज करें।';

  @override
  String smsImportAccountedSnack(Object merchant, Object amount) {
    return '$merchant दर्ज किया गया ($amount)';
  }

  @override
  String get tripsTab => 'ट्रिप';

  @override
  String get tripsGenericTitle => 'सामान्य चेकलिस्ट';

  @override
  String tripsGenericSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामान्य आइटम · नई ट्रिप में अपने-आप कॉपी होते हैं',
      one: '1 सामान्य आइटम · नई ट्रिप में अपने-आप कॉपी होता है',
      zero: 'हर ट्रिप के लिए ज़रूरी आइटम जोड़ें',
    );
    return '$_temp0';
  }

  @override
  String get tripsGenericLead =>
      'यहाँ के आइटम हर नई ट्रिप में अपने-आप कॉपी हो सकते हैं ताकि ज़रूरी सामान कभी न छूटे।';

  @override
  String get tripsGenericAddHint =>
      'सामान्य आइटम जोड़ें (जैसे चार्जर, ID कार्ड)…';

  @override
  String get tripsGenericEmptyTitle => 'अभी कोई सामान्य आइटम नहीं';

  @override
  String get tripsGenericEmptyBody =>
      'हर ट्रिप से पहले जाँचने वाली ज़रूरी चीज़ें जोड़ें, या शुरुआती सूची लोड करें।';

  @override
  String get tripsLoadStarter => 'शुरुआती सूची लोड करें';

  @override
  String tripsStarterLoaded(int count) {
    return '$count शुरुआती आइटम जोड़े गए';
  }

  @override
  String get tripsStarterChargers => 'फ़ोन चार्जर और केबल';

  @override
  String get tripsStarterIds => 'ID कार्ड / टिकट';

  @override
  String get tripsStarterMedicines => 'दवाइयाँ और फ़र्स्ट एड';

  @override
  String get tripsStarterClothes => 'कपड़े और नहाने-धोने का सामान';

  @override
  String get tripsStarterWater => 'पानी की बोतलें और नाश्ता';

  @override
  String get tripsStarterKeys => 'घर की चाबियाँ';

  @override
  String get tripsStarterGas => 'गैस स्टोव बंद करें';

  @override
  String get tripsStarterLocks => 'खिड़कियाँ और दरवाज़े बंद करें';

  @override
  String get tripsNewTrip => 'नई ट्रिप';

  @override
  String get tripsNewTripTitle => 'नई ट्रिप';

  @override
  String get tripsEditTripTitle => 'ट्रिप संपादित करें';

  @override
  String get tripsNameLabel => 'ट्रिप का नाम';

  @override
  String get tripsNameHint => 'जैसे गोवा फ़ैमिली ट्रिप';

  @override
  String get tripsNameRequired => 'ट्रिप का नाम जोड़ें।';

  @override
  String get tripsStartDate => 'ट्रिप की तारीख़';

  @override
  String get tripsEndDate => 'वापसी की तारीख़ (वैकल्पिक)';

  @override
  String get tripsAddEndDate => 'वापसी की तारीख़ जोड़ें';

  @override
  String get tripsClearEndDate => 'वापसी की तारीख़ हटाएँ';

  @override
  String get tripsNoteLabel => 'नोट (वैकल्पिक)';

  @override
  String get tripsNoteHint => 'जैसे फ़्लाइट, ट्रेन या ठहरने का विवरण';

  @override
  String tripsIncludeGeneric(int count) {
    return 'सामान्य चेकलिस्ट शामिल करें ($count)';
  }

  @override
  String get tripsSaveTrip => 'ट्रिप जोड़ें';

  @override
  String get tripsSaveChanges => 'बदलाव सहेजें';

  @override
  String get tripsDeleteTrip => 'ट्रिप हटाएँ';

  @override
  String get tripsAdded => 'ट्रिप जोड़ी गई';

  @override
  String get tripsUpdated => 'ट्रिप अपडेट हुई';

  @override
  String get tripsDeleted => 'ट्रिप हटाई गई';

  @override
  String get tripsEmptyTitle => 'कोई ट्रिप तय नहीं है';

  @override
  String get tripsEmptyBody =>
      'तारीख़ के साथ ट्रिप तय करें और निकलने से पहले सभी आइटम जाँच लें।';

  @override
  String tripsPastHeader(int count) {
    return 'पिछली ट्रिप ($count)';
  }

  @override
  String get tripsReady => 'तैयार';

  @override
  String get tripsOngoing => 'ट्रिप पर';

  @override
  String get tripsPast => 'पिछली';

  @override
  String get tripsStartsToday => 'आज से शुरू';

  @override
  String get tripsStartsTomorrow => 'कल';

  @override
  String tripsInDays(int n) {
    return '$n दिन में';
  }

  @override
  String tripsCheckedCount(int done, int total) {
    return '$total में से $done जाँचे गए';
  }

  @override
  String get tripsNoItemsYet => 'चेकलिस्ट में अभी कोई आइटम नहीं';

  @override
  String get tripsAllReadyTitle => 'आपकी ट्रिप की पूरी तैयारी हो गई!';

  @override
  String tripsRemainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'निकलने से पहले $count आइटम बाकी',
      one: 'निकलने से पहले 1 आइटम बाकी',
    );
    return '$_temp0';
  }

  @override
  String get tripsAddItemHint => 'निकलने से पहले जाँचने के लिए आइटम जोड़ें…';

  @override
  String get tripsAddItem => 'आइटम जोड़ें';

  @override
  String get tripsItemAdded => 'आइटम जोड़ा गया';

  @override
  String tripsItemChecked(Object title) {
    return 'जाँचा गया: $title';
  }

  @override
  String tripsItemUnchecked(Object title) {
    return 'वापस रखा गया: $title';
  }

  @override
  String tripsCheckedSection(int count) {
    return 'जाँचे गए ($count)';
  }

  @override
  String get tripsImportGeneric => 'सामान्य चेकलिस्ट आयात करें';

  @override
  String tripsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामान्य आइटम जोड़े गए',
      one: '1 सामान्य आइटम जोड़ा गया',
      zero: 'सभी सामान्य आइटम इस ट्रिप में पहले से हैं',
    );
    return '$_temp0';
  }

  @override
  String get tripsResetChecks => 'सभी निशान रीसेट करें';

  @override
  String get tripsChecksReset => 'चेकलिस्ट रीसेट हुई';

  @override
  String tripsCopyGenericBtn(int count) {
    return 'सामान्य चेकलिस्ट कॉपी करें ($count)';
  }

  @override
  String get tripsEditItemTitle => 'आइटम संपादित करें';

  @override
  String get tripsItemLabel => 'आइटम';

  @override
  String get tripsSaveToGeneric => 'सामान्य चेकलिस्ट में भी जोड़ें';

  @override
  String get tripsSavedToGeneric => 'सामान्य चेकलिस्ट में जोड़ा गया';

  @override
  String get tripsDeleteItem => 'आइटम हटाएँ';

  @override
  String get tripsItemDeleted => 'आइटम हटाया गया';

  @override
  String get tripsMoreActions => 'ट्रिप के और विकल्प';

  @override
  String get tripsEditTrip => 'ट्रिप संपादित करें';

  @override
  String get tripsNotFound => 'ट्रिप नहीं मिली';

  @override
  String get tripsTodaySection => 'आने वाली ट्रिप';

  @override
  String tripsTodayMeta(Object when, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left आइटम बाकी',
      one: '1 आइटम बाकी',
    );
    return '$when · $_temp0';
  }

  @override
  String get tripsOpenChecklist => 'चेकलिस्ट';

  @override
  String get moneyScanBill => 'बिल स्कैन करें';

  @override
  String get billScanSheetTitle => 'बिल स्कैन करें';

  @override
  String get billScanChooseHint =>
      'छपे हुए बिल की फ़ोटो लें, गैलरी से चुनें, या बिल टेक्स्ट पेस्ट करें। OCR आपके फ़ोन पर ऑफ़लाइन चलता है।';

  @override
  String get billScanTakePhoto => 'फ़ोटो लें';

  @override
  String get billScanFromGallery => 'गैलरी से चुनें';

  @override
  String get billScanPasteText => 'बिल टेक्स्ट पेस्ट करें';

  @override
  String get billScanPasteHint =>
      'आइटम और कीमतों वाली रसीद की पंक्तियाँ पेस्ट या टाइप करें';

  @override
  String get billScanExtractAction => 'आइटम निकालें';

  @override
  String get billScanScanning => 'बिल का टेक्स्ट ऑफ़लाइन पढ़ा जा रहा है...';

  @override
  String get billScanErrPermission =>
      'बिल की फ़ोटो लेने के लिए कैमरा अनुमति ज़रूरी है। आप गैलरी से भी फ़ोटो चुन सकते हैं।';

  @override
  String get billScanErrNoCamera =>
      'इस डिवाइस पर कोई कैमरा ऐप नहीं मिला। इसके बजाय गैलरी से फ़ोटो चुनें या टेक्स्ट पेस्ट करें।';

  @override
  String get billScanErrUnsupported =>
      'डिवाइस पर कैमरा OCR केवल Android पर उपलब्ध है। ऑफ़लाइन आइटम निकालने के लिए नीचे बिल टेक्स्ट पेस्ट करें।';

  @override
  String get billScanErrFailed =>
      'वह फ़ोटो पढ़ी नहीं जा सकी। साफ़ फ़ोटो दोबारा लें या टेक्स्ट पेस्ट करें।';

  @override
  String get billScanErrEmptyPaste =>
      'पहले कुछ बिल टेक्स्ट पेस्ट या टाइप करें।';

  @override
  String get billScanNoTextFound =>
      'पढ़ने योग्य टेक्स्ट नहीं मिला। 90° घुमाकर फिर स्कैन करें, या आइटम खुद जोड़ें।';

  @override
  String get billScanReviewTitle => 'स्कैन किए बिल की समीक्षा करें';

  @override
  String billScanConfidenceLabel(int percent) {
    return 'OCR सटीकता: $percent%';
  }

  @override
  String get billScanRotateRescan => '90° घुमाएँ और फिर स्कैन करें';

  @override
  String get billScanRawOcrShow => 'मूल OCR टेक्स्ट दिखाएँ';

  @override
  String get billScanRawOcrHide => 'मूल OCR टेक्स्ट छिपाएँ';

  @override
  String get billScanMerchantLabel => 'दुकान या व्यापारी';

  @override
  String get billScanMerchantHint => 'जैसे रिलायंस फ्रेश';

  @override
  String billScanModeSplit(int count) {
    return 'आइटम अनुसार बाँटें ($count)';
  }

  @override
  String get billScanModeSingle => 'एक कुल राशि';

  @override
  String get billScanSingleAmountLabel => 'बिल की कुल राशि';

  @override
  String get billScanItemsTitle => 'निकाले गए आइटम';

  @override
  String get billScanAddItem => '+ आइटम जोड़ें';

  @override
  String get billScanItemNameHint => 'आइटम का नाम';

  @override
  String get billScanItemAmountHint => 'राशि';

  @override
  String get billScanDeleteItemTooltip => 'आइटम हटाएँ';

  @override
  String billScanSummaryCompare(Object selected, Object billTotal) {
    return 'चयनित: $selected · बिल कुल: $billTotal';
  }

  @override
  String billScanSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खर्च सहेजें',
      one: '1 खर्च सहेजें',
    );
    return '$_temp0';
  }

  @override
  String get billScanSaveSingle => 'खर्च सहेजें';

  @override
  String get billScanErrNoItems =>
      'कम से कम एक आइटम चुनें जिसका सही नाम और 0 से अधिक राशि हो।';

  @override
  String get billScanErrAmount => '0 से अधिक सही राशि दर्ज करें।';

  @override
  String get billScanErrMerchant => 'दुकान या व्यापारी का नाम दर्ज करें।';

  @override
  String billScanSavedCount(int count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खर्च सहेजे गए ($total)',
      one: '1 खर्च सहेजा गया ($total)',
    );
    return '$_temp0';
  }

  @override
  String get profileLangSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get profileLangEnglish => 'English (अंग्रेज़ी)';

  @override
  String get profileLangTamil => 'தமிழ் (तमिल)';

  @override
  String get profileLangHindi => 'हिन्दी';

  @override
  String get profileLangBadgeTamil => 'தமிழ்';

  @override
  String get profileLangBadgeHindi => 'हिन्दी';

  @override
  String get spendCatGroceries => 'किराना';

  @override
  String get spendCatShopping => 'खरीदारी';

  @override
  String get spendCatStaff => 'स्टाफ़';

  @override
  String get spendCatUtilities => 'बिल व सेवाएँ';

  @override
  String get spendCatEatingOut => 'बाहर खाना';

  @override
  String get spendCatHomeCare => 'घर की देखभाल';

  @override
  String get spendCatOther => 'अन्य';

  @override
  String get whatsNewTitle => 'नया क्या है';

  @override
  String get whatsNewHistoryTitle => 'रिलीज़ नोट्स';

  @override
  String get whatsNewGotIt => 'ठीक है';

  @override
  String whatsNewVersionHeader(Object version) {
    return 'वर्ज़न $version';
  }

  @override
  String get whatsNewV171TodoDoneNotif =>
      'जब परिवार का कोई अन्य सदस्य आपका काम पूरा चिह्नित करता है, तो काम के मालिक को सूचना मिलती है।';

  @override
  String get whatsNewV171TodoWidgetMine =>
      '\'आज के काम\' होम-स्क्रीन विजेट अब केवल आपके काम दिखाता है, जबकि ऐप की \'आज\' स्क्रीन पर पूरे घर के काम पहले की तरह दिखते हैं।';

  @override
  String get whatsNewV170Changelog =>
      'अपडेट के बाद \'नया क्या है\' शीट अपने-आप रिलीज़ नोट्स दिखाती है — और प्रोफ़ाइल → वर्ज़न में कभी भी देखी जा सकती है।';

  @override
  String get whatsNewV170SpendWidget =>
      'एक टैप में खर्च जोड़ने, महीने के खर्च की झलक देखने और तुरंत बिल स्कैन करने के लिए नया \'पैसे खर्च\' होम-स्क्रीन विजेट।';

  @override
  String get whatsNewV170Languages =>
      'ऐप में तमिल और हिन्दी भाषाएँ जोड़ी गईं, जो अपने-आप आपके फ़ोन की भाषा चुनती हैं या प्रोफ़ाइल → भाषा से बदली जा सकती हैं।';

  @override
  String get whatsNewV160BillScan =>
      '\'पैसे\' में ऑफ़लाइन कैमरा बिल स्कैनर जो डिवाइस पर Tesseract OCR की मदद से दुकान, तारीख़ और हर आइटम की कीमत निकालता है।';

  @override
  String get whatsNewV150Trips =>
      '\'काम\' के तहत ट्रिप प्लानर, जिसमें ट्रिप की तारीख़ें, बार-बार काम आने वाली सामान्य चेकलिस्ट, निकलने से पहले की तैयारी और \'आज\' पर रेडीनेस कार्ड शामिल हैं।';

  @override
  String get whatsNewV140MoneyCharts =>
      '\'पैसे\' की कस्टम श्रेणियाँ, खर्च का विवरण दिखाने वाला टॉगल योग्य पाई चार्ट (श्रेणी, आइटम या व्यक्ति अनुसार), और समेटने योग्य ड्राफ़्ट।';

  @override
  String get whatsNewV132SmsParser =>
      'फ़ोन पर बैंक, क्रेडिट कार्ड, प्रीपेड कार्ड और UPI SMS से खर्च पढ़ने की क्षमता में सुधार।';

  @override
  String get whatsNewV131Routines =>
      '\'सफ़ाई\' का नाम बदलकर \'नियमित काम\' रखा गया है ताकि घर के रखरखाव का शेड्यूल स्वाभाविक रूप से शामिल हो सके।';

  @override
  String get whatsNewV130SmsImport =>
      '\'पैसे\' में एंट्री जोड़ने से पहले ड्राफ़्ट समीक्षा के साथ प्रयोगात्मक ऑफ़लाइन SMS खर्च आयात।';

  @override
  String get whatsNewV120GmailImport =>
      'ऑनलाइन किराने और रिटेल ऑर्डर के लिए प्रयोगात्मक Gmail बिल और PDF रसीद आयात।';

  @override
  String get widgetMoneyHeader => 'महीने का खर्च';

  @override
  String get widgetMoneyAdd => 'खर्च जोड़ें';

  @override
  String get widgetMoneyScan => 'स्कैन';

  @override
  String get widgetMoneyEmpty => 'इस महीने कोई खर्च दर्ज नहीं है।';

  @override
  String get widgetMoneyNoHome => 'अपना घर सेटअप करने के लिए इल्लम खोलें।';

  @override
  String widgetMoneyBudgetLeft(Object amount, Object budget) {
    return '$budget में से $amount बाकी';
  }

  @override
  String widgetMoneyBudgetOver(Object amount, Object budget) {
    return '$budget के बजट से $amount अधिक';
  }
}
