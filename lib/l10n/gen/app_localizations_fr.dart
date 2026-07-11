// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String greeting(String name) {
    return 'Bonjour, $name 👋';
  }

  @override
  String get guest => 'Invité';

  @override
  String get readyToPlay => 'Prêt à jouer ?';

  @override
  String get categories => 'Catégories';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get popular => '🔥 Populaires';

  @override
  String get friendsLeaderboard => '🏅 Classement amis';

  @override
  String get guestBannerTitle => 'Sauvegarde ta progression !';

  @override
  String get guestBannerSubtitle =>
      'Crée un compte pour débloquer XP, streak et classement.';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get logIn => 'Se connecter';

  @override
  String get dailyChallengeTag => 'DÉFI QUOTIDIEN';

  @override
  String get dailyChallengeTitle => 'Un quiz spécial chaque jour';

  @override
  String get dailyChallengeSubtitle => '+30 XP bonus · Maintient ton streak';

  @override
  String get journeyTag => 'MODE PARCOURS';

  @override
  String get journeyTitle => 'Grimpe les niveaux de la map';

  @override
  String get journeySubtitle => 'Débloque, gagne des étoiles ⭐';

  @override
  String levelShort(int level) {
    return 'Niv. $level';
  }

  @override
  String quizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quiz',
      one: '1 quiz',
      zero: '0 quiz',
    );
    return '$_temp0';
  }

  @override
  String get language => 'Langue';

  @override
  String get chooseLanguage => 'Choisis ta langue';

  @override
  String get languageSystemNote =>
      'S\'applique aussi au contenu des quiz et questions.';
}
