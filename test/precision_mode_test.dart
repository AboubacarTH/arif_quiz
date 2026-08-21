import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

QuestionModel _q(
  int id,
  String correct, {
  String? text,
  List<String>? options,
}) =>
    QuestionModel(
      id: id,
      text: text ?? 'Q$id',
      type: 'multiple_choice',
      options: options ?? const ['A', 'B', 'C', 'D'],
      correctAnswer: correct,
      points: 10,
      order: id,
    );

void main() {
  List<QuestionModel> qs() => [_q(1, 'A'), _q(2, 'A'), _q(3, 'A'), _q(4, 'A')];

  // ─── Le barème, qui doit dire la même chose que le serveur ────────────────

  group('ModeScoring', () {
    test('+2 pour une bonne réponse, −1 pour une mauvaise', () {
      expect(ModeScoring.points(GameMode.precision, 1, 0), 2);
      expect(ModeScoring.points(GameMode.precision, 0, 1), -1);
      expect(ModeScoring.points(GameMode.precision, 0, 0), 0,
          reason: 'passer ne rapporte ni ne coûte rien');
    });

    test('les autres modes n\'ont pas de total', () {
      for (final mode in [GameMode.classic, GameMode.speed, GameMode.survival]) {
        expect(ModeScoring.points(mode, 5, 3), isNull);
        expect(ModeScoring.maxPoints(mode, 10), isNull);
      }
    });

    test('le score est la part du maximum atteint', () {
      // 7 justes, 3 fausses : 14 − 3 = 11 sur 20.
      expect(ModeScoring.score(GameMode.precision, 7, 3, 10), 55);
      expect(ModeScoring.score(GameMode.precision, 10, 0, 10), 100);
    });

    test('un total négatif vaut zéro, pas un score négatif', () {
      expect(ModeScoring.score(GameMode.precision, 2, 8, 10), 0);
    });

    test('les autres modes gardent le taux de réussite', () {
      expect(ModeScoring.score(GameMode.classic, 7, 3, 10), 70);
      expect(ModeScoring.score(GameMode.speed, 7, 3, 10), 70);
    });

    test('le total négatif porte le vrai signe moins', () {
      // La pastille de gain et le libellé du mode emploient U+2212 ; le total
      // doit s'écrire pareil, les trois se lisant côte à côte.
      expect(ModeScoring.format(-3), '−3');
      expect(ModeScoring.format(0), '0');
      expect(ModeScoring.format(12), '12');
    });
  });

  // ─── Ce que la partie compte au fil des questions ─────────────────────────

  group('Précision, en cours de partie', () {
    test('juste, faux et passé se comptent séparément', () {
      fakeAsync((async) {
        final c = GamePlayController(
            mode: GameMode.precision,
            questions: qs(),
            secondsPerQuestion: 30,
            revealDelayMs: 100);

        expect(c.modePoints, 0);
        expect(c.maxModePoints, 8, reason: '4 questions × 2 points');

        c.selectAnswer('A'); // juste
        expect(c.currentOutcome, AnswerOutcome.right);
        expect(c.modePoints, 2);
        async.elapse(const Duration(milliseconds: 100));

        c.selectAnswer('B'); // faux
        expect(c.currentOutcome, AnswerOutcome.wrong);
        expect(c.modePoints, 1);
        async.elapse(const Duration(milliseconds: 100));

        c.skip(); // passé
        expect(c.currentOutcome, AnswerOutcome.skipped);
        expect(c.modePoints, 1, reason: 'passer ne change pas le total');

        c.dispose();
      });
    });

    test('le temps écoulé sans réponse ne coûte rien', () {
      fakeAsync((async) {
        final c = GamePlayController(
            mode: GameMode.precision,
            questions: qs(),
            secondsPerQuestion: 10,
            revealDelayMs: 100);

        async.elapse(const Duration(seconds: 10));
        expect(c.outcomes.first, AnswerOutcome.skipped,
            reason: 'ne pas répondre n\'est pas se tromper');
        expect(c.modePoints, 0);

        c.dispose();
      });
    });

    test('une question ne reçoit qu\'une issue', () {
      fakeAsync((async) {
        final c = GamePlayController(
            mode: GameMode.precision,
            questions: qs(),
            secondsPerQuestion: 30,
            revealDelayMs: 100);

        c.selectAnswer('A');
        c.selectAnswer('B');
        c.skip();

        expect(c.outcomes.length, 1);
        expect(c.modePoints, 2);

        c.dispose();
      });
    });

    test('le total peut passer sous zéro pendant la partie', () {
      fakeAsync((async) {
        final c = GamePlayController(
            mode: GameMode.precision,
            questions: qs(),
            secondsPerQuestion: 30,
            revealDelayMs: 100);

        for (var i = 0; i < 3; i++) {
          c.selectAnswer('B');
          async.elapse(const Duration(milliseconds: 100));
        }

        expect(c.modePoints, -3);
        c.dispose();
      });
    });

    test('les autres modes n\'affichent aucun total', () {
      fakeAsync((async) {
        final c = GamePlayController(
            mode: GameMode.classic, questions: qs(), secondsPerQuestion: 30);
        expect(c.modePoints, isNull);
        expect(c.maxModePoints, isNull);
        c.dispose();
      });
    });
  });

  // ─── La note d'une partie d'invité ────────────────────────────────────────

  group('Scoring local', () {
    test('la pénalité s\'applique hors ligne comme en ligne', () {
      final questions = [
        _q(1, 'A'), _q(2, 'A'), _q(3, 'A'), _q(4, 'A'), _q(5, 'A'),
      ];
      // Deux justes, deux fausses, une laissée vide : 4 − 2 = 2 sur 10.
      final answers = {'1': 'A', '2': 'A', '3': 'B', '4': 'B'};

      final result = QuizAttemptResult.fromLocalScoring(
        questions: questions,
        answers: answers,
        timeTaken: 42,
        mode: GameMode.precision,
      );

      expect(result.modePoints, 2);
      expect(result.maxModePoints, 10);
      expect(result.score, 20);
      expect(result.correctCount, 2);
    });

    test('sans mode, la note reste le taux de réussite', () {
      final questions = [_q(1, 'A'), _q(2, 'A'), _q(3, 'A'), _q(4, 'A')];
      final result = QuizAttemptResult.fromLocalScoring(
        questions: questions,
        answers: {'1': 'A', '2': 'B'},
        timeTaken: 10,
      );

      expect(result.score, 25);
      expect(result.modePoints, isNull);
    });
  });

  // ─── Le temps du Speed Round ──────────────────────────────────────────────

  group('speedSecondsFor', () {
    test('une question brève garde le plancher', () {
      expect(speedSecondsFor(_q(1, 'A', text: 'Capitale ?', options: const ['A', 'B'])),
          kSpeedMinSeconds);
    });

    test('une question longue reçoit davantage, sans dépasser le plafond', () {
      final long = _q(
        1,
        'A',
        text: 'Lequel de ces instruments de bord indique la vitesse verticale '
            'de l\'aéronef, exprimée en pieds par minute, et sur quel principe '
            'physique repose-t-il exactement ?',
        options: const [
          'Le variomètre, par comparaison de pression statique',
          'L\'anémomètre, par comparaison de pression totale',
          'L\'altimètre barométrique, par mesure absolue',
          'Le badin, par mesure de pression dynamique',
        ],
      );

      final seconds = speedSecondsFor(long);
      expect(seconds, greaterThan(kSpeedMinSeconds));
      expect(seconds, lessThanOrEqualTo(kSpeedMaxSeconds));
    });

    test('le budget reste toujours entre les deux bornes', () {
      final enormous = _q(1, 'A',
          text: 'x' * 5000, options: List.filled(4, 'y' * 500));
      expect(speedSecondsFor(enormous), kSpeedMaxSeconds);
    });

    test('une question sans options servies compte quand même ses choix', () {
      // Vrai/faux : les libellés viennent du contexte, pas de l'API. Le budget
      // ne doit pas les oublier pour autant.
      final trueFalse = _q(1, 'true', text: 'x' * 150, options: null);
      final withOptions = _q(1, 'true', text: 'x' * 150, options: const []);

      expect(speedSecondsFor(trueFalse), speedSecondsFor(withOptions));
    });

    test('le contrôleur applique le budget question par question', () {
      fakeAsync((async) {
        final short = _q(1, 'A', text: 'Court ?', options: const ['A', 'B']);
        final long = _q(2, 'A',
            text: 'x' * 400, options: const ['y', 'z', 'w', 'v']);

        final c = GamePlayController(
          mode: GameMode.speed,
          questions: [short, long],
          secondsPerQuestion: kSpeedMinSeconds,
          secondsFor: speedSecondsFor,
          revealDelayMs: 100,
        );

        expect(c.currentSeconds, kSpeedMinSeconds);
        c.selectAnswer('A');
        async.elapse(const Duration(milliseconds: 100));

        expect(c.index, 1);
        expect(c.currentSeconds, kSpeedMaxSeconds,
            reason: 'la question suivante est longue, elle a plus de temps');
        expect(c.timePercent, closeTo(1.0, 0.001));

        c.dispose();
      });
    });
  });
}
