// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String greeting(String name) {
    return 'مرحباً $name 👋';
  }

  @override
  String get guest => 'زائر';

  @override
  String get readyToPlay => 'مستعد للعب؟';

  @override
  String get categories => 'الفئات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get popular => '🔥 الأكثر شعبية';

  @override
  String get friendsLeaderboard => '🏅 ترتيب الأصدقاء';

  @override
  String get guestBannerTitle => 'احفظ تقدمك!';

  @override
  String get guestBannerSubtitle =>
      'أنشئ حساباً لفتح نقاط الخبرة والسلسلة والترتيب.';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get dailyChallengeTag => 'التحدي اليومي';

  @override
  String get dailyChallengeTitle => 'اختبار مميز كل يوم';

  @override
  String get dailyChallengeSubtitle => '+30 نقطة خبرة إضافية · حافظ على سلسلتك';

  @override
  String get journeyTag => 'وضع المغامرة';

  @override
  String get journeyTitle => 'تسلّق مستويات الخريطة';

  @override
  String get journeySubtitle => 'افتح المستويات واجمع النجوم ⭐';

  @override
  String levelShort(int level) {
    return 'مستوى $level';
  }

  @override
  String quizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اختباراً',
      few: '$count اختبارات',
      two: 'اختباران',
      one: 'اختبار واحد',
      zero: 'لا اختبارات',
    );
    return '$_temp0';
  }

  @override
  String get language => 'اللغة';

  @override
  String get chooseLanguage => 'اختر لغتك';

  @override
  String get languageSystemNote => 'تنطبق أيضاً على محتوى الاختبارات والأسئلة.';

  @override
  String questionNumber(int number) {
    return 'السؤال $number';
  }

  @override
  String get skip => 'تخطّي ←';

  @override
  String get loadQuestionsError => 'تعذّر تحميل الأسئلة.';

  @override
  String get loadLevelError => 'تعذّر تحميل هذا المستوى.';

  @override
  String get invalidSession => 'جلسة غير صالحة. أعد المحاولة.';

  @override
  String get submitError => 'فشل الإرسال. تحقق من اتصالك.';

  @override
  String get calculatingResults => 'جارٍ حساب النتائج…';

  @override
  String get survivalTag => 'وضع البقاء';

  @override
  String get gameOver => 'انتهت اللعبة!';

  @override
  String survivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نجوت من $count سؤالاً',
      few: 'نجوت من $count أسئلة',
      two: 'نجوت من سؤالين',
      one: 'نجوت من سؤال واحد',
      zero: 'لم تنجُ من أي سؤال',
    );
    return '$_temp0';
  }

  @override
  String get seeResults => 'عرض النتائج';

  @override
  String get quit => 'خروج';

  @override
  String get quitGameTitle => 'الخروج من اللعبة؟';

  @override
  String get quitGameBody => 'سيضيع تقدمك.';

  @override
  String get keepPlaying => 'متابعة';

  @override
  String get journeyMapTitle => 'وضع المغامرة';

  @override
  String journeyLevelProgress(int current, int total) {
    return 'المستوى $current / $total';
  }

  @override
  String get journeyUnavailable => 'المغامرة غير متاحة';

  @override
  String get comeBackLater => 'عد لاحقاً';

  @override
  String levelsCount(int count) {
    return '🏁  $count مستوى';
  }

  @override
  String get play => 'العب';

  @override
  String bossShort(int level) {
    return 'زعيم $level';
  }

  @override
  String get resultPerfect => 'ممتاز!';

  @override
  String get resultGreat => 'أحسنت!';

  @override
  String get resultPassed => 'اجتزت المستوى';

  @override
  String get resultAlmost => 'اقتربت!';

  @override
  String bossLevelLabel(int level) {
    return 'زعيم · المستوى $level';
  }

  @override
  String levelLabel(int level) {
    return 'المستوى $level';
  }

  @override
  String get nextLevel => 'المستوى التالي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get replay => 'إعادة اللعب';

  @override
  String get viewMap => 'عرض الخريطة';

  @override
  String get score => 'النتيجة';

  @override
  String get correctLabel => 'صحيحة';

  @override
  String get trainingResultNote =>
      'وضع التدريب — لا تؤثر هذه النتيجة على نقاط خبرتك أو ترتيبك.';

  @override
  String get answerReview => 'مراجعة الإجابات';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get homeLabel => 'الرئيسية';

  @override
  String get viewChallenge => 'عرض التحدي';

  @override
  String get headlineOutstanding => 'مذهل! 🤩';

  @override
  String get headlineExcellent => 'ممتاز! 🎉';

  @override
  String get headlineGreat => 'أحسنت! 👏';

  @override
  String get headlineNotBad => 'ليس سيئاً! 👍';

  @override
  String get headlineKeepGoing => 'واصل! 💪';

  @override
  String get headlineTryAgain => 'حاول مجدداً! 🔄';

  @override
  String get yourAnswer => 'إجابتك';

  @override
  String get points => 'النقاط';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get reportQuestionAction => 'الإبلاغ عن خطأ';

  @override
  String get reportQuestionTitle => 'الإبلاغ عن هذا السؤال';

  @override
  String get reportReasonLabel => 'السبب';

  @override
  String get reasonWrongAnswer => 'الإجابة الصحيحة خاطئة';

  @override
  String get reasonAmbiguous => 'سؤال غامض أو سيئ الصياغة';

  @override
  String get reasonTypo => 'خطأ إملائي';

  @override
  String get reasonOutdated => 'معلومة قديمة';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get commentOptional => 'تعليق (اختياري)';

  @override
  String get sendReport => 'إرسال البلاغ';

  @override
  String get sendFailed => 'فشل الإرسال. حاول مرة أخرى.';

  @override
  String get allQuizzes => 'كل الاختبارات';

  @override
  String get searchQuizHint => 'ابحث عن اختبار…';

  @override
  String get loadingEllipsis => 'جارٍ التحميل…';

  @override
  String get allCategories => 'كل الفئات';

  @override
  String get difficulty => 'الصعوبة';

  @override
  String get diffEasy => 'سهل';

  @override
  String get diffMedium => 'متوسط';

  @override
  String get diffHard => 'صعب';

  @override
  String get allFilter => 'الكل';

  @override
  String get noQuizFound => 'لم يُعثر على اختبار';

  @override
  String get tryAnotherFilter => 'جرّب فلتراً أو بحثاً آخر';

  @override
  String get searchCategoryHint => 'ابحث عن فئة…';

  @override
  String noResultsFor(String query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String get loadQuizError => 'تعذّر تحميل الاختبار.';

  @override
  String get quizDetails => 'تفاصيل الاختبار';

  @override
  String get questions => 'الأسئلة';

  @override
  String get perQuestion => 'لكل سؤال';

  @override
  String get pointsPerQ => 'نقاط / سؤال';

  @override
  String get plays => 'مرات اللعب';

  @override
  String get ruleSelectOne => 'اختر إجابة واحدة لكل سؤال';

  @override
  String get ruleTimer => 'أجب قبل انتهاء الوقت';

  @override
  String rulePoints(int points) {
    return 'اكسب $points نقطة لكل إجابة صحيحة';
  }

  @override
  String get ruleReview => 'راجع الشروحات الكاملة بعد الاختبار';

  @override
  String get startQuiz => 'ابدأ الاختبار 🚀';

  @override
  String get tryAnotherDifficulty => 'جرّب مستوى صعوبة آخر';

  @override
  String get loadCategoriesError => 'تعذّر تحميل الفئات';

  @override
  String get noCategories => 'لا فئات';

  @override
  String get comeBackSoon => 'عد لاحقاً، محتوى جديد قادم قريباً';

  @override
  String get chooseMode => 'اختر الوضع';

  @override
  String get randomQuestions10 => '10 أسئلة عشوائية';

  @override
  String get questions10 => '10 أسئلة';

  @override
  String get gameModeLabel => 'وضع اللعب';

  @override
  String get modeClassic => 'الوضع الكلاسيكي';

  @override
  String get modeClassicDesc =>
      '10 أسئلة عشوائية · مؤقّت لكل سؤال · النتيجة بالنسبة المئوية';

  @override
  String get modeSurvival => 'وضع البقاء';

  @override
  String get modeSurvivalDesc =>
      '10 أسئلة · إجابة خاطئة واحدة وتنتهي اللعبة · مكافأة ×1.3';

  @override
  String get modeSpeed => 'جولة السرعة';

  @override
  String get modeSpeedDesc => '10 أسئلة · 5 ثوانٍ لكل سؤال · مكافأة خبرة ×1.5';

  @override
  String playInMode(String mode) {
    return 'العب $mode';
  }

  @override
  String get trainingMode => 'وضع التدريب';

  @override
  String get trainingSubtitle => 'اختر عدد الأسئلة · بلا رهانات';

  @override
  String get trainingSheetBody => 'العب دون التأثير على نقاطك أو ترتيبك.';

  @override
  String get questionCountLabel => 'عدد الأسئلة';

  @override
  String get startBtn => 'ابدأ';

  @override
  String get oneLife => 'حياة واحدة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllRead => 'قراءة الكل';

  @override
  String get noNotifications => 'لا إشعارات';

  @override
  String get friends => 'الأصدقاء';

  @override
  String get requestsTab => 'الطلبات';

  @override
  String get activityTab => 'النشاط';

  @override
  String get noFriendsYet => 'لا أصدقاء بعد';

  @override
  String get searchPlayersToAdd => 'ابحث عن لاعبين لإضافتهم!';

  @override
  String get addFriends => 'إضافة أصدقاء';

  @override
  String sinceLabel(String time) {
    return 'منذ $time';
  }

  @override
  String get noPendingRequests => 'لا طلبات معلّقة';

  @override
  String get noRecentActivity => 'لا نشاط حديث';

  @override
  String get removeFriend => 'حذف هذا الصديق';

  @override
  String get searchByNameHint => 'ابحث بالاسم أو @username…';

  @override
  String get noPlayerFound => 'لم يُعثر على لاعب';

  @override
  String get requestSent => 'أُرسل الطلب!';

  @override
  String get sentLabel => 'مُرسَل';

  @override
  String get receivedLabel => 'مُستلَم';

  @override
  String get addBtn => 'إضافة';

  @override
  String get modeClassicShort => 'كلاسيكي';

  @override
  String get modeSurvivalShort => 'البقاء';

  @override
  String get modeSpeedShort => 'جولة السرعة';
}
