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

  @override
  String get trainingResultNote =>
      'Mode entraînement — ce résultat n\'affecte ni ton XP ni le classement.';

  @override
  String get answerReview => 'Revue des réponses';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get homeLabel => 'Accueil';

  @override
  String get viewChallenge => 'Voir le défi';

  @override
  String get headlineOutstanding => 'Exceptionnel ! 🤩';

  @override
  String get headlineExcellent => 'Excellent ! 🎉';

  @override
  String get headlineGreat => 'Bien joué ! 👏';

  @override
  String get headlineNotBad => 'Pas mal ! 👍';

  @override
  String get headlineKeepGoing => 'Continue ! 💪';

  @override
  String get headlineTryAgain => 'Réessaie ! 🔄';

  @override
  String get yourAnswer => 'Ta réponse';

  @override
  String get points => 'Points';

  @override
  String get timeLabel => 'Temps';

  @override
  String get reportQuestionAction => 'Signaler une erreur';

  @override
  String get reportQuestionTitle => 'Signaler cette question';

  @override
  String get reportReasonLabel => 'Motif';

  @override
  String get reasonWrongAnswer => 'La bonne réponse est incorrecte';

  @override
  String get reasonAmbiguous => 'Question ambiguë ou mal formulée';

  @override
  String get reasonTypo => 'Faute d\'orthographe';

  @override
  String get reasonOutdated => 'Information périmée';

  @override
  String get reasonOther => 'Autre';

  @override
  String get commentOptional => 'Commentaire (optionnel)';

  @override
  String get sendReport => 'Envoyer le signalement';

  @override
  String get sendFailed => 'Échec de l\'envoi. Réessayez.';

  @override
  String get allQuizzes => 'Tous les quiz';

  @override
  String get searchQuizHint => 'Rechercher un quiz…';

  @override
  String get loadingEllipsis => 'Chargement…';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get diffEasy => 'Facile';

  @override
  String get diffMedium => 'Moyen';

  @override
  String get diffHard => 'Difficile';

  @override
  String get allFilter => 'Tous';

  @override
  String get noQuizFound => 'Aucun quiz trouvé';

  @override
  String get tryAnotherFilter =>
      'Essaie un autre filtre ou une autre recherche';

  @override
  String get searchCategoryHint => 'Rechercher une catégorie…';

  @override
  String noResultsFor(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get loadQuizError => 'Impossible de charger le quiz.';

  @override
  String get quizDetails => 'Détails du quiz';

  @override
  String get questions => 'Questions';

  @override
  String get perQuestion => 'Par question';

  @override
  String get pointsPerQ => 'Points / Q';

  @override
  String get plays => 'Parties';

  @override
  String get ruleSelectOne => 'Choisis une réponse par question';

  @override
  String get ruleTimer => 'Réponds avant la fin du chrono';

  @override
  String rulePoints(int points) {
    return 'Gagne $points points par bonne réponse';
  }

  @override
  String get ruleReview => 'Consulte les explications après le quiz';

  @override
  String get startQuiz => 'Lancer le quiz 🚀';

  @override
  String get tryAnotherDifficulty => 'Essaie un autre filtre de difficulté';

  @override
  String get loadCategoriesError => 'Impossible de charger les catégories';

  @override
  String get noCategories => 'Aucune catégorie';

  @override
  String get comeBackSoon => 'Reviens plus tard, du contenu arrive bientôt';

  @override
  String get chooseMode => 'Choisir le mode';

  @override
  String get randomQuestions10 => '10 questions aléatoires';

  @override
  String get questions10 => '10 questions';

  @override
  String get gameModeLabel => 'Mode de jeu';

  @override
  String get modeClassic => 'Mode Classique';

  @override
  String get modeClassicDesc =>
      '10 questions aléatoires · Timer par question · Score en %';

  @override
  String get modeSurvival => 'Mode Survie';

  @override
  String get modeSurvivalDesc =>
      '10 questions · Une mauvaise réponse et c\'est terminé · Bonus ×1.3';

  @override
  String get modeSpeed => 'Speed Round';

  @override
  String get modeSpeedDesc =>
      '10 questions · 5 secondes par question · Bonus XP ×1.5';

  @override
  String playInMode(String mode) {
    return 'Jouer en mode $mode';
  }

  @override
  String get trainingMode => 'Mode entraînement';

  @override
  String get trainingSubtitle => 'Choisis le nombre de questions · sans enjeu';

  @override
  String get trainingSheetBody => 'Joue sans impacter ton XP ni le classement.';

  @override
  String get questionCountLabel => 'Nombre de questions';

  @override
  String get startBtn => 'Commencer';

  @override
  String get oneLife => '1 vie';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Tout lire';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get friends => 'Amis';

  @override
  String get requestsTab => 'Demandes';

  @override
  String get activityTab => 'Activité';

  @override
  String get noFriendsYet => 'Pas encore d\'amis';

  @override
  String get searchPlayersToAdd => 'Recherche des joueurs à ajouter !';

  @override
  String get addFriends => 'Ajouter des amis';

  @override
  String sinceLabel(String time) {
    return 'Depuis $time';
  }

  @override
  String get noPendingRequests => 'Aucune demande en attente';

  @override
  String get noRecentActivity => 'Pas d\'activité récente';

  @override
  String get removeFriend => 'Supprimer cet ami';

  @override
  String get searchByNameHint => 'Rechercher par nom ou @username…';

  @override
  String get noPlayerFound => 'Aucun joueur trouvé';

  @override
  String get requestSent => 'Demande envoyée !';

  @override
  String get sentLabel => 'Envoyé';

  @override
  String get receivedLabel => 'Reçu';

  @override
  String get addBtn => 'Ajouter';

  @override
  String get modeClassicShort => 'Classique';

  @override
  String get modeSurvivalShort => 'Survie';

  @override
  String get modeSpeedShort => 'Speed Round';

  @override
  String get challengesTitle => 'Défis';

  @override
  String get joinBtn => 'Rejoindre';

  @override
  String get createChallenge => 'Créer un défi';

  @override
  String get noChallengesYet => 'Pas encore de défis';

  @override
  String get createOrJoin => 'Crée ou rejoins un défi !';

  @override
  String get createBtn => 'Créer';

  @override
  String get myCreatedChallenges => 'Mes défis créés';

  @override
  String get deleteBtn => 'Supprimer';

  @override
  String get joinedChallenges => 'Défis rejoints';

  @override
  String get deleteChallengeTitle => 'Supprimer le défi ?';

  @override
  String deleteChallengeBody(String title) {
    return 'Le défi « $title » sera définitivement supprimé.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get challengeDeleted => 'Défi supprimé';

  @override
  String get deleteError => 'Erreur lors de la suppression';

  @override
  String get stepSource => 'Source des questions';

  @override
  String get stepPickCategory => 'Choisir une catégorie';

  @override
  String get stepPickQuiz => 'Choisir un quiz';

  @override
  String get stepConfigure => 'Configurer le défi';

  @override
  String get enterChallengeTitle => 'Entre un titre pour le défi';

  @override
  String get createError => 'Erreur lors de la création';

  @override
  String get srcQuizLabel => 'Un quiz spécifique';

  @override
  String get srcQuizDesc => '10 questions tirées d\'un quiz de ton choix';

  @override
  String get srcCategoryLabel => 'Par catégorie';

  @override
  String get srcCategoryDesc =>
      '10 questions aléatoires parmi tous les quiz d\'une catégorie';

  @override
  String get srcAllDesc =>
      '10 questions aléatoires parmi tous les quiz disponibles';

  @override
  String get whereQuestionsFrom => 'D\'où viennent les questions ?';

  @override
  String get noCategoryAvailable => 'Aucune catégorie disponible';

  @override
  String get noQuizInCategory => 'Aucun quiz dans cette catégorie';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get challengeTitleLabel => 'Titre du défi';

  @override
  String get challengeTitleHint => 'Ex : Qui connaît l\'aviation ?';

  @override
  String get creating => 'Création…';

  @override
  String get createChallengeBtn => 'Créer le défi';

  @override
  String get joinChallengeTitle => 'Rejoindre un défi';

  @override
  String get enterChallengeCode => 'Entre le code du défi';

  @override
  String get codeHelp =>
      'Le code à 8 caractères t\'a été partagé par le créateur du défi.';

  @override
  String get joinChallengeBtn => 'Rejoindre le défi';

  @override
  String get challengeFound => 'Défi trouvé !';

  @override
  String byCreator(String name) {
    return 'par $name';
  }

  @override
  String get codeLengthError => 'Le code doit faire 8 caractères';

  @override
  String get rematchError => 'Revanche impossible. Réessaie.';

  @override
  String get rematch => 'Revanche';

  @override
  String get playThisChallenge => 'Jouer ce défi';

  @override
  String get alreadyPlayed =>
      'Tu as déjà joué ce défi. Consulte le classement ci-dessous.';

  @override
  String leaderboardCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count complétés',
      one: '1 complété',
    );
    return 'Classement ($_temp0)';
  }

  @override
  String get nobodyCompleted => 'Personne n\'a encore complété ce défi.';

  @override
  String pendingCount(int count) {
    return 'En attente ($count)';
  }

  @override
  String get pendingLabel => 'En attente';
}
