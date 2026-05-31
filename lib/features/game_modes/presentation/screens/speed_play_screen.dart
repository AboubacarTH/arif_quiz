import 'dart:async';
import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class SpeedPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final int? challengeId;

  const SpeedPlayScreen({super.key, required this.quiz, this.challengeId});

  @override
  State<SpeedPlayScreen> createState() => _SpeedPlayScreenState();
}

class _SpeedPlayScreenState extends State<SpeedPlayScreen> {
  static const _secondsPerQuestion = 5;

  final _repo = QuizRepository(apiService);
  List<QuestionModel> _questions = [];
  bool _loading = true;
  String? _error;
  bool _submitting = false;

  int _index = 0;
  int _timeLeft = _secondsPerQuestion;
  int _totalTime = 0;
  String? _selected;
  bool _answered = false;
  final Map<String, String> _answers = {};
  Timer? _timer;

  QuestionModel get _current => _questions[_index];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await _repo.getQuizQuestions(widget.quiz.id);
      setState(() {
        _questions = data.questions;
        _loading = false;
      });
      _startTimer();
    } catch (_) {
      setState(() {
        _error = 'Impossible de charger les questions.';
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _selectAnswer(null);
      }
    });
  }

  void _selectAnswer(String? answer) {
    if (_answered) return;
    _timer?.cancel();
    _totalTime += _secondsPerQuestion - _timeLeft;

    setState(() {
      _selected = answer;
      _answered = true;
      if (answer != null) _answers[_current.id.toString()] = answer;
    });

    Future.delayed(const Duration(milliseconds: 500), _advance);
  }

  void _advance() {
    if (_index >= _questions.length - 1) {
      _submitResults();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
    _startTimer();
  }

  Future<void> _submitResults() async {
    setState(() => _submitting = true);
    try {
      QuizAttemptResult result;
      if (widget.challengeId != null) {
        final crepo = ChallengeRepository(apiService);
        result = await crepo.submitChallenge(
          challengeId: widget.challengeId!,
          answers: Map<String, String>.from(_answers),
          timeTaken: _totalTime,
        );
      } else {
        result = await _repo.submitQuiz(
          quizId: widget.quiz.id,
          answers: Map<String, String>.from(_answers),
          timeTaken: _totalTime,
          mode: 'speed',
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(context, FadeScaleRoute(page: QuizResultScreen(result: result, quiz: widget.quiz)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la soumission'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: context.appColors.bg, body: const Center(child: CircularProgressIndicator(color: AppColors.secondary)));
    if (_error != null) return Scaffold(backgroundColor: context.appColors.bg, body: ErrorState(message: _error!, onRetry: _loadQuestions));
    if (_submitting) return Scaffold(backgroundColor: context.appColors.bg, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: AppColors.secondary), SizedBox(height: 16), Text('Calcul des résultats...', style: TextStyle(color: context.appColors.textSecondary))])));

    final q = _current;
    final opts = q.options ?? ['Vrai', 'Faux'];
    final labels = ['A', 'B', 'C', 'D'];
    final timerPercent = _timeLeft / _secondsPerQuestion;

    return PopScope(
      canPop: false,
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
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: context.appColors.cardBg, borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.close_rounded, color: context.appColors.textSecondary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (_index + 1) / _questions.length,
                          backgroundColor: context.appColors.cardBg,
                          valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${_index + 1}/${_questions.length}', style: TextStyle(color: context.appColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                // Speed timer bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                      ),
                      child: const Text('⚡ SPEED', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
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
                              timerPercent > 0.5 ? AppColors.secondary : timerPercent > 0.25 ? AppColors.warning : AppColors.error,
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('$_timeLeft s', style: TextStyle(
                      color: timerPercent > 0.5 ? AppColors.secondary : timerPercent > 0.25 ? AppColors.warning : AppColors.error,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                Align(alignment: Alignment.centerLeft, child: Text('Question ${_index + 1}', style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(q.text, style: TextStyle(color: context.appColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, height: 1.4)),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: opts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final opt = opts[i];
                      return AnswerOptionTile(
                        label: labels[i < labels.length ? i : 0],
                        option: opt,
                        state: !_answered ? AnswerState.idle : (_selected == opt ? AnswerState.selected : AnswerState.idle),
                        onTap: () => _selectAnswer(opt),
                      );
                    },
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
