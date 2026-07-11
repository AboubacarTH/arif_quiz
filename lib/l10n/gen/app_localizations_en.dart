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

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get skip => 'Skip →';

  @override
  String get loadQuestionsError => 'Couldn\'t load the questions.';

  @override
  String get loadLevelError => 'Couldn\'t load this level.';

  @override
  String get invalidSession => 'Invalid session. Retry the level.';

  @override
  String get submitError => 'Submission failed. Check your connection.';

  @override
  String get calculatingResults => 'Calculating results…';

  @override
  String get survivalTag => 'SURVIVAL MODE';

  @override
  String get gameOver => 'Game Over!';

  @override
  String survivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You survived $count questions',
      one: 'You survived 1 question',
      zero: 'You didn\'t survive a single question',
    );
    return '$_temp0';
  }

  @override
  String get seeResults => 'See results';

  @override
  String get quit => 'Quit';

  @override
  String get quitGameTitle => 'Quit the game?';

  @override
  String get quitGameBody => 'Your progress will be lost.';

  @override
  String get keepPlaying => 'Continue';

  @override
  String get journeyMapTitle => 'Journey Mode';

  @override
  String journeyLevelProgress(int current, int total) {
    return 'Level $current / $total';
  }

  @override
  String get journeyUnavailable => 'Journey unavailable';

  @override
  String get comeBackLater => 'Come back later';

  @override
  String levelsCount(int count) {
    return '🏁  $count levels';
  }

  @override
  String get play => 'PLAY';

  @override
  String bossShort(int level) {
    return 'BOSS $level';
  }

  @override
  String get resultPerfect => 'Perfect!';

  @override
  String get resultGreat => 'Well played!';

  @override
  String get resultPassed => 'Level cleared';

  @override
  String get resultAlmost => 'Almost!';

  @override
  String bossLevelLabel(int level) {
    return 'Boss · Level $level';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get nextLevel => 'Next level';

  @override
  String get retry => 'Retry';

  @override
  String get replay => 'Replay';

  @override
  String get viewMap => 'View map';

  @override
  String get score => 'Score';

  @override
  String get correctLabel => 'Correct';

  @override
  String get trainingResultNote =>
      'Practice mode — this result doesn\'t affect your XP or ranking.';

  @override
  String get answerReview => 'Answer review';

  @override
  String get createAccount => 'Create account';

  @override
  String get homeLabel => 'Home';

  @override
  String get viewChallenge => 'View challenge';

  @override
  String get headlineOutstanding => 'Outstanding! 🤩';

  @override
  String get headlineExcellent => 'Excellent! 🎉';

  @override
  String get headlineGreat => 'Great job! 👏';

  @override
  String get headlineNotBad => 'Not bad! 👍';

  @override
  String get headlineKeepGoing => 'Keep going! 💪';

  @override
  String get headlineTryAgain => 'Try again! 🔄';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get points => 'Points';

  @override
  String get timeLabel => 'Time';

  @override
  String get reportQuestionAction => 'Report an issue';

  @override
  String get reportQuestionTitle => 'Report this question';

  @override
  String get reportReasonLabel => 'Reason';

  @override
  String get reasonWrongAnswer => 'The correct answer is wrong';

  @override
  String get reasonAmbiguous => 'Ambiguous or poorly worded question';

  @override
  String get reasonTypo => 'Spelling mistake';

  @override
  String get reasonOutdated => 'Outdated information';

  @override
  String get reasonOther => 'Other';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get sendReport => 'Send report';

  @override
  String get sendFailed => 'Sending failed. Try again.';

  @override
  String get allQuizzes => 'All quizzes';

  @override
  String get searchQuizHint => 'Search for a quiz…';

  @override
  String get loadingEllipsis => 'Loading…';

  @override
  String get allCategories => 'All categories';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get diffEasy => 'Easy';

  @override
  String get diffMedium => 'Medium';

  @override
  String get diffHard => 'Hard';

  @override
  String get allFilter => 'All';

  @override
  String get noQuizFound => 'No quiz found';

  @override
  String get tryAnotherFilter => 'Try another filter or search';

  @override
  String get searchCategoryHint => 'Search for a category…';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get loadQuizError => 'Couldn\'t load the quiz.';

  @override
  String get quizDetails => 'Quiz details';

  @override
  String get questions => 'Questions';

  @override
  String get perQuestion => 'Per question';

  @override
  String get pointsPerQ => 'Points / Q';

  @override
  String get plays => 'Plays';

  @override
  String get ruleSelectOne => 'Select one answer per question';

  @override
  String get ruleTimer => 'Answer before the timer runs out';

  @override
  String rulePoints(int points) {
    return 'Earn $points points per correct answer';
  }

  @override
  String get ruleReview => 'Review full explanations after the quiz';

  @override
  String get startQuiz => 'Start Quiz 🚀';

  @override
  String get tryAnotherDifficulty => 'Try another difficulty filter';

  @override
  String get loadCategoriesError => 'Couldn\'t load the categories';

  @override
  String get noCategories => 'No categories';

  @override
  String get comeBackSoon => 'Come back later, new content is on its way';

  @override
  String get chooseMode => 'Choose mode';

  @override
  String get randomQuestions10 => '10 random questions';

  @override
  String get questions10 => '10 questions';

  @override
  String get gameModeLabel => 'Game mode';

  @override
  String get modeClassic => 'Classic Mode';

  @override
  String get modeClassicDesc =>
      '10 random questions · Timer per question · Score in %';

  @override
  String get modeSurvival => 'Survival Mode';

  @override
  String get modeSurvivalDesc =>
      '10 questions · One wrong answer and it\'s over · ×1.3 bonus';

  @override
  String get modeSpeed => 'Speed Round';

  @override
  String get modeSpeedDesc =>
      '10 questions · 5 seconds per question · ×1.5 XP bonus';

  @override
  String playInMode(String mode) {
    return 'Play $mode';
  }

  @override
  String get trainingMode => 'Practice mode';

  @override
  String get trainingSubtitle => 'Choose the number of questions · no stakes';

  @override
  String get trainingSheetBody => 'Play without affecting your XP or ranking.';

  @override
  String get questionCountLabel => 'Number of questions';

  @override
  String get startBtn => 'Start';

  @override
  String get oneLife => '1 life';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get friends => 'Friends';

  @override
  String get requestsTab => 'Requests';

  @override
  String get activityTab => 'Activity';

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get searchPlayersToAdd => 'Search for players to add!';

  @override
  String get addFriends => 'Add friends';

  @override
  String sinceLabel(String time) {
    return 'Since $time';
  }

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get removeFriend => 'Remove this friend';

  @override
  String get searchByNameHint => 'Search by name or @username…';

  @override
  String get noPlayerFound => 'No player found';

  @override
  String get requestSent => 'Request sent!';

  @override
  String get sentLabel => 'Sent';

  @override
  String get receivedLabel => 'Received';

  @override
  String get addBtn => 'Add';

  @override
  String get modeClassicShort => 'Classic';

  @override
  String get modeSurvivalShort => 'Survival';

  @override
  String get modeSpeedShort => 'Speed Round';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get joinBtn => 'Join';

  @override
  String get createChallenge => 'Create a challenge';

  @override
  String get noChallengesYet => 'No challenges yet';

  @override
  String get createOrJoin => 'Create or join a challenge!';

  @override
  String get createBtn => 'Create';

  @override
  String get myCreatedChallenges => 'My created challenges';

  @override
  String get deleteBtn => 'Delete';

  @override
  String get joinedChallenges => 'Joined challenges';

  @override
  String get deleteChallengeTitle => 'Delete the challenge?';

  @override
  String deleteChallengeBody(String title) {
    return 'The challenge \"$title\" will be permanently deleted.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get challengeDeleted => 'Challenge deleted';

  @override
  String get deleteError => 'Error while deleting';

  @override
  String get stepSource => 'Question source';

  @override
  String get stepPickCategory => 'Choose a category';

  @override
  String get stepPickQuiz => 'Choose a quiz';

  @override
  String get stepConfigure => 'Configure the challenge';

  @override
  String get enterChallengeTitle => 'Enter a title for the challenge';

  @override
  String get createError => 'Error while creating';

  @override
  String get srcQuizLabel => 'A specific quiz';

  @override
  String get srcQuizDesc => '10 questions from a quiz of your choice';

  @override
  String get srcCategoryLabel => 'By category';

  @override
  String get srcCategoryDesc =>
      '10 random questions from all quizzes in a category';

  @override
  String get srcAllDesc => '10 random questions from all available quizzes';

  @override
  String get whereQuestionsFrom => 'Where do the questions come from?';

  @override
  String get noCategoryAvailable => 'No category available';

  @override
  String get noQuizInCategory => 'No quiz in this category';

  @override
  String get categoryLabel => 'Category';

  @override
  String get challengeTitleLabel => 'Challenge title';

  @override
  String get challengeTitleHint => 'E.g.: Who knows aviation?';

  @override
  String get creating => 'Creating…';

  @override
  String get createChallengeBtn => 'Create the challenge';

  @override
  String get joinChallengeTitle => 'Join a challenge';

  @override
  String get enterChallengeCode => 'Enter the challenge code';

  @override
  String get codeHelp =>
      'The 8-character code was shared with you by the challenge creator.';

  @override
  String get joinChallengeBtn => 'Join the challenge';

  @override
  String get challengeFound => 'Challenge found!';

  @override
  String byCreator(String name) {
    return 'by $name';
  }

  @override
  String get codeLengthError => 'The code must be 8 characters';

  @override
  String get rematchError => 'Rematch failed. Try again.';

  @override
  String get rematch => 'Rematch';

  @override
  String get playThisChallenge => 'Play this challenge';

  @override
  String get alreadyPlayed =>
      'You already played this challenge. Check the leaderboard below.';

  @override
  String leaderboardCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed',
      one: '1 completed',
    );
    return 'Leaderboard ($_temp0)';
  }

  @override
  String get nobodyCompleted => 'Nobody has completed this challenge yet.';

  @override
  String pendingCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String get pendingLabel => 'Pending';
}
