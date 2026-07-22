import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String greeting(String name);

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play?'**
  String get readyToPlay;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'🔥 Popular'**
  String get popular;

  /// No description provided for @friendsLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'🏅 Friends leaderboard'**
  String get friendsLeaderboard;

  /// No description provided for @guestBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress!'**
  String get guestBannerTitle;

  /// No description provided for @guestBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to unlock XP, streaks and rankings.'**
  String get guestBannerSubtitle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @dailyChallengeTag.
  ///
  /// In en, this message translates to:
  /// **'DAILY CHALLENGE'**
  String get dailyChallengeTag;

  /// No description provided for @dailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'A special quiz every day'**
  String get dailyChallengeTitle;

  /// No description provided for @dailyChallengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'+30 bonus XP · Keeps your streak alive'**
  String get dailyChallengeSubtitle;

  /// No description provided for @journeyTag.
  ///
  /// In en, this message translates to:
  /// **'JOURNEY MODE'**
  String get journeyTag;

  /// No description provided for @journeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Climb the levels of the map'**
  String get journeyTitle;

  /// No description provided for @journeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock levels, earn stars ⭐'**
  String get journeySubtitle;

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lvl {level}'**
  String levelShort(int level);

  /// No description provided for @quizCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 quizzes} =1{1 quiz} other{{count} quizzes}}'**
  String quizCount(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @languageSystemNote.
  ///
  /// In en, this message translates to:
  /// **'Also applies to quiz and question content.'**
  String get languageSystemNote;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(int number);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip →'**
  String get skip;

  /// No description provided for @loadQuestionsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the questions.'**
  String get loadQuestionsError;

  /// No description provided for @loadLevelError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this level.'**
  String get loadLevelError;

  /// No description provided for @invalidSession.
  ///
  /// In en, this message translates to:
  /// **'Invalid session. Retry the level.'**
  String get invalidSession;

  /// No description provided for @submitError.
  ///
  /// In en, this message translates to:
  /// **'Submission failed. Check your connection.'**
  String get submitError;

  /// No description provided for @calculatingResults.
  ///
  /// In en, this message translates to:
  /// **'Calculating results…'**
  String get calculatingResults;

  /// No description provided for @survivalTag.
  ///
  /// In en, this message translates to:
  /// **'SURVIVAL MODE'**
  String get survivalTag;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over!'**
  String get gameOver;

  /// No description provided for @survivedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You didn\'t survive a single question} =1{You survived 1 question} other{You survived {count} questions}}'**
  String survivedCount(int count);

  /// No description provided for @seeResults.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get seeResults;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @quitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit the game?'**
  String get quitGameTitle;

  /// No description provided for @quitGameBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost.'**
  String get quitGameBody;

  /// No description provided for @keepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get keepPlaying;

  /// No description provided for @journeyMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey Mode'**
  String get journeyMapTitle;

  /// No description provided for @journeyLevelProgress.
  ///
  /// In en, this message translates to:
  /// **'Level {current} / {total}'**
  String journeyLevelProgress(int current, int total);

  /// No description provided for @journeyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Journey unavailable'**
  String get journeyUnavailable;

  /// No description provided for @comeBackLater.
  ///
  /// In en, this message translates to:
  /// **'Come back later'**
  String get comeBackLater;

  /// No description provided for @levelsCount.
  ///
  /// In en, this message translates to:
  /// **'🏁  {count} levels'**
  String levelsCount(int count);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @bossShort.
  ///
  /// In en, this message translates to:
  /// **'BOSS {level}'**
  String bossShort(int level);

  /// No description provided for @resultPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get resultPerfect;

  /// No description provided for @resultGreat.
  ///
  /// In en, this message translates to:
  /// **'Well played!'**
  String get resultGreat;

  /// No description provided for @resultPassed.
  ///
  /// In en, this message translates to:
  /// **'Level cleared'**
  String get resultPassed;

  /// No description provided for @resultAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost!'**
  String get resultAlmost;

  /// No description provided for @bossLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Boss · Level {level}'**
  String bossLevelLabel(int level);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get nextLevel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View map'**
  String get viewMap;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @correctLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctLabel;

  /// No description provided for @trainingResultNote.
  ///
  /// In en, this message translates to:
  /// **'Practice mode — this result doesn\'t affect your XP or ranking.'**
  String get trainingResultNote;

  /// No description provided for @answerReview.
  ///
  /// In en, this message translates to:
  /// **'Answer review'**
  String get answerReview;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @viewChallenge.
  ///
  /// In en, this message translates to:
  /// **'View challenge'**
  String get viewChallenge;

  /// No description provided for @headlineOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding! 🤩'**
  String get headlineOutstanding;

  /// No description provided for @headlineExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent! 🎉'**
  String get headlineExcellent;

  /// No description provided for @headlineGreat.
  ///
  /// In en, this message translates to:
  /// **'Great job! 👏'**
  String get headlineGreat;

  /// No description provided for @headlineNotBad.
  ///
  /// In en, this message translates to:
  /// **'Not bad! 👍'**
  String get headlineNotBad;

  /// No description provided for @headlineKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going! 💪'**
  String get headlineKeepGoing;

  /// No description provided for @headlineTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again! 🔄'**
  String get headlineTryAgain;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @reportQuestionAction.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportQuestionAction;

  /// No description provided for @reportQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this question'**
  String get reportQuestionTitle;

  /// No description provided for @reportReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reportReasonLabel;

  /// No description provided for @reasonWrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'The correct answer is wrong'**
  String get reasonWrongAnswer;

  /// No description provided for @reasonAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous or poorly worded question'**
  String get reasonAmbiguous;

  /// No description provided for @reasonTypo.
  ///
  /// In en, this message translates to:
  /// **'Spelling mistake'**
  String get reasonTypo;

  /// No description provided for @reasonOutdated.
  ///
  /// In en, this message translates to:
  /// **'Outdated information'**
  String get reasonOutdated;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get sendReport;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Sending failed. Try again.'**
  String get sendFailed;

  /// No description provided for @allQuizzes.
  ///
  /// In en, this message translates to:
  /// **'All quizzes'**
  String get allQuizzes;

  /// No description provided for @searchQuizHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a quiz…'**
  String get searchQuizHint;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingEllipsis;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @diffEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get diffEasy;

  /// No description provided for @diffMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get diffMedium;

  /// No description provided for @diffHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get diffHard;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @noQuizFound.
  ///
  /// In en, this message translates to:
  /// **'No quiz found'**
  String get noQuizFound;

  /// No description provided for @tryAnotherFilter.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or search'**
  String get tryAnotherFilter;

  /// No description provided for @searchCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a category…'**
  String get searchCategoryHint;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @loadQuizError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the quiz.'**
  String get loadQuizError;

  /// No description provided for @quizDetails.
  ///
  /// In en, this message translates to:
  /// **'Quiz details'**
  String get quizDetails;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @perQuestion.
  ///
  /// In en, this message translates to:
  /// **'Per question'**
  String get perQuestion;

  /// No description provided for @pointsPerQ.
  ///
  /// In en, this message translates to:
  /// **'Points / Q'**
  String get pointsPerQ;

  /// No description provided for @plays.
  ///
  /// In en, this message translates to:
  /// **'Plays'**
  String get plays;

  /// No description provided for @ruleSelectOne.
  ///
  /// In en, this message translates to:
  /// **'Select one answer per question'**
  String get ruleSelectOne;

  /// No description provided for @ruleTimer.
  ///
  /// In en, this message translates to:
  /// **'Answer before the timer runs out'**
  String get ruleTimer;

  /// No description provided for @rulePoints.
  ///
  /// In en, this message translates to:
  /// **'Earn {points} points per correct answer'**
  String rulePoints(int points);

  /// No description provided for @ruleReview.
  ///
  /// In en, this message translates to:
  /// **'Review full explanations after the quiz'**
  String get ruleReview;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz 🚀'**
  String get startQuiz;

  /// No description provided for @tryAnotherDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Try another difficulty filter'**
  String get tryAnotherDifficulty;

  /// No description provided for @loadCategoriesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the categories'**
  String get loadCategoriesError;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @comeBackSoon.
  ///
  /// In en, this message translates to:
  /// **'Come back later, new content is on its way'**
  String get comeBackSoon;

  /// No description provided for @chooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose mode'**
  String get chooseMode;

  /// No description provided for @randomQuestions10.
  ///
  /// In en, this message translates to:
  /// **'10 random questions'**
  String get randomQuestions10;

  /// No description provided for @questions10.
  ///
  /// In en, this message translates to:
  /// **'10 questions'**
  String get questions10;

  /// No description provided for @gameModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Game mode'**
  String get gameModeLabel;

  /// No description provided for @modeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic Mode'**
  String get modeClassic;

  /// No description provided for @modeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'10 random questions · Timer per question · Score in %'**
  String get modeClassicDesc;

  /// No description provided for @modeSurvival.
  ///
  /// In en, this message translates to:
  /// **'Survival Mode'**
  String get modeSurvival;

  /// No description provided for @modeSurvivalDesc.
  ///
  /// In en, this message translates to:
  /// **'10 questions · One wrong answer and it\'s over · ×1.3 bonus'**
  String get modeSurvivalDesc;

  /// No description provided for @modeSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed Round'**
  String get modeSpeed;

  /// No description provided for @modeSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'10 questions · 5 seconds per question · ×1.5 XP bonus'**
  String get modeSpeedDesc;

  /// No description provided for @playInMode.
  ///
  /// In en, this message translates to:
  /// **'Play {mode}'**
  String playInMode(String mode);

  /// No description provided for @trainingMode.
  ///
  /// In en, this message translates to:
  /// **'Practice mode'**
  String get trainingMode;

  /// No description provided for @trainingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the number of questions · no stakes'**
  String get trainingSubtitle;

  /// No description provided for @trainingSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Play without affecting your XP or ranking.'**
  String get trainingSheetBody;

  /// No description provided for @questionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get questionCountLabel;

  /// No description provided for @startBtn.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startBtn;

  /// No description provided for @oneLife.
  ///
  /// In en, this message translates to:
  /// **'1 life'**
  String get oneLife;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @requestsTab.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTab;

  /// No description provided for @activityTab.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTab;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @searchPlayersToAdd.
  ///
  /// In en, this message translates to:
  /// **'Search for players to add!'**
  String get searchPlayersToAdd;

  /// No description provided for @addFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends'**
  String get addFriends;

  /// No description provided for @sinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Since {time}'**
  String sinceLabel(String time);

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove this friend'**
  String get removeFriend;

  /// No description provided for @searchByNameHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or @username…'**
  String get searchByNameHint;

  /// No description provided for @noPlayerFound.
  ///
  /// In en, this message translates to:
  /// **'No player found'**
  String get noPlayerFound;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent!'**
  String get requestSent;

  /// No description provided for @sentLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentLabel;

  /// No description provided for @receivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedLabel;

  /// No description provided for @addBtn.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addBtn;

  /// No description provided for @modeClassicShort.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get modeClassicShort;

  /// No description provided for @modeSurvivalShort.
  ///
  /// In en, this message translates to:
  /// **'Survival'**
  String get modeSurvivalShort;

  /// No description provided for @modeSpeedShort.
  ///
  /// In en, this message translates to:
  /// **'Speed Round'**
  String get modeSpeedShort;

  /// No description provided for @challengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesTitle;

  /// No description provided for @joinBtn.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinBtn;

  /// No description provided for @createChallenge.
  ///
  /// In en, this message translates to:
  /// **'Create a challenge'**
  String get createChallenge;

  /// No description provided for @noChallengesYet.
  ///
  /// In en, this message translates to:
  /// **'No challenges yet'**
  String get noChallengesYet;

  /// No description provided for @createOrJoin.
  ///
  /// In en, this message translates to:
  /// **'Create or join a challenge!'**
  String get createOrJoin;

  /// No description provided for @createBtn.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createBtn;

  /// No description provided for @myCreatedChallenges.
  ///
  /// In en, this message translates to:
  /// **'My created challenges'**
  String get myCreatedChallenges;

  /// No description provided for @deleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBtn;

  /// No description provided for @joinedChallenges.
  ///
  /// In en, this message translates to:
  /// **'Joined challenges'**
  String get joinedChallenges;

  /// No description provided for @deleteChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the challenge?'**
  String get deleteChallengeTitle;

  /// No description provided for @deleteChallengeBody.
  ///
  /// In en, this message translates to:
  /// **'The challenge \"{title}\" will be permanently deleted.'**
  String deleteChallengeBody(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @challengeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Challenge deleted'**
  String get challengeDeleted;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Error while deleting'**
  String get deleteError;

  /// No description provided for @stepSource.
  ///
  /// In en, this message translates to:
  /// **'Question source'**
  String get stepSource;

  /// No description provided for @stepPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get stepPickCategory;

  /// No description provided for @stepPickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Choose a quiz'**
  String get stepPickQuiz;

  /// No description provided for @stepConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure the challenge'**
  String get stepConfigure;

  /// No description provided for @enterChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for the challenge'**
  String get enterChallengeTitle;

  /// No description provided for @createError.
  ///
  /// In en, this message translates to:
  /// **'Error while creating'**
  String get createError;

  /// No description provided for @srcQuizLabel.
  ///
  /// In en, this message translates to:
  /// **'A specific quiz'**
  String get srcQuizLabel;

  /// No description provided for @srcQuizDesc.
  ///
  /// In en, this message translates to:
  /// **'10 questions from a quiz of your choice'**
  String get srcQuizDesc;

  /// No description provided for @srcCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get srcCategoryLabel;

  /// No description provided for @srcCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'10 random questions from all quizzes in a category'**
  String get srcCategoryDesc;

  /// No description provided for @srcAllDesc.
  ///
  /// In en, this message translates to:
  /// **'10 random questions from all available quizzes'**
  String get srcAllDesc;

  /// No description provided for @whereQuestionsFrom.
  ///
  /// In en, this message translates to:
  /// **'Where do the questions come from?'**
  String get whereQuestionsFrom;

  /// No description provided for @noCategoryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No category available'**
  String get noCategoryAvailable;

  /// No description provided for @noQuizInCategory.
  ///
  /// In en, this message translates to:
  /// **'No quiz in this category'**
  String get noQuizInCategory;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @challengeTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Challenge title'**
  String get challengeTitleLabel;

  /// No description provided for @challengeTitleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Who knows aviation?'**
  String get challengeTitleHint;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get creating;

  /// No description provided for @createChallengeBtn.
  ///
  /// In en, this message translates to:
  /// **'Create the challenge'**
  String get createChallengeBtn;

  /// No description provided for @joinChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a challenge'**
  String get joinChallengeTitle;

  /// No description provided for @enterChallengeCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the challenge code'**
  String get enterChallengeCode;

  /// No description provided for @codeHelp.
  ///
  /// In en, this message translates to:
  /// **'The 8-character code was shared with you by the challenge creator.'**
  String get codeHelp;

  /// No description provided for @joinChallengeBtn.
  ///
  /// In en, this message translates to:
  /// **'Join the challenge'**
  String get joinChallengeBtn;

  /// No description provided for @challengeFound.
  ///
  /// In en, this message translates to:
  /// **'Challenge found!'**
  String get challengeFound;

  /// No description provided for @byCreator.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String byCreator(String name);

  /// No description provided for @codeLengthError.
  ///
  /// In en, this message translates to:
  /// **'The code must be 8 characters'**
  String get codeLengthError;

  /// No description provided for @rematchError.
  ///
  /// In en, this message translates to:
  /// **'Rematch failed. Try again.'**
  String get rematchError;

  /// No description provided for @rematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get rematch;

  /// No description provided for @playThisChallenge.
  ///
  /// In en, this message translates to:
  /// **'Play this challenge'**
  String get playThisChallenge;

  /// No description provided for @alreadyPlayed.
  ///
  /// In en, this message translates to:
  /// **'You already played this challenge. Check the leaderboard below.'**
  String get alreadyPlayed;

  /// No description provided for @leaderboardCompleted.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard ({count, plural, =1{1 completed} other{{count} completed}})'**
  String leaderboardCompleted(int count);

  /// No description provided for @nobodyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Nobody has completed this challenge yet.'**
  String get nobodyCompleted;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String pendingCount(int count);

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @wrongPasswordOrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password or network error.'**
  String get wrongPasswordOrNetwork;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to access your account.'**
  String get logoutBody;

  /// No description provided for @logoutBtn.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutBtn;

  /// No description provided for @logOutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutAction;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editBtn;

  /// No description provided for @rankLabel.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank}'**
  String rankLabel(int rank);

  /// No description provided for @nextLevelIn.
  ///
  /// In en, this message translates to:
  /// **'Level {level} in {xp} XP'**
  String nextLevelIn(int level, int xp);

  /// No description provided for @quizzesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Quizzes played'**
  String get quizzesPlayed;

  /// No description provided for @goodAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct ans.'**
  String get goodAnswers;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @unlockBadgesByPlaying.
  ///
  /// In en, this message translates to:
  /// **'Unlock badges by playing'**
  String get unlockBadgesByPlaying;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Follows the device theme'**
  String get themeSystemDesc;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark gaming interface'**
  String get themeDarkDesc;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Bright interface'**
  String get themeLightDesc;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @noQuizPlayed.
  ///
  /// In en, this message translates to:
  /// **'No quiz played'**
  String get noQuizPlayed;

  /// No description provided for @playFirstQuiz.
  ///
  /// In en, this message translates to:
  /// **'Play your first quiz to see your results here!'**
  String get playFirstQuiz;

  /// No description provided for @playBtn.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playBtn;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get enterFullName;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @updateProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile. Try again.'**
  String get updateProfileFailed;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @yourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @loadHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load history.'**
  String get loadHistoryError;

  /// No description provided for @quizHistory.
  ///
  /// In en, this message translates to:
  /// **'Quiz history'**
  String get quizHistory;

  /// No description provided for @noAttemptsYet.
  ///
  /// In en, this message translates to:
  /// **'No attempts yet'**
  String get noAttemptsYet;

  /// No description provided for @attemptsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Play a quiz and your results will appear here.'**
  String get attemptsAppearHere;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @pointsShort.
  ///
  /// In en, this message translates to:
  /// **'+{points} pts'**
  String pointsShort(int points);

  /// No description provided for @loadBadgesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load achievements.'**
  String get loadBadgesError;

  /// No description provided for @progression.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progression;

  /// No description provided for @alreadyPlayedToday.
  ///
  /// In en, this message translates to:
  /// **'You already played today!'**
  String get alreadyPlayedToday;

  /// No description provided for @dailyChallengeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallengeScreenTitle;

  /// No description provided for @noDailyToday.
  ///
  /// In en, this message translates to:
  /// **'No challenge today'**
  String get noDailyToday;

  /// No description provided for @comeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow!'**
  String get comeBackTomorrow;

  /// No description provided for @todaysChallengeTag.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S CHALLENGE'**
  String get todaysChallengeTag;

  /// No description provided for @renewsIn.
  ///
  /// In en, this message translates to:
  /// **'Renews in {h}h {m}m'**
  String renewsIn(int h, int m);

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Challenge completed!'**
  String get challengeCompleted;

  /// No description provided for @yourScoreGrade.
  ///
  /// In en, this message translates to:
  /// **'Your score: {score}% • Grade {grade}'**
  String yourScoreGrade(String score, String grade);

  /// No description provided for @bonusXp30.
  ///
  /// In en, this message translates to:
  /// **'⚡ +30 bonus XP'**
  String get bonusXp30;

  /// No description provided for @takeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Take the challenge'**
  String get takeChallenge;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome\nBack!'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your quiz journey'**
  String get signInSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get continueAsGuest;

  /// No description provided for @scoresNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Scores won\'t be saved'**
  String get scoresNotSaved;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMin8;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Email may already be taken.'**
  String get registrationFailed;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an\naccount'**
  String get createAccountTitle;

  /// No description provided for @joinThousands.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of players'**
  String get joinThousands;

  /// No description provided for @choosePassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a password'**
  String get choosePassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get repeatPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @resetSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the code. Try again.'**
  String get resetSendFailed;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset\npassword'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code received by email.'**
  String get enterSixDigitCode;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccess;

  /// No description provided for @codeInvalidOrExpired.
  ///
  /// In en, this message translates to:
  /// **'Incorrect or expired code. Try again.'**
  String get codeInvalidOrExpired;

  /// No description provided for @newCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent to {email}.'**
  String newCodeSentTo(String email);

  /// No description provided for @resendCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t resend the code. Try again.'**
  String get resendCodeFailed;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New\npassword'**
  String get newPasswordTitle;

  /// No description provided for @enterCodeAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the code received at {email} and your new password.'**
  String enterCodeAndNewPassword(String email);

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @resetPasswordBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordBtn;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterYourEmail;

  /// No description provided for @enterConfirmationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the confirmation code'**
  String get enterConfirmationCode;

  /// No description provided for @emailConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Email address confirmed.'**
  String get emailConfirmed;

  /// No description provided for @confirmCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to confirm this code.'**
  String get confirmCodeFailed;

  /// No description provided for @confirmationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'A new confirmation email has been sent.'**
  String get confirmationEmailResent;

  /// No description provided for @confirmationEmailResendFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend the confirmation email.'**
  String get confirmationEmailResendFailed;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm Email'**
  String get confirmEmail;

  /// No description provided for @confirmEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm\nEmail'**
  String get confirmEmailTitle;

  /// No description provided for @validateEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Validate your email address to secure your account'**
  String get validateEmailSubtitle;

  /// No description provided for @confirmationCode.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get confirmationCode;

  /// No description provided for @enterYourCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get enterYourCode;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @guestScreenBody.
  ///
  /// In en, this message translates to:
  /// **'Save your progress, create challenges\nand find your friends.'**
  String get guestScreenBody;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Challenge your friends. Master the quiz.'**
  String get appTagline;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit the app?'**
  String get exitAppTitle;

  /// No description provided for @exitAppBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to quit ArifQuiz?'**
  String get exitAppBody;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// No description provided for @keepPlayingTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep playing'**
  String get keepPlayingTitle;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad or go Premium\nto play without interruptions.'**
  String get paywallBody;

  /// No description provided for @adLoading.
  ///
  /// In en, this message translates to:
  /// **'Ad is loading…'**
  String get adLoading;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @premiumBanner.
  ///
  /// In en, this message translates to:
  /// **'Arif Quiz Premium\nAd-free · All features'**
  String get premiumBanner;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad (≈30s)'**
  String get watchAd;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminTitle;

  /// No description provided for @totalQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Total quizzes'**
  String get totalQuizzes;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @manageCategoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, delete'**
  String get manageCategoriesDesc;

  /// No description provided for @manageQuizzesDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage quizzes and their status'**
  String get manageQuizzesDesc;

  /// No description provided for @manageQuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add and edit questions'**
  String get manageQuestionsDesc;

  /// No description provided for @importExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel import'**
  String get importExcel;

  /// No description provided for @importQuizDesc.
  ///
  /// In en, this message translates to:
  /// **'Import a quiz from a file'**
  String get importQuizDesc;

  /// No description provided for @reportedAnswersDesc.
  ///
  /// In en, this message translates to:
  /// **'Answers reported by players'**
  String get reportedAnswersDesc;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get confirmDeleteTitle;

  /// No description provided for @deleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This action is irreversible.'**
  String deleteCategoryBody(String name);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get searchHint;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameRequired;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @iconEmoji.
  ///
  /// In en, this message translates to:
  /// **'Icon (emoji)'**
  String get iconEmoji;

  /// No description provided for @colorHex.
  ///
  /// In en, this message translates to:
  /// **'Color (hex) *'**
  String get colorHex;

  /// No description provided for @colorFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: #RRGGBB'**
  String get colorFormat;

  /// No description provided for @activeCategory.
  ///
  /// In en, this message translates to:
  /// **'Active category'**
  String get activeCategory;

  /// No description provided for @nameLocale.
  ///
  /// In en, this message translates to:
  /// **'Name ({locale})'**
  String nameLocale(String locale);

  /// No description provided for @descriptionLocale.
  ///
  /// In en, this message translates to:
  /// **'Description ({locale})'**
  String descriptionLocale(String locale);

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @deleteReportBody.
  ///
  /// In en, this message translates to:
  /// **'This report will be permanently deleted.'**
  String get deleteReportBody;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports'**
  String get noReports;

  /// No description provided for @markedCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer marked correct: {answer}'**
  String markedCorrectAnswer(String answer);

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @markPending.
  ///
  /// In en, this message translates to:
  /// **'Mark pending'**
  String get markPending;

  /// No description provided for @markInProgress.
  ///
  /// In en, this message translates to:
  /// **'Mark in progress'**
  String get markInProgress;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get markResolved;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @selectExcelFile.
  ///
  /// In en, this message translates to:
  /// **'Please select an Excel file.'**
  String get selectExcelFile;

  /// No description provided for @cantAccessFile.
  ///
  /// In en, this message translates to:
  /// **'Can\'t access the selected file.'**
  String get cantAccessFile;

  /// No description provided for @quizMetadata.
  ///
  /// In en, this message translates to:
  /// **'Quiz metadata'**
  String get quizMetadata;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get titleRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get categoryRequired;

  /// No description provided for @difficultyRequired.
  ///
  /// In en, this message translates to:
  /// **'Difficulty *'**
  String get difficultyRequired;

  /// No description provided for @timeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Time (s) *'**
  String get timeSeconds;

  /// No description provided for @pointsPerQuestionReq.
  ///
  /// In en, this message translates to:
  /// **'Points/question *'**
  String get pointsPerQuestionReq;

  /// No description provided for @publishNow.
  ///
  /// In en, this message translates to:
  /// **'Publish immediately'**
  String get publishNow;

  /// No description provided for @excelFile.
  ///
  /// In en, this message translates to:
  /// **'Excel file'**
  String get excelFile;

  /// No description provided for @tapToSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a file'**
  String get tapToSelectFile;

  /// No description provided for @acceptedFormats.
  ///
  /// In en, this message translates to:
  /// **'Accepted formats: .xlsx, .xls, .csv'**
  String get acceptedFormats;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importing;

  /// No description provided for @importBtn.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importBtn;

  /// No description provided for @excelFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Excel file format'**
  String get excelFormatTitle;

  /// No description provided for @excelFormatColumns.
  ///
  /// In en, this message translates to:
  /// **'Required columns: question, type, option_a, option_b, option_c, option_d, correct_answer\nOptional columns: explanation'**
  String get excelFormatColumns;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful!'**
  String get importSuccess;

  /// No description provided for @questionsImported.
  ///
  /// In en, this message translates to:
  /// **'{count} questions imported'**
  String questionsImported(int count);

  /// No description provided for @translationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translationsLabel;

  /// No description provided for @mainFieldsEnglish.
  ///
  /// In en, this message translates to:
  /// **'Main fields = English (default language)'**
  String get mainFieldsEnglish;

  /// No description provided for @deleteQuestionBody.
  ///
  /// In en, this message translates to:
  /// **'This question will be permanently deleted.'**
  String get deleteQuestionBody;

  /// No description provided for @searchQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Search a question…'**
  String get searchQuestionHint;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @filterByQuiz.
  ///
  /// In en, this message translates to:
  /// **'Filter by quiz'**
  String get filterByQuiz;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get filterByType;

  /// No description provided for @noQuestionFound.
  ///
  /// In en, this message translates to:
  /// **'No question found'**
  String get noQuestionFound;

  /// No description provided for @typeTrueFalse.
  ///
  /// In en, this message translates to:
  /// **'True/False'**
  String get typeTrueFalse;

  /// No description provided for @answerTrue.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get answerTrue;

  /// No description provided for @answerFalse.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get answerFalse;

  /// No description provided for @trueFalseAutoLocalized.
  ///
  /// In en, this message translates to:
  /// **'The two choices are shown to each player in their own language.'**
  String get trueFalseAutoLocalized;

  /// No description provided for @typeShortAnswer.
  ///
  /// In en, this message translates to:
  /// **'Short answer'**
  String get typeShortAnswer;

  /// No description provided for @typeShortAnswerShort.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get typeShortAnswerShort;

  /// No description provided for @editQuestion.
  ///
  /// In en, this message translates to:
  /// **'Edit question'**
  String get editQuestion;

  /// No description provided for @newQuestion.
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get newQuestion;

  /// No description provided for @quizRequired.
  ///
  /// In en, this message translates to:
  /// **'Quiz *'**
  String get quizRequired;

  /// No description provided for @typeRequired.
  ///
  /// In en, this message translates to:
  /// **'Type *'**
  String get typeRequired;

  /// No description provided for @questionRequired.
  ///
  /// In en, this message translates to:
  /// **'Question *'**
  String get questionRequired;

  /// No description provided for @optionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Options *'**
  String get optionsRequired;

  /// No description provided for @optionN.
  ///
  /// In en, this message translates to:
  /// **'Option {n}'**
  String optionN(int n);

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add an option'**
  String get addOption;

  /// No description provided for @correctAnswerMatch.
  ///
  /// In en, this message translates to:
  /// **'Correct answer * (must match an option)'**
  String get correctAnswerMatch;

  /// No description provided for @correctAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Correct answer *'**
  String get correctAnswerRequired;

  /// No description provided for @explanationOptional.
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get explanationOptional;

  /// No description provided for @mediaOptional.
  ///
  /// In en, this message translates to:
  /// **'Media (optional)'**
  String get mediaOptional;

  /// No description provided for @imageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageLabel;

  /// No description provided for @audioLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioLabel;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @integerRequired.
  ///
  /// In en, this message translates to:
  /// **'Integer'**
  String get integerRequired;

  /// No description provided for @questionLocaleHint.
  ///
  /// In en, this message translates to:
  /// **'Question ({locale}) — empty = English fallback'**
  String questionLocaleHint(String locale);

  /// No description provided for @translationOf.
  ///
  /// In en, this message translates to:
  /// **'Translation of “{base}”'**
  String translationOf(String base);

  /// No description provided for @correctAnswerLocale.
  ///
  /// In en, this message translates to:
  /// **'Correct answer ({locale})'**
  String correctAnswerLocale(String locale);

  /// No description provided for @explanationLocale.
  ///
  /// In en, this message translates to:
  /// **'Explanation ({locale})'**
  String explanationLocale(String locale);

  /// No description provided for @fileBtn.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileBtn;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(String error);

  /// No description provided for @deleteQuizBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" and all its questions?'**
  String deleteQuizBody(String title);

  /// No description provided for @fileLanguage.
  ///
  /// In en, this message translates to:
  /// **'File language'**
  String get fileLanguage;

  /// No description provided for @importLangEn.
  ///
  /// In en, this message translates to:
  /// **'English — new questions'**
  String get importLangEn;

  /// No description provided for @importLangFr.
  ///
  /// In en, this message translates to:
  /// **'Français — translations'**
  String get importLangFr;

  /// No description provided for @importLangAr.
  ///
  /// In en, this message translates to:
  /// **'العربية — translations'**
  String get importLangAr;

  /// No description provided for @importLangEs.
  ///
  /// In en, this message translates to:
  /// **'Español — translations'**
  String get importLangEs;

  /// No description provided for @appendedAfterExisting.
  ///
  /// In en, this message translates to:
  /// **'Added after existing questions'**
  String get appendedAfterExisting;

  /// No description provided for @appliedToExisting.
  ///
  /// In en, this message translates to:
  /// **'Applied to existing questions (order column)'**
  String get appliedToExisting;

  /// No description provided for @questionsImportedMsg.
  ///
  /// In en, this message translates to:
  /// **'Questions imported.'**
  String get questionsImportedMsg;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @publishedSingular.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishedSingular;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get filterByCategory;

  /// No description provided for @allFem.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFem;

  /// No description provided for @filterByDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Filter by difficulty'**
  String get filterByDifficulty;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get filterByStatus;

  /// No description provided for @editQuiz.
  ///
  /// In en, this message translates to:
  /// **'Edit quiz'**
  String get editQuiz;

  /// No description provided for @newQuiz.
  ///
  /// In en, this message translates to:
  /// **'New quiz'**
  String get newQuiz;

  /// No description provided for @publishQuiz.
  ///
  /// In en, this message translates to:
  /// **'Publish quiz'**
  String get publishQuiz;

  /// No description provided for @includeInJourney.
  ///
  /// In en, this message translates to:
  /// **'Include in Journey Mode'**
  String get includeInJourney;

  /// No description provided for @journeyFeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Its questions feed the level map'**
  String get journeyFeedDesc;

  /// No description provided for @visibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibilityLabel;

  /// No description provided for @publicVisible.
  ///
  /// In en, this message translates to:
  /// **'Public — visible to everyone'**
  String get publicVisible;

  /// No description provided for @restrictedChosen.
  ///
  /// In en, this message translates to:
  /// **'Restricted — chosen users'**
  String get restrictedChosen;

  /// No description provided for @titleLocale.
  ///
  /// In en, this message translates to:
  /// **'Title ({locale})'**
  String titleLocale(String locale);

  /// No description provided for @allowedUsers.
  ///
  /// In en, this message translates to:
  /// **'Allowed users'**
  String get allowedUsers;

  /// No description provided for @chooseUsers.
  ///
  /// In en, this message translates to:
  /// **'Choose users'**
  String get chooseUsers;

  /// No description provided for @searchUserHint.
  ///
  /// In en, this message translates to:
  /// **'Search (name, username, email)…'**
  String get searchUserHint;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get noUsers;

  /// No description provided for @okSelected.
  ///
  /// In en, this message translates to:
  /// **'OK · {count} selected'**
  String okSelected(int count);

  /// No description provided for @addLevel.
  ///
  /// In en, this message translates to:
  /// **'Add a level'**
  String get addLevel;

  /// No description provided for @editLevel.
  ///
  /// In en, this message translates to:
  /// **'Edit level'**
  String get editLevel;

  /// No description provided for @levelPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get levelPosition;

  /// No description provided for @levelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level title'**
  String get levelTitle;

  /// No description provided for @secondsPerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Seconds / question'**
  String get secondsPerQuestion;

  /// No description provided for @pointsPerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Points / question'**
  String get pointsPerQuestion;

  /// No description provided for @bossLevel.
  ///
  /// In en, this message translates to:
  /// **'Boss level'**
  String get bossLevel;

  /// No description provided for @levelPublishHint.
  ///
  /// In en, this message translates to:
  /// **'A level without questions stays hidden on the map.'**
  String get levelPublishHint;

  /// No description provided for @levelHasNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'No question yet: hidden from the map.'**
  String get levelHasNoQuestions;

  /// No description provided for @levelNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Not published: hidden from the map.'**
  String get levelNotPublished;

  /// No description provided for @noJourneyLevels.
  ///
  /// In en, this message translates to:
  /// **'No journey level yet'**
  String get noJourneyLevels;

  /// No description provided for @noJourneyLevelsHint.
  ///
  /// In en, this message translates to:
  /// **'Create the first step: the players\' map stays empty until then.'**
  String get noJourneyLevelsHint;

  /// No description provided for @deleteJourneyLevelBody.
  ///
  /// In en, this message translates to:
  /// **'Delete « {title} » and its {count} question(s)? Player progress on this step will be lost.'**
  String deleteJourneyLevelBody(String title, int count);

  /// No description provided for @manageJourneyDesc.
  ///
  /// In en, this message translates to:
  /// **'Create the levels of the map and their questions'**
  String get manageJourneyDesc;

  /// No description provided for @exportQuestions.
  ///
  /// In en, this message translates to:
  /// **'Export questions'**
  String get exportQuestions;

  /// No description provided for @exportLocaleHint.
  ///
  /// In en, this message translates to:
  /// **'The file matches the import template: you can edit it and re-import it.'**
  String get exportLocaleHint;

  /// No description provided for @exportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Preparing the file…'**
  String get exportInProgress;

  /// No description provided for @exportBtn.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
