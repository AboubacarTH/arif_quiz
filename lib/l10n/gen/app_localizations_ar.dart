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

  @override
  String get challengesTitle => 'التحديات';

  @override
  String get joinBtn => 'انضمام';

  @override
  String get createChallenge => 'إنشاء تحدٍّ';

  @override
  String get noChallengesYet => 'لا تحديات بعد';

  @override
  String get createOrJoin => 'أنشئ تحدياً أو انضم إلى واحد!';

  @override
  String get createBtn => 'إنشاء';

  @override
  String get myCreatedChallenges => 'التحديات التي أنشأتها';

  @override
  String get deleteBtn => 'حذف';

  @override
  String get joinedChallenges => 'التحديات المنضم إليها';

  @override
  String get deleteChallengeTitle => 'حذف التحدي؟';

  @override
  String deleteChallengeBody(String title) {
    return 'سيُحذف التحدي \"$title\" نهائياً.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get challengeDeleted => 'حُذف التحدي';

  @override
  String get deleteError => 'خطأ أثناء الحذف';

  @override
  String get stepSource => 'مصدر الأسئلة';

  @override
  String get stepPickCategory => 'اختر فئة';

  @override
  String get stepPickQuiz => 'اختر اختباراً';

  @override
  String get stepConfigure => 'إعداد التحدي';

  @override
  String get enterChallengeTitle => 'أدخل عنواناً للتحدي';

  @override
  String get createError => 'خطأ أثناء الإنشاء';

  @override
  String get srcQuizLabel => 'اختبار محدد';

  @override
  String get srcQuizDesc => '10 أسئلة من اختبار تختاره';

  @override
  String get srcCategoryLabel => 'حسب الفئة';

  @override
  String get srcCategoryDesc => '10 أسئلة عشوائية من كل اختبارات فئة ما';

  @override
  String get srcAllDesc => '10 أسئلة عشوائية من كل الاختبارات المتاحة';

  @override
  String get whereQuestionsFrom => 'من أين تأتي الأسئلة؟';

  @override
  String get noCategoryAvailable => 'لا فئة متاحة';

  @override
  String get noQuizInCategory => 'لا اختبار في هذه الفئة';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get challengeTitleLabel => 'عنوان التحدي';

  @override
  String get challengeTitleHint => 'مثال: من يعرف الطيران؟';

  @override
  String get creating => 'جارٍ الإنشاء…';

  @override
  String get createChallengeBtn => 'إنشاء التحدي';

  @override
  String get joinChallengeTitle => 'الانضمام إلى تحدٍّ';

  @override
  String get enterChallengeCode => 'أدخل رمز التحدي';

  @override
  String get codeHelp => 'الرمز المكوّن من 8 أحرف شاركه معك منشئ التحدي.';

  @override
  String get joinChallengeBtn => 'الانضمام إلى التحدي';

  @override
  String get challengeFound => 'عُثر على التحدي!';

  @override
  String byCreator(String name) {
    return 'بواسطة $name';
  }

  @override
  String get codeLengthError => 'يجب أن يتكون الرمز من 8 أحرف';

  @override
  String get rematchError => 'تعذّرت إعادة المباراة. حاول مجدداً.';

  @override
  String get rematch => 'إعادة المباراة';

  @override
  String get playThisChallenge => 'العب هذا التحدي';

  @override
  String get alreadyPlayed => 'لقد لعبت هذا التحدي بالفعل. راجع الترتيب أدناه.';

  @override
  String leaderboardCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أكمل $count',
      few: 'أكمل $count',
      two: 'أكمل 2',
      one: 'أكمل 1',
    );
    return 'الترتيب ($_temp0)';
  }

  @override
  String get nobodyCompleted => 'لم يُكمل أحد هذا التحدي بعد.';

  @override
  String pendingCount(int count) {
    return 'قيد الانتظار ($count)';
  }

  @override
  String get pendingLabel => 'قيد الانتظار';

  @override
  String get wrongPasswordOrNetwork => 'كلمة مرور خاطئة أو خطأ في الشبكة.';

  @override
  String get deleteAccountTitle => 'حذف الحساب؟';

  @override
  String get password => 'كلمة المرور';

  @override
  String get logoutTitle => 'تسجيل الخروج؟';

  @override
  String get logoutBody => 'ستحتاج إلى تسجيل الدخول مجدداً للوصول إلى حسابك.';

  @override
  String get logoutBtn => 'خروج';

  @override
  String get logOutAction => 'تسجيل الخروج';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get editBtn => 'تعديل';

  @override
  String rankLabel(int rank) {
    return 'المرتبة #$rank';
  }

  @override
  String nextLevelIn(int level, int xp) {
    return 'المستوى $level بعد $xp نقطة خبرة';
  }

  @override
  String get quizzesPlayed => 'الاختبارات الملعوبة';

  @override
  String get goodAnswers => 'إجابات صحيحة';

  @override
  String get accuracy => 'الدقة';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get bestStreak => 'أفضل سلسلة';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get unlockBadgesByPlaying => 'افتح الشارات باللعب';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeSystemDesc => 'يتبع سمة الجهاز';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeDarkDesc => 'واجهة ألعاب داكنة';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeLightDesc => 'واجهة مضيئة';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get noQuizPlayed => 'لم تلعب أي اختبار';

  @override
  String get playFirstQuiz => 'العب أول اختبار لترى نتائجك هنا!';

  @override
  String get playBtn => 'العب';

  @override
  String get adminPanel => 'لوحة الإدارة';

  @override
  String get deleteMyAccount => 'حذف حسابي';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get enterValidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get updateProfileFailed => 'تعذّر تحديث الملف الشخصي. حاول مجدداً.';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get yourNameHint => 'اسمك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get loadHistoryError => 'تعذّر تحميل السجل.';

  @override
  String get quizHistory => 'سجل الاختبارات';

  @override
  String get noAttemptsYet => 'لا محاولات بعد';

  @override
  String get attemptsAppearHere => 'العب اختباراً وستظهر نتائجك هنا.';

  @override
  String get refresh => 'تحديث';

  @override
  String pointsShort(int points) {
    return '+$points نقطة';
  }

  @override
  String get loadBadgesError => 'تعذّر تحميل الإنجازات.';

  @override
  String get progression => 'التقدم';

  @override
  String get alreadyPlayedToday => 'لقد لعبت اليوم بالفعل!';

  @override
  String get dailyChallengeScreenTitle => 'التحدي اليومي';

  @override
  String get noDailyToday => 'لا تحدي اليوم';

  @override
  String get comeBackTomorrow => 'عد غداً!';

  @override
  String get todaysChallengeTag => 'تحدي اليوم';

  @override
  String renewsIn(int h, int m) {
    return 'يتجدد بعد $hس $mد';
  }

  @override
  String get challengeCompleted => 'اكتمل التحدي!';

  @override
  String yourScoreGrade(String score, String grade) {
    return 'نتيجتك: $score% • التقدير $grade';
  }

  @override
  String get bonusXp30 => '⚡ +30 نقطة خبرة إضافية';

  @override
  String get takeChallenge => 'خض التحدي';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get welcomeBack => 'مرحباً\nبعودتك!';

  @override
  String get signInSubtitle => 'سجّل الدخول لمواصلة رحلتك في الاختبارات';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get continueAsGuest => 'المتابعة دون حساب';

  @override
  String get scoresNotSaved => 'لن تُحفظ النتائج';

  @override
  String get passwordMin8 => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get registrationFailed =>
      'فشل التسجيل. قد يكون البريد مستخدماً بالفعل.';

  @override
  String get createAccountTitle => 'إنشاء\nحساب';

  @override
  String get joinThousands => 'انضم إلى آلاف اللاعبين';

  @override
  String get choosePassword => 'اختر كلمة مرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get repeatPassword => 'أعد كتابة كلمة المرور';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get resetSendFailed => 'تعذّر إرسال الرمز. حاول مجدداً.';

  @override
  String get resetPasswordTitle => 'إعادة تعيين\nكلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لتلقي رابط إعادة التعيين';

  @override
  String get sendResetLink => 'إرسال الرابط';

  @override
  String get backToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get enterSixDigitCode =>
      'أدخل الرمز المكوّن من 6 أرقام الذي وصلك بالبريد.';

  @override
  String get passwordResetSuccess => 'أُعيد تعيين كلمة المرور بنجاح!';

  @override
  String get codeInvalidOrExpired => 'رمز خاطئ أو منتهي الصلاحية. حاول مجدداً.';

  @override
  String newCodeSentTo(String email) {
    return 'أُرسل رمز جديد إلى $email.';
  }

  @override
  String get resendCodeFailed => 'تعذّر إعادة إرسال الرمز. حاول مجدداً.';

  @override
  String get newPasswordTitle => 'كلمة مرور\nجديدة';

  @override
  String enterCodeAndNewPassword(String email) {
    return 'أدخل الرمز المُرسل إلى $email وكلمة مرورك الجديدة.';
  }

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get resetPasswordBtn => 'إعادة تعيين كلمة المرور';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get enterYourEmail => 'أدخل عنوان بريدك الإلكتروني';

  @override
  String get enterConfirmationCode => 'أدخل رمز التأكيد';

  @override
  String get emailConfirmed => 'تم تأكيد البريد الإلكتروني.';

  @override
  String get confirmCodeFailed => 'تعذّر تأكيد هذا الرمز.';

  @override
  String get confirmationEmailResent => 'أُرسل بريد تأكيد جديد.';

  @override
  String get confirmationEmailResendFailed => 'تعذّر إعادة إرسال بريد التأكيد.';

  @override
  String get confirmEmail => 'تأكيد البريد';

  @override
  String get confirmEmailTitle => 'تأكيد\nالبريد';

  @override
  String get validateEmailSubtitle => 'أكّد بريدك الإلكتروني لتأمين حسابك';

  @override
  String get confirmationCode => 'رمز التأكيد';

  @override
  String get enterYourCode => 'أدخل رمزك';

  @override
  String get resendEmail => 'إعادة إرسال البريد';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get signInToContinue => 'سجّل الدخول للمتابعة';

  @override
  String get guestScreenBody => 'احفظ تقدمك وأنشئ التحديات\nوابحث عن أصدقائك.';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get appTagline => 'تحدَّ أصدقاءك. سيطر على الاختبار.';

  @override
  String get exitAppTitle => 'الخروج من التطبيق؟';

  @override
  String get exitAppBody => 'هل أنت متأكد أنك تريد الخروج من ArifQuiz؟';

  @override
  String get profileTab => 'الملف الشخصي';

  @override
  String get playNow => 'العب الآن';

  @override
  String get keepPlayingTitle => 'واصل اللعب';

  @override
  String get paywallBody =>
      'شاهد إعلاناً قصيراً أو اشترك في بريميوم\nللعب دون انقطاع.';

  @override
  String get adLoading => 'جارٍ تحميل الإعلان…';

  @override
  String get yearly => 'سنوي';

  @override
  String get monthly => 'شهري';

  @override
  String get premiumBanner => 'Arif Quiz Premium\nبلا إعلانات · كل الميزات';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get watchAd => 'مشاهدة إعلان (≈30 ث)';

  @override
  String get somethingWrong => 'حدث خطأ ما.';

  @override
  String get tryAgain => 'أعد المحاولة';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get adminTitle => 'الإدارة';

  @override
  String get totalQuizzes => 'إجمالي الاختبارات';

  @override
  String get published => 'المنشورة';

  @override
  String get reports => 'البلاغات';

  @override
  String get management => 'الإدارة';

  @override
  String get manageCategoriesDesc => 'إضافة وتعديل وحذف';

  @override
  String get manageQuizzesDesc => 'إدارة الاختبارات وحالتها';

  @override
  String get manageQuestionsDesc => 'إضافة الأسئلة وتعديلها';

  @override
  String get importExcel => 'استيراد Excel';

  @override
  String get importQuizDesc => 'استيراد اختبار من ملف';

  @override
  String get reportedAnswersDesc => 'إجابات أبلغ عنها اللاعبون';

  @override
  String get confirmDeleteTitle => 'حذف؟';

  @override
  String deleteCategoryBody(String name) {
    return 'حذف \"$name\"؟ هذا الإجراء لا رجعة فيه.';
  }

  @override
  String get searchHint => 'بحث…';

  @override
  String get inactive => 'غير نشطة';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String get nameRequired => 'الاسم *';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get iconEmoji => 'الأيقونة (إيموجي)';

  @override
  String get colorHex => 'اللون (hex) *';

  @override
  String get colorFormat => 'الصيغة: #RRGGBB';

  @override
  String get activeCategory => 'فئة نشطة';

  @override
  String nameLocale(String locale) {
    return 'الاسم ($locale)';
  }

  @override
  String descriptionLocale(String locale) {
    return 'الوصف ($locale)';
  }

  @override
  String get inProgress => 'قيد المعالجة';

  @override
  String get resolved => 'تم الحل';

  @override
  String get rejected => 'مرفوض';

  @override
  String get deleteReportBody => 'سيُحذف هذا البلاغ نهائياً.';

  @override
  String get noReports => 'لا بلاغات';

  @override
  String markedCorrectAnswer(String answer) {
    return 'الإجابة المعتمدة: $answer';
  }

  @override
  String get anonymous => 'مجهول';

  @override
  String get questionLabel => 'السؤال';

  @override
  String get markPending => 'وضع قيد الانتظار';

  @override
  String get markInProgress => 'وضع قيد المعالجة';

  @override
  String get markResolved => 'وضع كمحلول';

  @override
  String get reject => 'رفض';

  @override
  String get selectExcelFile => 'يرجى اختيار ملف Excel.';

  @override
  String get cantAccessFile => 'تعذّر الوصول إلى الملف المحدد.';

  @override
  String get quizMetadata => 'بيانات الاختبار';

  @override
  String get titleRequired => 'العنوان *';

  @override
  String get categoryRequired => 'الفئة *';

  @override
  String get difficultyRequired => 'الصعوبة *';

  @override
  String get timeSeconds => 'الوقت (ث) *';

  @override
  String get pointsPerQuestionReq => 'نقاط/سؤال *';

  @override
  String get publishNow => 'نشر فوراً';

  @override
  String get excelFile => 'ملف Excel';

  @override
  String get tapToSelectFile => 'اضغط لاختيار ملف';

  @override
  String get acceptedFormats => 'الصيغ المقبولة: .xlsx و.xls و.csv';

  @override
  String get importing => 'جارٍ الاستيراد…';

  @override
  String get importBtn => 'استيراد';

  @override
  String get excelFormatTitle => 'صيغة ملف Excel';

  @override
  String get excelFormatColumns =>
      'الأعمدة المطلوبة: question, type, option_a, option_b, option_c, option_d, correct_answer\nأعمدة اختيارية: explanation';

  @override
  String get importSuccess => 'نجح الاستيراد!';

  @override
  String questionsImported(int count) {
    return 'استُورد $count سؤالاً';
  }

  @override
  String get translationsLabel => 'الترجمات';

  @override
  String get mainFieldsEnglish =>
      'الحقول الرئيسية = الإنجليزية (اللغة الافتراضية)';

  @override
  String get deleteQuestionBody => 'سيُحذف هذا السؤال نهائياً.';

  @override
  String get searchQuestionHint => 'ابحث عن سؤال…';

  @override
  String get typeLabel => 'النوع';

  @override
  String get resetFilters => 'إعادة تعيين';

  @override
  String get filterByQuiz => 'تصفية حسب الاختبار';

  @override
  String get filterByType => 'تصفية حسب النوع';

  @override
  String get noQuestionFound => 'لم يُعثر على سؤال';

  @override
  String get typeTrueFalse => 'صح/خطأ';

  @override
  String get answerTrue => 'صح';

  @override
  String get answerFalse => 'خطأ';

  @override
  String get trueFalseAutoLocalized =>
      'يُعرض الخياران على كل لاعب بلغته الخاصة.';

  @override
  String get typeShortAnswer => 'إجابة حرة';

  @override
  String get typeShortAnswerShort => 'حرة';

  @override
  String get editQuestion => 'تعديل السؤال';

  @override
  String get newQuestion => 'سؤال جديد';

  @override
  String get quizRequired => 'الاختبار *';

  @override
  String get typeRequired => 'النوع *';

  @override
  String get questionRequired => 'السؤال *';

  @override
  String get optionsRequired => 'الخيارات *';

  @override
  String optionN(int n) {
    return 'الخيار $n';
  }

  @override
  String get addOption => 'إضافة خيار';

  @override
  String get correctAnswerMatch =>
      'الإجابة الصحيحة * (يجب أن تطابق أحد الخيارات)';

  @override
  String get correctAnswerRequired => 'الإجابة الصحيحة *';

  @override
  String get explanationOptional => 'الشرح (اختياري)';

  @override
  String get mediaOptional => 'وسائط (اختياري)';

  @override
  String get imageLabel => 'صورة';

  @override
  String get audioLabel => 'صوت';

  @override
  String get orderLabel => 'الترتيب';

  @override
  String get integerRequired => 'عدد صحيح';

  @override
  String questionLocaleHint(String locale) {
    return 'السؤال ($locale) — فارغ = الإنجليزية';
  }

  @override
  String translationOf(String base) {
    return 'ترجمة «$base»';
  }

  @override
  String correctAnswerLocale(String locale) {
    return 'الإجابة الصحيحة ($locale)';
  }

  @override
  String explanationLocale(String locale) {
    return 'الشرح ($locale)';
  }

  @override
  String get fileBtn => 'ملف';

  @override
  String uploadFailed(String error) {
    return 'فشل الرفع: $error';
  }

  @override
  String deleteQuizBody(String title) {
    return 'حذف \"$title\" وجميع أسئلته؟';
  }

  @override
  String get fileLanguage => 'لغة الملف';

  @override
  String get importLangEn => 'English — أسئلة جديدة';

  @override
  String get importLangFr => 'Français — ترجمات';

  @override
  String get importLangAr => 'العربية — ترجمات';

  @override
  String get importLangEs => 'Español — ترجمات';

  @override
  String get appendedAfterExisting => 'تُضاف بعد الأسئلة الموجودة';

  @override
  String get appliedToExisting => 'تُطبَّق على الأسئلة الموجودة (عمود order)';

  @override
  String get questionsImportedMsg => 'استُوردت الأسئلة.';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get publishedSingular => 'منشور';

  @override
  String get draft => 'مسودة';

  @override
  String get filterByCategory => 'تصفية حسب الفئة';

  @override
  String get allFem => 'الكل';

  @override
  String get filterByDifficulty => 'تصفية حسب الصعوبة';

  @override
  String get filterByStatus => 'تصفية حسب الحالة';

  @override
  String get editQuiz => 'تعديل الاختبار';

  @override
  String get newQuiz => 'اختبار جديد';

  @override
  String get publishQuiz => 'نشر الاختبار';

  @override
  String get includeInJourney => 'تضمين في وضع المغامرة';

  @override
  String get journeyFeedDesc => 'أسئلته تغذي خريطة المستويات';

  @override
  String get visibilityLabel => 'الرؤية';

  @override
  String get publicVisible => 'عام — مرئي للجميع';

  @override
  String get restrictedChosen => 'مقيّد — مستخدمون محددون';

  @override
  String titleLocale(String locale) {
    return 'العنوان ($locale)';
  }

  @override
  String get allowedUsers => 'المستخدمون المسموح لهم';

  @override
  String get chooseUsers => 'اختيار مستخدمين';

  @override
  String get searchUserHint => 'بحث (الاسم، اسم المستخدم، البريد)…';

  @override
  String get noUsers => 'لا مستخدمين';

  @override
  String okSelected(int count) {
    return 'موافق · $count محدد';
  }

  @override
  String get addLevel => 'إضافة مستوى';

  @override
  String get editLevel => 'تعديل المستوى';

  @override
  String get levelPosition => 'الموضع';

  @override
  String get levelTitle => 'عنوان المستوى';

  @override
  String get secondsPerQuestion => 'ثوانٍ / سؤال';

  @override
  String get pointsPerQuestion => 'نقاط / سؤال';

  @override
  String get bossLevel => 'مستوى الزعيم';

  @override
  String get levelPublishHint => 'المستوى بلا أسئلة يبقى مخفيًا على الخريطة.';

  @override
  String get levelHasNoQuestions => 'لا توجد أسئلة: مخفي عن الخريطة.';

  @override
  String get levelNotPublished => 'غير منشور: مخفي عن الخريطة.';

  @override
  String get noJourneyLevels => 'لا توجد مستويات';

  @override
  String get noJourneyLevelsHint =>
      'أنشئ المرحلة الأولى: خريطة اللاعبين تبقى فارغة بدونها.';

  @override
  String deleteJourneyLevelBody(String title, int count) {
    return 'حذف « $title » وأسئلته ($count)؟ سيُفقد تقدم اللاعبين في هذه المرحلة.';
  }

  @override
  String get manageJourneyDesc => 'أنشئ مراحل الخريطة وأسئلتها';

  @override
  String get exportQuestions => 'تصدير الأسئلة';

  @override
  String get exportLocaleHint =>
      'يتبع الملف صيغة قالب الاستيراد: يمكنك تعديله وإعادة استيراده.';

  @override
  String get exportInProgress => 'جارٍ تجهيز الملف…';

  @override
  String get exportBtn => 'تصدير';
}
