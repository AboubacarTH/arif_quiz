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

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get skip => 'Passer →';

  @override
  String get loadQuestionsError => 'Impossible de charger les questions.';

  @override
  String get loadLevelError => 'Impossible de charger ce niveau.';

  @override
  String get invalidSession => 'Session invalide. Réessaie le niveau.';

  @override
  String get submitError =>
      'Erreur lors de la soumission. Vérifie ta connexion.';

  @override
  String get calculatingResults => 'Calcul des résultats…';

  @override
  String get survivalTag => 'MODE SURVIE';

  @override
  String get gameOver => 'Game Over !';

  @override
  String survivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu as survécu à $count questions',
      one: 'Tu as survécu à 1 question',
      zero: 'Tu n\'as survécu à aucune question',
    );
    return '$_temp0';
  }

  @override
  String get seeResults => 'Voir les résultats';

  @override
  String get quit => 'Quitter';

  @override
  String get quitGameTitle => 'Quitter la partie ?';

  @override
  String get quitGameBody => 'Ta progression sera perdue.';

  @override
  String get keepPlaying => 'Continuer';

  @override
  String get journeyMapTitle => 'Mode Parcours';

  @override
  String journeyLevelProgress(int current, int total) {
    return 'Niveau $current / $total';
  }

  @override
  String get journeyUnavailable => 'Parcours indisponible';

  @override
  String get comeBackLater => 'Reviens plus tard';

  @override
  String levelsCount(int count) {
    return '🏁  $count niveaux';
  }

  @override
  String get play => 'JOUER';

  @override
  String bossShort(int level) {
    return 'BOSS $level';
  }

  @override
  String get resultPerfect => 'Parfait !';

  @override
  String get resultGreat => 'Bien joué !';

  @override
  String get resultPassed => 'Niveau réussi';

  @override
  String get resultAlmost => 'Presque !';

  @override
  String bossLevelLabel(int level) {
    return 'Boss · Niveau $level';
  }

  @override
  String levelLabel(int level) {
    return 'Niveau $level';
  }

  @override
  String get nextLevel => 'Niveau suivant';

  @override
  String get retry => 'Réessayer';

  @override
  String get replay => 'Rejouer';

  @override
  String get viewMap => 'Voir la carte';

  @override
  String get score => 'Score';

  @override
  String get correctLabel => 'Bonnes';
}
