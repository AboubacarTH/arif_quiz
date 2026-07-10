import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/question_media.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quit_confirm_dialog.dart';
import 'package:flutter/material.dart';

class SpeedPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final int? challengeId;
  final ChallengeModel? challenge;

  const SpeedPlayScreen(
      {super.key, required this.quiz, this.challengeId, this.challenge});

  @override
  State<SpeedPlayScreen> createState() => _SpeedPlayScreenState();
}

class _SpeedPlayScreenState extends State<SpeedPlayScreen> {
  static const _secondsPerQuestion = 5;

  final _repo = QuizRepository(apiService);
  GamePlayController? _ctrl;
  bool _loading = true;
  String? _error;
  bool _submitting = false;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final List<QuestionModel> questions;
      if (widget.challengeId != null) {
        final data = await ChallengeRepository(apiService)
            .getChallengeQuestions(widget.challengeId!);
        questions = data.questions;
        _sessionId = data.sessionId;
      } else {
        final data = await _repo.getQuizQuestions(widget.quiz.id);
        questions = data.questions;
        _sessionId = data.sessionId;
      }
      final ctrl = GamePlayController(
        mode: GameMode.speed,
        questions: questions,
        secondsPerQuestion: _secondsPerQuestion,
      );
      ctrl.addListener(_onChange);
      setState(() {
        _ctrl = ctrl;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Challenge load error: $e');
      setState(() {
        _error = 'Impossible de charger les questions.';
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
    final answers = Map<String, String>.from(ctrl.answers);
    final questionIds = ctrl.questions.map((q) => q.id).toList();

    if (isGuest.value) {
      final result = QuizAttemptResult.fromLocalScoring(
          questions: ctrl.questions, answers: answers, timeTaken: ctrl.totalTime);
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
          questionIds: questionIds,
          sessionId: _sessionId,
        );
      } else {
        result = await _repo.submitQuiz(
          quizId: widget.quiz.id,
          answers: answers,
          timeTaken: ctrl.totalTime,
          questionIds: questionIds,
          mode: 'speed',
          sessionId: _sessionId,
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
        const SnackBar(
            content: Text('Erreur lors de la soumission'),
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
            child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: ErrorState(message: _error!, onRetry: _loadQuestions),
      );
    }
    if (_submitting) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(height: 16),
              Text(
                'Calcul des résultats...',
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final ctrl = _ctrl!;
    final q = ctrl.currentQuestion;
    final opts = q.options ?? ['Vrai', 'Faux'];
    final timerPercent = ctrl.timePercent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await confirmQuitGame(context) && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
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
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.secondary),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${ctrl.index + 1}/${ctrl.questions.length}',
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Speed timer bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.4)),
                      ),
                      child: const Text('⚡ SPEED',
                          style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          child: LinearProgressIndicator(
                            value: timerPercent,
                            backgroundColor: context.appColors.cardBg,
                            valueColor: AlwaysStoppedAnimation(
                              timerPercent > 0.5
                                  ? AppColors.secondary
                                  : timerPercent > 0.25
                                      ? AppColors.warning
                                      : AppColors.error,
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${ctrl.timeLeft} s',
                      style: TextStyle(
                        color: timerPercent > 0.5
                            ? AppColors.secondary
                            : timerPercent > 0.25
                                ? AppColors.warning
                                : AppColors.error,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Question ${ctrl.index + 1}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    q.text,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (q.hasMedia)
                  QuestionMedia(imageUrl: q.imageUrl, audioUrl: q.audioUrl),
                Expanded(
                  child: AnswerOptionsGrid(
                    options: opts,
                    answered: ctrl.answered,
                    selected: ctrl.selected,
                    isCorrect: (o) => q.isCorrect(o),
                    onSelect: ctrl.selectAnswer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
