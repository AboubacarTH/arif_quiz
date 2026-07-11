import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/question_media.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quit_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SurvivalPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final int? challengeId;
  final ChallengeModel? challenge;

  const SurvivalPlayScreen(
      {super.key, required this.quiz, this.challengeId, this.challenge});

  @override
  State<SurvivalPlayScreen> createState() => _SurvivalPlayScreenState();
}

class _SurvivalPlayScreenState extends State<SurvivalPlayScreen> {
  final _repo = QuizRepository(apiService);
  GamePlayController? _ctrl;
  bool _loading = true;
  bool _failed = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final List<QuestionModel> questions;
      final int timeLimit;
      if (widget.challengeId != null) {
        final data = await ChallengeRepository(apiService)
            .getChallengeQuestions(widget.challengeId!);
        questions = data.questions;
        timeLimit = data.timeLimit;
      } else {
        final data = await _repo.getQuizQuestions(widget.quiz.id);
        questions = data.questions;
        timeLimit = data.timeLimit;
      }
      final ctrl = GamePlayController(
        mode: GameMode.survival,
        questions: questions,
        secondsPerQuestion: timeLimit,
      );
      ctrl.addListener(_onChange);
      setState(() {
        _ctrl = ctrl;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Challenge load error: $e');
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    if (_ctrl?.phase == GamePhase.submitting) _submitResults();
  }

  Future<void> _submitResults() async {
    final ctrl = _ctrl!;
    if (_submitting) return;
    setState(() => _submitting = true);
    // En survie on ne soumet que le sous-ensemble réellement joué (mort = fin),
    // donc pas de session serveur ici : chemin legacy question_ids.
    final playedQuestions = ctrl.playedQuestions;
    final playedIds = playedQuestions.map((q) => q.id).toList();
    final answers = Map<String, String>.from(ctrl.answers);

    if (isGuest.value) {
      final result = QuizAttemptResult.fromLocalScoring(
          questions: playedQuestions,
          answers: answers,
          timeTaken: ctrl.totalTime);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          FadeScaleRoute(
              page: QuizResultScreen(
                  result: result, quiz: widget.quiz, guestMode: true)));
      return;
    }

    try {
      QuizAttemptResult result;
      if (widget.challengeId != null) {
        final crepo = ChallengeRepository(apiService);
        result = await crepo.submitChallenge(
          challengeId: widget.challengeId!,
          answers: answers,
          timeTaken: ctrl.totalTime,
          questionIds: playedIds,
        );
      } else {
        result = await _repo.submitQuiz(
          quizId: widget.quiz.id,
          answers: answers,
          timeTaken: ctrl.totalTime,
          questionIds: playedIds,
          mode: 'survival',
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          FadeScaleRoute(
              page: QuizResultScreen(
                  result: result,
                  quiz: widget.quiz,
                  challenge: widget.challenge)));
    } catch (e) {
      debugPrint('Challenge submit error: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).submitError),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onChange);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_failed) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: ErrorState(message: AppLocalizations.of(context).loadQuestionsError, onRetry: _loadQuestions),
      );
    }
    if (_submitting) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).calculatingResults,
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final ctrl = _ctrl!;
    final gameOver = ctrl.phase == GamePhase.gameOver;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (gameOver) {
          if (mounted) Navigator.pop(context);
          return;
        }
        if (await confirmQuitGame(context) && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: gameOver ? _buildGameOver() : _buildQuestion(),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final ctrl = _ctrl!;
    final q = ctrl.currentQuestion;
    final opts = q.options ?? ['Vrai', 'Faux'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (await confirmQuitGame(context) && mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.appColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: context.appColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ctrl.progress,
                    backgroundColor: context.appColors.cardBg,
                    valueColor: const AlwaysStoppedAnimation(AppColors.error),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${ctrl.index + 1}/${ctrl.questions.length}',
                style:
                    TextStyle(color: context.appColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Survival indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: Text(
                  AppLocalizations.of(context).survivalTag,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.appColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ctrl.timeLeft} s',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Média (image → audio) puis question : zone flexible/scrollable.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (q.hasMedia)
                    QuestionMedia(imageUrl: q.imageUrl, audioUrl: q.audioUrl),
                  Text(
                    AppLocalizations.of(context).questionNumber(ctrl.index + 1),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.text,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Réponses (bornées ≤ moitié de l'écran, ancrées en bas)
          AnswerOptionsGrid(
            options: opts,
            answered: ctrl.answered,
            selected: ctrl.selected,
            isCorrect: (o) => q.isCorrect(o),
            onSelect: ctrl.selectAnswer,
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    final survived = _ctrl!.survivedCount;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💔', style: TextStyle(fontSize: 64)).animate().shake(),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).gameOver,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).survivedCount(survived),
              style:
                  TextStyle(color: context.appColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _submitResults,
              icon: const Icon(Icons.bar_chart_rounded),
              label: Text(AppLocalizations.of(context).seeResults),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).quit,
                  style: TextStyle(color: context.appColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
