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
