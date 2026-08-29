import 'dart:async';

import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

/// Phases du cycle de jeu, communes à tous les modes.
enum GamePhase { playing, gameOver, submitting, done }

/// Qui tient le temps.
///
/// [perQuestion] : chaque question a son budget, et l'épuiser passe à la
/// suivante. [global] : une seule horloge pour toute la manche — l'épuiser
/// termine la partie, où qu'on en soit. C'est toute la différence du mode
/// Contre-la-montre, et elle ne pouvait pas se loger dans un écran : la
/// machine à états du jeu est ici.
enum GameClock { perQuestion, global }

/// Ce qu'une question est devenue. Un mode qui pénalise l'erreur doit pouvoir
/// distinguer « faux » de « pas répondu » — pour le barème comme pour ce que le
/// joueur voit s'afficher.
enum AnswerOutcome { right, wrong, skipped }

/// Le temps de lecture accordé à une question en Speed Round.
///
/// Cinq secondes fixes étaient intenables : le même budget servait à une
/// question de quarante caractères et à une question de deux cents, options
/// comprises, et il fallait encore lire les quatre choix avant de décider. Le
/// budget suit donc la longueur du texte, entre deux bornes qui gardent le mode
/// nerveux : jamais moins de [kSpeedMinSeconds], jamais plus de
/// [kSpeedMaxSeconds].
int speedSecondsFor(QuestionModel question) {
  final options = question.options ?? const <String>[];
  final characters = question.text.length +
      (options.isEmpty
          // Une question vrai/faux sans options servies : ses deux libellés
          // sont courts et connus, inutile de les demander au contexte.
          ? 10
          : options.fold<int>(0, (sum, o) => sum + o.length));

  // ~15 caractères lus par seconde en survol, plus trois secondes pour choisir.
  final budget = (characters / 15).ceil() + 3;

  return budget.clamp(kSpeedMinSeconds, kSpeedMaxSeconds);
}

const kSpeedMinSeconds = 8;
const kSpeedMaxSeconds = 15;

