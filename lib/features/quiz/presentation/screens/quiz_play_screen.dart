import 'dart:async';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _loading = true;
  int _timeLeft = 30;
  int _totalTimeTaken = 0;
  Timer? _timer;
  final Map<String, String> _answers = {};
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final res = await apiService.getQuizQuestions(widget.quiz.id);
      setState(() {
        _questions = (res['questions'] as List).map((q) => QuestionModel.fromJson(q)).toList();
        _timeLeft   = widget.quiz.timeLimit;
        _loading    = false;
      });
      _startTimer();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = widget.quiz.timeLimit;
    _progressController.value = 1.0;
    _progressController.reverse(from: 1.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _nextQuestion();
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _totalTimeTaken += widget.quiz.timeLimit - _timeLeft;
      _answers[_questions[_currentIndex].id.toString()] = answer;
    });

    Future.delayed(const Duration(milliseconds: 900), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex >= _questions.length - 1) {
      _submitQuiz();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
    _startTimer();
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();
    try {
      final res = await apiService.submitQuiz(
        quizId: widget.quiz.id,
        answers: _answers,
        timeTaken: _totalTimeTaken,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            result: QuizAttemptResult.fromJson(res),
            quiz: widget.quiz,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Check your connection.')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('No questions available', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final question = _questions[_currentIndex];
    final timerRatio = _timeLeft / widget.quiz.timeLimit;
    final timerColor = timerRatio > 0.5
        ? AppColors.success
        : timerRatio > 0.25
            ? AppColors.warning
            : AppColors.error;

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            title: const Text('Quit Quiz?', style: TextStyle(color: AppColors.textPrimary)),
            content: const Text('Your progress will be lost.', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Quit', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          backgroundColor: AppColors.cardBg,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Timer
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: timerRatio,
                          backgroundColor: AppColors.cardBg,
                          valueColor: AlwaysStoppedAnimation(timerColor),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '$_timeLeft',
                        style: TextStyle(
                          color: timerColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Question
                Text(
                  'Question ${_currentIndex + 1}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  question.text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Answer options
                Expanded(
                  child: ListView(
                    children: (question.options ?? ['True', 'False']).map((option) {
                      Color bg = AppColors.cardBg;
                      Color border = AppColors.cardBgLight;
                      Color text = AppColors.textPrimary;

                      if (_answered && _selectedAnswer == option) {
                        bg = AppColors.primary.withOpacity(0.2);
                        border = AppColors.primary;
                        text = AppColors.primary;
                      }

                      return GestureDetector(
                        onTap: () => _selectAnswer(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border, width: 2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_answered && _selectedAnswer == option)
                                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Skip button
                if (!_answered)
                  Center(
                    child: TextButton(
                      onPressed: _nextQuestion,
                      child: const Text(
                        'Skip →',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
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
