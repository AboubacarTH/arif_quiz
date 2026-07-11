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
}
