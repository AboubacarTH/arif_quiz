// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String greeting(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get guest => 'Guest';

  @override
  String get readyToPlay => 'Ready to play?';

  @override
  String get categories => 'Categories';

  @override
  String get seeAll => 'See all';

  @override
  String get popular => '🔥 Popular';

  @override
  String get friendsLeaderboard => '🏅 Friends leaderboard';

  @override
  String get guestBannerTitle => 'Save your progress!';

  @override
  String get guestBannerSubtitle =>
      'Create an account to unlock XP, streaks and rankings.';

  @override
  String get signUp => 'Sign up';

  @override
  String get logIn => 'Log in';

  @override
  String get dailyChallengeTag => 'DAILY CHALLENGE';

  @override
  String get dailyChallengeTitle => 'A special quiz every day';

  @override
  String get dailyChallengeSubtitle => '+30 bonus XP · Keeps your streak alive';

  @override
  String get journeyTag => 'JOURNEY MODE';

  @override
  String get journeyTitle => 'Climb the levels of the map';

  @override
  String get journeySubtitle => 'Unlock levels, earn stars ⭐';

  @override
  String levelShort(int level) {
    return 'Lvl $level';
  }

  @override
  String quizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quizzes',
      one: '1 quiz',
      zero: '0 quizzes',
    );
    return '$_temp0';
  }

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get languageSystemNote => 'Also applies to quiz and question content.';
}
