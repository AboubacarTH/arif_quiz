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
import 'package:flutter_animate/flutter_animate.dart';

class SurvivalPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final int? challengeId;

  const SurvivalPlayScreen({super.key, required this.quiz, this.challengeId});

  @override
  State<SurvivalPlayScreen> createState() => _SurvivalPlayScreenState();
}

class _SurvivalPlayScreenState extends State<SurvivalPlayScreen>
    with SingleTickerProviderStateMixin {
  final _repo = QuizRepository(apiService);
  List<QuestionModel> _questions = [];
  bool _loading = true;
  String? _error;
  bool _gameOver = false;
  bool _submitting = false;

  int _index = 0;
  int _timeLeft = 0;
  int _totalTime = 0;
  String? _selected;
  bool _answered = false;
  final Map<String, String> _answers = {};
  Timer? _timer;
  late AnimationController _shakeCtrl;

  QuestionModel get _current => _questions[_index];

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await _repo.getQuizQuestions(widget.quiz.id);
      setState(() {
        _questions = data.questions;
        _timeLeft = data.timeLimit;
        _loading = false;
      });
      _startTimer(data.timeLimit);
    } catch (_) {
      setState(() {
        _error = 'Impossible de charger les questions.';
        _loading = false;
      });
    }
  }

  void _startTimer(int limit) {
    _timer?.cancel();
    _timeLeft = limit;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _handleAnswer(null);
      }
    });
  }

  void _handleAnswer(String? answer) {
    if (_answered || _gameOver) return;
    _timer?.cancel();
    _totalTime += (widget.quiz.timeLimit - _timeLeft).abs();

    final isCorrect = answer != null &&
        _questions[_index].options != null &&
        answer.isNotEmpty;

    setState(() {
      _selected = answer;
      _answered = true;
      if (answer != null) _answers[_current.id.toString()] = answer;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (isCorrect) {
        _advance();
      } else {
        _triggerGameOver();
      }
    });
  }

  void _triggerGameOver() {
    _shakeCtrl.forward(from: 0);
    setState(() => _gameOver = true);
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
    _startTimer(widget.quiz.timeLimit);
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
          mode: 'survival',
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
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: context.appColors.bg, body: const Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_error != null) return Scaffold(backgroundColor: context.appColors.bg, body: ErrorState(message: _error!, onRetry: _loadQuestions));
    if (_submitting) return Scaffold(backgroundColor: context.appColors.bg, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: AppColors.primary), SizedBox(height: 16), Text('Calcul des résultats...', style: TextStyle(color: context.appColors.textSecondary))])));

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: _gameOver ? _buildGameOver() : _buildQuestion(),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _current;
    final opts = q.options ?? ['Vrai', 'Faux'];
    final labels = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header
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
                    valueColor: const AlwaysStoppedAnimation(AppColors.error),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_index + 1}/${_questions.length}', style: TextStyle(color: context.appColors.textSecondary, fontSize: 13)),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: const Text('MODE SURVIE', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: context.appColors.cardBg, borderRadius: BorderRadius.circular(20)),
                child: Text('$_timeLeft s', style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Align(alignment: Alignment.centerLeft, child: Text('Question ${_index + 1}', style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
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
                  onTap: () {
                    _handleAnswer(opt);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💔', style: TextStyle(fontSize: 64)).animate().shake(),
            const SizedBox(height: 20),
            const Text('Game Over !', style: TextStyle(color: AppColors.error, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Tu as survécu ${_index} question${_index > 1 ? 's' : ''}',
                style: TextStyle(color: context.appColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _submitResults,
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Voir les résultats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Quitter', style: TextStyle(color: context.appColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
