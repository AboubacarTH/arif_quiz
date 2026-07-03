import 'dart:async';

import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

/// Phases du cycle de jeu, communes aux trois modes.
enum GamePhase { playing, gameOver, submitting, done }

/// Contrôleur de jeu unifié pour les modes Classique, Speed et Survie.
///
/// Il centralise la machine à états (timer par question, sélection,
/// révélation, avance, game over) auparavant dupliquée dans chaque écran.
/// Chaque écran conserve sa propre UI et lit l'état ici ; le chargement des
/// questions et la soumission (API / invité / défi) restent dans l'écran.
class GamePlayController extends ChangeNotifier {
  GamePlayController({
    required this.mode,
    required this.questions,
    required this.secondsPerQuestion,
    int? revealDelayMs,
  }) : revealDelayMs = revealDelayMs ?? _defaultRevealDelay(mode) {
    _startTimer();
  }

  final GameMode mode;
  final List<QuestionModel> questions;
  final int secondsPerQuestion;
  final int revealDelayMs;

  final Map<String, String> _answers = {};

  int _index = 0;
  int _timeLeft = 0;
  int _totalTime = 0;
  String? _selected;
  bool _answered = false;
  GamePhase _phase = GamePhase.playing;
  QuizAttemptResult? _result;

  Timer? _timer;
  Timer? _revealTimer;

  bool get _stopOnWrong => mode == GameMode.survival;

  // ── État exposé ──
  int get index => _index;
  int get timeLeft => _timeLeft;
  int get totalTime => _totalTime;
  String? get selected => _selected;
  bool get answered => _answered;
  GamePhase get phase => _phase;
  QuizAttemptResult? get result => _result;

  QuestionModel get currentQuestion => questions[_index];
  bool get isLast => _index >= questions.length - 1;
  double get progress => questions.isEmpty ? 0 : (_index + 1) / questions.length;
  double get timePercent =>
      secondsPerQuestion == 0 ? 0 : _timeLeft / secondsPerQuestion;
  Map<String, String> get answers => Map.unmodifiable(_answers);

  /// Nombre de questions passées avant la fin (mort en Survie) — pour l'affichage.
  int get survivedCount => _index;

  /// Questions à soumettre : sous-ensemble joué en Survie, sinon toutes.
  List<QuestionModel> get playedQuestions => mode == GameMode.survival
      ? questions.take((_index + 1).clamp(1, questions.length)).toList()
      : questions;

  static int _defaultRevealDelay(GameMode mode) => switch (mode) {
        GameMode.speed => 500,
        GameMode.survival => 700,
        GameMode.classic => 800,
      };

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _timeLeft--;
      notifyListeners();
      if (_timeLeft <= 0) {
        t.cancel();
        _lockAnswer(null);
      }
    });
  }

  /// Sélection utilisateur.
  void selectAnswer(String answer) => _lockAnswer(answer);

  /// Passe la question sans répondre (bouton « Skip » du mode Classique).
  void skip() {
    if (_answered || _phase != GamePhase.playing) return;
    _timer?.cancel();
    _totalTime += secondsPerQuestion - _timeLeft;
    _answered = true;
    notifyListeners();
    _revealTimer = Timer(Duration(milliseconds: revealDelayMs), _advance);
  }

  void _lockAnswer(String? answer) {
    if (_answered || _phase != GamePhase.playing) return;
    _timer?.cancel();
    _totalTime += secondsPerQuestion - _timeLeft;
    _selected = answer;
    _answered = true;
    if (answer != null) _answers[currentQuestion.id.toString()] = answer;
    final correct = currentQuestion.isCorrect(answer);
    notifyListeners();
    _revealTimer = Timer(Duration(milliseconds: revealDelayMs), () {
      if (_stopOnWrong && !correct) {
        _phase = GamePhase.gameOver;
        notifyListeners();
      } else {
        _advance();
      }
    });
  }

  void _advance() {
    if (isLast) {
      _phase = GamePhase.submitting;
      notifyListeners();
      return;
    }
    _index++;
    _selected = null;
    _answered = false;
    _startTimer();
    notifyListeners();
  }

  /// Injecte le résultat final (après soumission API / scoring local).
  void setResult(QuizAttemptResult r) {
    _timer?.cancel();
    _revealTimer?.cancel();
    _result = r;
    _phase = GamePhase.done;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _revealTimer?.cancel();
    super.dispose();
  }
}
