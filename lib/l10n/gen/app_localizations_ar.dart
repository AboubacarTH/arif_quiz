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
}