/// Contrôleur de jeu unifié pour tous les modes.
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
    this.secondsFor,
    this.clock = GameClock.perQuestion,
    this.bonusSecondsPerCorrect = 0,
    int? revealDelayMs,
  }) : revealDelayMs = revealDelayMs ?? _defaultRevealDelay(mode) {
    _startTimer();
  }

  final GameMode mode;
  final List<QuestionModel> questions;

  /// Budget de départ du chronomètre : celui d'une question quand l'horloge est
  /// [GameClock.perQuestion], celui de la manche entière quand elle est
  /// [GameClock.global].
  final int secondsPerQuestion;

  /// Budget calculé pour une question donnée. Le Speed Round s'en sert pour
  /// accorder plus de temps à une question longue qu'à une question brève.
  final int Function(QuestionModel)? secondsFor;

  final GameClock clock;

  /// Ce qu'une bonne réponse rend au chrono, en horloge globale.
  final int bonusSecondsPerCorrect;

  final int revealDelayMs;

  final Map<String, String> _answers = {};
  final List<AnswerOutcome> _outcomes = [];

  int _jokersUsed = 0;

  int _index = 0;
  int _timeLeft = 0;
  int _totalTime = 0;

  /// Le budget de la question en cours, figé au moment où elle s'affiche : le
  /// recalculer en route ferait sauter la barre de temps.
  int _currentSeconds = 0;
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

  /// Le temps accordé à la question en cours.
  int get currentSeconds => _currentSeconds;
  String? get selected => _selected;
  bool get answered => _answered;
  GamePhase get phase => _phase;
  QuizAttemptResult? get result => _result;

  QuestionModel get currentQuestion => questions[_index];
  bool get isLast => _index >= questions.length - 1;
  double get progress => questions.isEmpty ? 0 : (_index + 1) / questions.length;
  double get timePercent =>
      _currentSeconds == 0 ? 0 : _timeLeft / _currentSeconds;
  Map<String, String> get answers => Map.unmodifiable(_answers);

  /// Les issues des questions déjà jouées, la dernière en fin de liste.
  List<AnswerOutcome> get outcomes => List.unmodifiable(_outcomes);

  /// L'issue de la question en cours, une fois révélée. `null` tant que le
  /// joueur n'a ni répondu ni passé.
  AnswerOutcome? get currentOutcome =>
      _outcomes.length > _index ? _outcomes[_index] : null;

  int get rightCount =>
      _outcomes.where((o) => o == AnswerOutcome.right).length;
  int get wrongCount =>
      _outcomes.where((o) => o == AnswerOutcome.wrong).length;

  /// Les issues sous la forme qu'attend le barème : juste ou pas, dans l'ordre.
  List<bool> get _sequence =>
      _outcomes.map((o) => o == AnswerOutcome.right).toList();

  /// La série de bonnes réponses en cours. Une erreur ou une question passée la
  /// remet à zéro.
  int get currentStreak {
    var streak = 0;
    for (final outcome in _outcomes.reversed) {
      if (outcome != AnswerOutcome.right) break;
      streak++;
    }
    return streak;
  }

  /// Ce que rapportera la PROCHAINE bonne réponse. C'est le chiffre qui donne
  /// envie de continuer — pas celui qu'on vient d'encaisser.
  int get nextStreakTier => ModeScoring.streakTier(currentStreak + 1);

  int get jokersUsed => _jokersUsed;
  int get jokersLeft => ModeScoring.jokerCount - _jokersUsed;

  /// Le total du mode, tel qu'il doit s'afficher pendant la partie. `null` pour
  /// les modes qui n'en ont pas.
  int? get modePoints =>
      ModeScoring.points(mode, _sequence, wrongCount, jokersUsed: _jokersUsed);

  /// Le maximum atteignable sur l'ensemble des questions.
  int? get maxModePoints => ModeScoring.maxPoints(mode, questions.length);

  /// Nombre de questions passées avant la fin (mort en Survie) — pour l'affichage.
  int get survivedCount => _index;

  /// Questions à soumettre : sous-ensemble joué en Survie, sinon toutes.
  List<QuestionModel> get playedQuestions => mode == GameMode.survival
      ? questions.take((_index + 1).clamp(1, questions.length)).toList()
      : questions;

  static int _defaultRevealDelay(GameMode mode) => switch (mode) {
        GameMode.speed => 500,
        GameMode.survival => 700,
        // En Précision et en Série, la révélation porte un gain ou une perte :
        // il faut le temps de la lire.
        GameMode.precision || GameMode.streak => 900,
        // En Contre-la-montre, l'horloge tourne pendant la révélation : la
        // faire durer reviendrait à voler du temps au joueur.
        GameMode.timeattack => 350,
        GameMode.classic || GameMode.jokers => 800,
      };

  void _startTimer() {
    if (clock == GameClock.global) {
      // Une seule horloge pour la manche : on ne la relance pas d'une question
      // à l'autre, sinon le mode n'aurait plus rien d'un contre-la-montre.
      if (_timer != null) return;

      _currentSeconds = secondsPerQuestion;
      _timeLeft = _currentSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        _timeLeft--;
        _totalTime++;
        notifyListeners();
        if (_timeLeft <= 0) {
          t.cancel();
          _endRound();
        }
      });
      return;
    }

    _timer?.cancel();
    _currentSeconds = secondsFor?.call(currentQuestion) ?? secondsPerQuestion;
    _timeLeft = _currentSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _timeLeft--;
      notifyListeners();
      if (_timeLeft <= 0) {
        t.cancel();
        _lockAnswer(null);
      }
    });
  }

  /// Le chrono est tombé : la manche s'arrête là, questions restantes ou non.
  void _endRound() {
    _revealTimer?.cancel();
    _phase = GamePhase.submitting;
    notifyListeners();
  }

  /// Consomme un coup de pouce. Rend `false` s'il n'en reste plus, ou si la
  /// question est déjà jouée — un joker ne sert à rien après coup.
  bool useJoker() {
    if (jokersLeft <= 0 || _answered || _phase != GamePhase.playing) {
      return false;
    }
    _jokersUsed++;
    notifyListeners();
    return true;
  }

  /// Rallonge le temps restant. Le joker « du temps » s'en sert.
  void addSeconds(int seconds) {
    _timeLeft += seconds;
    if (clock == GameClock.perQuestion) _currentSeconds += seconds;
    notifyListeners();
  }

  /// Sélection utilisateur.
  void selectAnswer(String answer) => _lockAnswer(answer);

  /// Passe la question sans répondre (bouton « Skip » du mode Classique).
  void skip() {
    if (_answered || _phase != GamePhase.playing) return;
    if (clock == GameClock.perQuestion) {
      _timer?.cancel();
      _totalTime += _currentSeconds - _timeLeft;
    }
    _answered = true;
    _record(AnswerOutcome.skipped);
    notifyListeners();
    _revealTimer = Timer(Duration(milliseconds: revealDelayMs), _advance);
  }

  void _lockAnswer(String? answer) {
    if (_answered || _phase != GamePhase.playing) return;
    if (clock == GameClock.perQuestion) {
      _timer?.cancel();
      _totalTime += _currentSeconds - _timeLeft;
    }
    _selected = answer;
    _answered = true;
    if (answer != null) _answers[currentQuestion.id.toString()] = answer;
    final correct = currentQuestion.isCorrect(answer);
    // Le temps écoulé sans réponse n'est pas une erreur : il vaut la même chose
    // que passer, ce qui en Précision revient à ne rien risquer.
    _record(answer == null
        ? AnswerOutcome.skipped
        : correct
            ? AnswerOutcome.right
            : AnswerOutcome.wrong);
    // En horloge globale, une bonne réponse rend du temps : c'est ce qui fait
    // durer la manche, et donc tout l'enjeu.
    if (clock == GameClock.global && correct && bonusSecondsPerCorrect > 0) {
      _timeLeft += bonusSecondsPerCorrect;
    }

    notifyListeners();
    _revealTimer = Timer(Duration(milliseconds: revealDelayMs), () {
      if (_phase != GamePhase.playing) return;
      if (_stopOnWrong && !correct) {
        _phase = GamePhase.gameOver;
        notifyListeners();
      } else {
        _advance();
      }
    });
  }

  /// Une question ne peut avoir qu'une issue : la liste suit l'index, elle ne
  /// s'allonge pas deux fois pour la même question.
  void _record(AnswerOutcome outcome) {
    if (_outcomes.length > _index) return;
    _outcomes.add(outcome);
  }

  void _advance() {
    if (isLast) {
      // Plus de question : la manche est finie, l'horloge de la manche aussi.
      if (clock == GameClock.global) _timer?.cancel();
      _phase = GamePhase.submitting;
      notifyListeners();
      return;
    }
    _index++;
    _selected = null;
    _answered = false;
    // En horloge globale, rien à relancer : le chrono de la manche court
    // toujours.
    if (clock == GameClock.perQuestion) _startTimer();
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
