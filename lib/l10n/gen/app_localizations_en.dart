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

  @override
  String get wrongPasswordOrNetwork => 'Incorrect password or network error.';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get password => 'Password';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutBody =>
      'You\'ll need to sign in again to access your account.';

  @override
  String get logoutBtn => 'Log out';

  @override
  String get logOutAction => 'Log out';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editBtn => 'Edit';

  @override
  String rankLabel(int rank) {
    return 'Rank #$rank';
  }

  @override
  String nextLevelIn(int level, int xp) {
    return 'Level $level in $xp XP';
  }

  @override
  String get quizzesPlayed => 'Quizzes played';

  @override
  String get goodAnswers => 'Correct ans.';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get bestStreak => 'Best streak';

  @override
  String get achievements => 'Achievements';

  @override
  String get unlockBadgesByPlaying => 'Unlock badges by playing';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDesc => 'Follows the device theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkDesc => 'Dark gaming interface';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightDesc => 'Bright interface';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get noQuizPlayed => 'No quiz played';

  @override
  String get playFirstQuiz => 'Play your first quiz to see your results here!';

  @override
  String get playBtn => 'Play';

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get enterFullName => 'Please enter your full name';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get updateProfileFailed => 'Unable to update profile. Try again.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get fullName => 'Full name';

  @override
  String get yourNameHint => 'Your name';

  @override
  String get email => 'Email';

  @override
  String get loadHistoryError => 'Couldn\'t load history.';

  @override
  String get quizHistory => 'Quiz history';

  @override
  String get noAttemptsYet => 'No attempts yet';

  @override
  String get attemptsAppearHere =>
      'Play a quiz and your results will appear here.';

  @override
  String get refresh => 'Refresh';

  @override
  String pointsShort(int points) {
    return '+$points pts';
  }

  @override
  String get loadBadgesError => 'Couldn\'t load achievements.';

  @override
  String get progression => 'Progress';

  @override
  String get alreadyPlayedToday => 'You already played today!';

  @override
  String get dailyChallengeScreenTitle => 'Daily Challenge';

  @override
  String get noDailyToday => 'No challenge today';

  @override
  String get comeBackTomorrow => 'Come back tomorrow!';

  @override
  String get todaysChallengeTag => 'TODAY\'S CHALLENGE';

  @override
  String renewsIn(int h, int m) {
    return 'Renews in ${h}h ${m}m';
  }

  @override
  String get challengeCompleted => 'Challenge completed!';

  @override
  String yourScoreGrade(String score, String grade) {
    return 'Your score: $score% • Grade $grade';
  }

  @override
  String get bonusXp30 => '⚡ +30 bonus XP';

  @override
  String get takeChallenge => 'Take the challenge';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get welcomeBack => 'Welcome\nBack!';

  @override
  String get signInSubtitle => 'Sign in to continue your quiz journey';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get continueAsGuest => 'Continue without an account';

  @override
  String get scoresNotSaved => 'Scores won\'t be saved';

  @override
  String get passwordMin8 => 'Password must be at least 8 characters';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get registrationFailed =>
      'Registration failed. Email may already be taken.';

  @override
  String get createAccountTitle => 'Create an\naccount';

  @override
  String get joinThousands => 'Join thousands of players';

  @override
  String get choosePassword => 'Choose a password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get repeatPassword => 'Repeat your password';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get resetSendFailed => 'Couldn\'t send the code. Try again.';

  @override
  String get resetPasswordTitle => 'Reset\npassword';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email to receive a reset link';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get enterSixDigitCode => 'Enter the 6-digit code received by email.';

  @override
  String get passwordResetSuccess => 'Password reset successfully!';

  @override
  String get codeInvalidOrExpired => 'Incorrect or expired code. Try again.';

  @override
  String newCodeSentTo(String email) {
    return 'A new code has been sent to $email.';
  }

  @override
  String get resendCodeFailed => 'Couldn\'t resend the code. Try again.';

  @override
  String get newPasswordTitle => 'New\npassword';

  @override
  String enterCodeAndNewPassword(String email) {
    return 'Enter the code received at $email and your new password.';
  }

  @override
  String get verificationCode => 'Verification code';

  @override
  String get newPassword => 'New password';

  @override
  String get resetPasswordBtn => 'Reset password';

  @override
  String get resendCode => 'Resend code';

  @override
  String get enterYourEmail => 'Please enter your email address';

  @override
  String get enterConfirmationCode => 'Please enter the confirmation code';

  @override
  String get emailConfirmed => 'Email address confirmed.';

  @override
  String get confirmCodeFailed => 'Unable to confirm this code.';

  @override
  String get confirmationEmailResent =>
      'A new confirmation email has been sent.';

  @override
  String get confirmationEmailResendFailed =>
      'Unable to resend the confirmation email.';

  @override
  String get confirmEmail => 'Confirm Email';

  @override
  String get confirmEmailTitle => 'Confirm\nEmail';

  @override
  String get validateEmailSubtitle =>
      'Validate your email address to secure your account';

  @override
  String get confirmationCode => 'Confirmation code';

  @override
  String get enterYourCode => 'Enter your code';

  @override
  String get resendEmail => 'Resend email';

  @override
  String get continueBtn => 'Continue';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get guestScreenBody =>
      'Save your progress, create challenges\nand find your friends.';

  @override
  String get backToHome => 'Back to home';

  @override
  String get appTagline => 'Challenge your friends. Master the quiz.';

  @override
  String get exitAppTitle => 'Quit the app?';

  @override
  String get exitAppBody => 'Are you sure you want to quit ArifQuiz?';

  @override
  String get profileTab => 'Profile';

  @override
  String get playNow => 'Play Now';

  @override
  String get keepPlayingTitle => 'Keep playing';

  @override
  String get paywallBody =>
      'Watch a short ad or go Premium\nto play without interruptions.';

  @override
  String get adLoading => 'Ad is loading…';

  @override
  String get yearly => 'Yearly';

  @override
  String get monthly => 'Monthly';

  @override
  String get premiumBanner => 'Arif Quiz Premium\nAd-free · All features';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get watchAd => 'Watch an ad (≈30s)';

  @override
  String get somethingWrong => 'Something went wrong.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get adminTitle => 'Admin';

  @override
  String get totalQuizzes => 'Total quizzes';

  @override
  String get published => 'Published';

  @override
  String get reports => 'Reports';

  @override
  String get management => 'Management';

  @override
  String get manageCategoriesDesc => 'Add, edit, delete';

  @override
  String get manageQuizzesDesc => 'Manage quizzes and their status';

  @override
  String get manageQuestionsDesc => 'Add and edit questions';

  @override
  String get importExcel => 'Excel import';

  @override
  String get importQuizDesc => 'Import a quiz from a file';

  @override
  String get reportedAnswersDesc => 'Answers reported by players';

  @override
  String get confirmDeleteTitle => 'Delete?';

  @override
  String deleteCategoryBody(String name) {
    return 'Delete \"$name\"? This action is irreversible.';
  }

  @override
  String get searchHint => 'Search…';

  @override
  String get inactive => 'Inactive';

  @override
  String get editCategory => 'Edit category';

  @override
  String get newCategory => 'New category';

  @override
  String get nameRequired => 'Name *';

  @override
  String get requiredField => 'Required';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get iconEmoji => 'Icon (emoji)';

  @override
  String get colorHex => 'Color (hex) *';

  @override
  String get colorFormat => 'Format: #RRGGBB';

  @override
  String get activeCategory => 'Active category';

  @override
  String nameLocale(String locale) {
    return 'Name ($locale)';
  }

  @override
  String descriptionLocale(String locale) {
    return 'Description ($locale)';
  }

  @override
  String get inProgress => 'In progress';

  @override
  String get resolved => 'Resolved';

  @override
  String get rejected => 'Rejected';

  @override
  String get deleteReportBody => 'This report will be permanently deleted.';

  @override
  String get noReports => 'No reports';

  @override
  String markedCorrectAnswer(String answer) {
    return 'Answer marked correct: $answer';
  }

  @override
  String get anonymous => 'Anonymous';

  @override
  String get questionLabel => 'Question';

  @override
  String get markPending => 'Mark pending';

  @override
  String get markInProgress => 'Mark in progress';

  @override
  String get markResolved => 'Mark resolved';

  @override
  String get reject => 'Reject';

  @override
  String get selectExcelFile => 'Please select an Excel file.';

  @override
  String get cantAccessFile => 'Can\'t access the selected file.';

  @override
  String get quizMetadata => 'Quiz metadata';

  @override
  String get titleRequired => 'Title *';

  @override
  String get categoryRequired => 'Category *';

  @override
  String get difficultyRequired => 'Difficulty *';

  @override
  String get timeSeconds => 'Time (s) *';

  @override
  String get pointsPerQuestionReq => 'Points/question *';

  @override
  String get publishNow => 'Publish immediately';

  @override
  String get excelFile => 'Excel file';

  @override
  String get tapToSelectFile => 'Tap to select a file';

  @override
  String get acceptedFormats => 'Accepted formats: .xlsx, .xls, .csv';

  @override
  String get importing => 'Importing…';

  @override
  String get importBtn => 'Import';

  @override
  String get excelFormatTitle => 'Excel file format';

  @override
  String get excelFormatColumns =>
      'Required columns: question, type, option_a, option_b, option_c, option_d, correct_answer\nOptional columns: explanation';

  @override
  String get importSuccess => 'Import successful!';

  @override
  String questionsImported(int count) {
    return '$count questions imported';
  }

  @override
  String get translationsLabel => 'Translations';

  @override
  String get mainFieldsEnglish => 'Main fields = English (default language)';

  @override
  String get deleteQuestionBody => 'This question will be permanently deleted.';

  @override
  String get searchQuestionHint => 'Search a question…';

  @override
  String get typeLabel => 'Type';

  @override
  String get resetFilters => 'Reset';

  @override
  String get filterByQuiz => 'Filter by quiz';

  @override
  String get filterByType => 'Filter by type';

  @override
  String get noQuestionFound => 'No question found';

  @override
  String get typeTrueFalse => 'True/False';

  @override
  String get typeShortAnswer => 'Short answer';

  @override
  String get typeShortAnswerShort => 'Free';

  @override
  String get editQuestion => 'Edit question';

  @override
  String get newQuestion => 'New question';

  @override
  String get quizRequired => 'Quiz *';

  @override
  String get typeRequired => 'Type *';

  @override
  String get questionRequired => 'Question *';

  @override
  String get optionsRequired => 'Options *';

  @override
  String optionN(int n) {
    return 'Option $n';
  }

  @override
  String get addOption => 'Add an option';

  @override
  String get correctAnswerMatch => 'Correct answer * (must match an option)';

  @override
  String get correctAnswerRequired => 'Correct answer *';

  @override
  String get explanationOptional => 'Explanation (optional)';

  @override
  String get mediaOptional => 'Media (optional)';

  @override
  String get imageLabel => 'Image';

  @override
  String get audioLabel => 'Audio';

  @override
  String get orderLabel => 'Order';

  @override
  String get integerRequired => 'Integer';

  @override
  String questionLocaleHint(String locale) {
    return 'Question ($locale) — empty = English fallback';
  }

  @override
  String translationOf(String base) {
    return 'Translation of “$base”';
  }

  @override
  String correctAnswerLocale(String locale) {
    return 'Correct answer ($locale)';
  }

  @override
  String explanationLocale(String locale) {
    return 'Explanation ($locale)';
  }

  @override
  String get fileBtn => 'File';

  @override
  String uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String deleteQuizBody(String title) {
    return 'Delete \"$title\" and all its questions?';
  }

  @override
  String get fileLanguage => 'File language';

  @override
  String get importLangEn => 'English — new questions';

  @override
  String get importLangFr => 'Français — translations';

  @override
  String get importLangAr => 'العربية — translations';

  @override
  String get importLangEs => 'Español — translations';

  @override
  String get appendedAfterExisting => 'Added after existing questions';

  @override
  String get appliedToExisting =>
      'Applied to existing questions (order column)';

  @override
  String get questionsImportedMsg => 'Questions imported.';

  @override
  String get statusLabel => 'Status';

  @override
  String get publishedSingular => 'Published';

  @override
  String get draft => 'Draft';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get allFem => 'All';

  @override
  String get filterByDifficulty => 'Filter by difficulty';

  @override
  String get filterByStatus => 'Filter by status';

  @override
  String get editQuiz => 'Edit quiz';

  @override
  String get newQuiz => 'New quiz';

  @override
  String get publishQuiz => 'Publish quiz';

  @override
  String get includeInJourney => 'Include in Journey Mode';

  @override
  String get journeyFeedDesc => 'Its questions feed the level map';

  @override
  String get visibilityLabel => 'Visibility';

  @override
  String get publicVisible => 'Public — visible to everyone';

  @override
  String get restrictedChosen => 'Restricted — chosen users';

  @override
  String titleLocale(String locale) {
    return 'Title ($locale)';
  }

  @override
  String get allowedUsers => 'Allowed users';

  @override
  String get chooseUsers => 'Choose users';

  @override
  String get searchUserHint => 'Search (name, username, email)…';

  @override
  String get noUsers => 'No users';

  @override
  String okSelected(int count) {
    return 'OK · $count selected';
  }
}
