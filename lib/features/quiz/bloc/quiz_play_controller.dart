import 'dart:async';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

enum PlayPhase { loading, playing, submitting, done }

class QuizPlayController extends ChangeNotifier {
  final int quizId;
  final List<QuestionModel> questions;
  final int timeLimit;

  int _index = 0;
  int _timeLeft = 0;
  int _totalTime = 0;
  Timer? _timer;
  final Map<String, String> _answers = {};
  String? _selected;
  bool _answered = false;
  PlayPhase _phase = PlayPhase.playing;
  QuizAttemptResult? _result;

  int get index        => _index;
  int get timeLeft     => _timeLeft;
  int get totalTime    => _totalTime;
  String? get selected => _selected;
  bool get answered    => _answered;
  PlayPhase get phase  => _phase;
  QuizAttemptResult? get result => _result;

  QuestionModel get currentQuestion => questions[_index];
  bool get isLast => _index >= questions.length - 1;
  double get progress => (_index + 1) / questions.length;
  Map<String, String> get answers => Map.unmodifiable(_answers);

  QuizPlayController({
    required this.quizId,
    required this.questions,
    required this.timeLimit,
  }) {
    _timeLeft = timeLimit;
    _totalTime = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = timeLimit;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _timeLeft--;
      notifyListeners();
      if (_timeLeft <= 0) {
        t.cancel();
        _autoAdvance();
      }
    });
  }

  void _autoAdvance() {
    if (!_answered) {
      // Record as skipped (no answer)
      _totalTime += timeLimit;
    }
    _advance();
  }

  void selectAnswer(String answer) {
    if (_answered) return;
    _timer?.cancel();
    _totalTime += timeLimit - _timeLeft;
    _selected  = answer;
    _answered  = true;
    _answers[currentQuestion.id.toString()] = answer;
    notifyListeners();
  }

  void advance() {
    Future.delayed(const Duration(milliseconds: 800), _advance);
  }

  void _advance() {
    if (_index >= questions.length - 1) {
      _phase = PlayPhase.submitting;
      notifyListeners();
      return;
    }
    _index++;
    _selected = null;
    _answered = false;
    _startTimer();
    notifyListeners();
  }

  void setResult(QuizAttemptResult r) {
    _timer?.cancel();
    _result = r;
    _phase = PlayPhase.done;
    notifyListeners();
  }

  void setLoading() {
    _phase = PlayPhase.loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
