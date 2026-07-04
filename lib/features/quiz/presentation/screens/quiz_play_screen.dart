import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quit_confirm_dialog.dart';
import 'package:arif_quiz/ui/widgets/timer_ring.dart';
import 'package:flutter/material.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final int? challengeId;
  final ChallengeModel? challenge;
  final bool training;
  final int? questionCount;
  const QuizPlayScreen({
    super.key,
    required this.quiz,
    this.challengeId,
    this.challenge,
    this.training = false,
    this.questionCount,
  });
  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  GamePlayController? _ctrl;
  bool _initLoading = true;
  String? _initError;
  int? _sessionId;
  final _repo = QuizRepository(apiService);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _initLoading = true;
      _initError = null;
    });
    try {
      final List<QuestionModel> questions;
      final int timeLimit;
      if (widget.challengeId != null) {
        final data = await ChallengeRepository(apiService).getChallengeQuestions(widget.challengeId!);
        questions = data.questions;
        timeLimit = data.timeLimit;
        _sessionId = data.sessionId;
      } else {
        final data = await _repo.getQuizQuestions(widget.quiz.id,
            count: widget.questionCount);
        questions = data.questions;
        timeLimit = data.timeLimit;
        _sessionId = data.sessionId;
      }
      final ctrl = GamePlayController(
          mode: GameMode.classic,
          questions: questions,
          secondsPerQuestion: timeLimit);
      ctrl.addListener(_onCtrlChange);
      setState(() {
        _ctrl = ctrl;
        _initLoading = false;
      });
    } catch (e) {
      debugPrint('Challenge load error: $e');
      setState(() {
        _initError = 'Failed to load questions.';
        _initLoading = false;
      });
    }
  }

  void _onCtrlChange() {
    if (!mounted) return;
    setState(() {});
    if (_ctrl?.phase == GamePhase.submitting) _submit();
  }

  Future<void> _submit() async {
    final questions = _ctrl!.questions;
    final answers = Map<String, String>.from(_ctrl!.answers);
    final timeTaken = _ctrl!.totalTime;

    // Mode invité ou entraînement : scoring local, aucune soumission — donc
    // aucun impact XP / classement / stats.
    if (isGuest.value || widget.training) {
      final result = QuizAttemptResult.fromLocalScoring(
          questions: questions, answers: answers, timeTaken: timeTaken);
      _ctrl?.setResult(result);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          FadeScaleRoute(
              page: QuizResultScreen(
                  result: result,
                  quiz: widget.quiz,
                  guestMode: isGuest.value,
                  training: widget.training)));
      return;
    }

    try {
      final questionIds = questions.map((q) => q.id).toList();
      QuizAttemptResult result;
      if (widget.challengeId != null) {
        final crepo = ChallengeRepository(apiService);
        result = await crepo.submitChallenge(
          challengeId: widget.challengeId!,
          answers: answers,
          timeTaken: timeTaken,
          questionIds: questionIds,
          sessionId: _sessionId,
        );
      } else {
        result = await _repo.submitQuiz(
          quizId: widget.quiz.id,
          answers: answers,
          timeTaken: timeTaken,
          questionIds: questionIds,
          sessionId: _sessionId,
        );
      }

      _ctrl?.setResult(result);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          FadeScaleRoute(
              page: QuizResultScreen(result: result, quiz: widget.quiz, challenge: widget.challenge)));
    } catch (e) {
      debugPrint('Challenge submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la soumission. Vérifie ta connexion.'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onCtrlChange);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initLoading) {
      return Scaffold(
          backgroundColor: context.appColors.bg,
          body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_initError != null) {
      return Scaffold(
          backgroundColor: context.appColors.bg,
          body: ErrorState(message: _initError!, onRetry: _loadQuestions));
    }

    final ctrl = _ctrl!;
    final q = ctrl.currentQuestion;
    final opts = q.options ?? ['True', 'False'];
    final labels = ['A', 'B', 'C', 'D'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final quit = await confirmQuitGame(context);
        if (quit && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Top bar
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
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.close_rounded,
                            color: context.appColors.textSecondary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ctrl.progress,
                          backgroundColor: context.appColors.cardBg,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${ctrl.index + 1}/${ctrl.questions.length}',
                        style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 28),

                // Timer
                TimerRing(
                    timeLeft: ctrl.timeLeft,
                    totalTime: ctrl.secondsPerQuestion,
                    size: 80),
                const SizedBox(height: 28),

                // Question
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Question ${ctrl.index + 1}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(q.text,
                      style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          fontFamily: 'Nunito')),
                ),
                const SizedBox(height: 28),

                // Answers
                Expanded(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: opts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final opt = opts[i];
                      final q = ctrl.currentQuestion;
                      // Une fois répondu : on révèle toujours la bonne réponse
                      // (verte) et on marque le choix erroné (rouge).
                      final state = !ctrl.answered
                          ? AnswerState.idle
                          : q.isCorrect(opt)
                              ? AnswerState.correct
                              : opt == ctrl.selected
                                  ? AnswerState.wrong
                                  : AnswerState.idle;
                      return AnswerOptionTile(
                        label: labels[i < labels.length ? i : 0],
                        option: opt,
                        state: state,
                        onTap: () => ctrl.selectAnswer(opt),
                      );
                    },
                  ),
                ),

                // Skip
                if (!ctrl.answered)
                  TextButton(
                    onPressed: ctrl.skip,
                    child: Text('Skip →',
                        style: TextStyle(
                            color: context.appColors.textMuted, fontSize: 14)),
                  )
                else
                  const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
