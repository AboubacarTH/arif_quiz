import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

QuestionModel _q(int id, String correct) => QuestionModel(
      id: id,
      text: 'Q$id',
      type: 'multiple_choice',
      options: const ['A', 'B', 'C', 'D'],
      correctAnswer: correct,
      points: 10,
      order: id,
    );

void main() {
  List<QuestionModel> qs(int count) =>
      List.generate(count, (i) => _q(i + 1, 'A'));

  // ─── Série ────────────────────────────────────────────────────────────────

  group('Série, le barème', () {
    test('les paliers montent toutes les deux bonnes réponses', () {
      expect(ModeScoring.streakTier(1), 1);
      expect(ModeScoring.streakTier(2), 1);
      expect(ModeScoring.streakTier(3), 2);
      expect(ModeScoring.streakTier(5), 3);
      expect(ModeScoring.streakTier(7), 4);
      expect(ModeScoring.streakTier(50), 4,
          reason: 'le dernier palier ne monte plus');
    });

    test('l\'ordre change le total à nombre égal de bonnes réponses', () {
      // Six d'affilée : 1+1+2+2+3+3 = 12.
      final grouped = List<bool>.filled(6, true);
      // Les mêmes six, une sur deux : six séries de un.
      final scattered = [
        true, false, true, false, true, false, //
        true, false, true, false, true,
      ];

      expect(ModeScoring.streakPoints(grouped), 12);
      expect(ModeScoring.streakPoints(scattered), 6);
    });

    test('une erreur remet la série à zéro', () {
      expect(
        ModeScoring.streakPoints([true, true, true, false, true, true, true]),
        8,
        reason: '1+1+2 puis 1+1+2',
      );
    });

    test('le maximum est la manche sans faute', () {
      // 1+1+2+2+3+3+4+4+4+4 = 28.
      expect(ModeScoring.maxPoints(GameMode.streak, 10), 28);
      expect(ModeScoring.score(GameMode.streak, List.filled(10, true), 0, 10),
          100);
    });
  });

  group('Série, en cours de partie', () {
    test('la série se compte, et se perd', () {
      fakeAsync((async) {
        final c = GamePlayController(
            mode: GameMode.streak,
            questions: qs(6),
            secondsPerQuestion: 30,
            revealDelayMs: 100);

        expect(c.currentStreak, 0);
        expect(c.nextStreakTier, 1);

        for (var i = 0; i < 3; i++) {
          c.selectAnswer('A');
          async.elapse(const Duration(milliseconds: 100));
        }

        expect(c.currentStreak, 3);
        expect(c.nextStreakTier, 2, reason: 'la quatrième vaudra deux points');
        expect(c.modePoints, 4, reason: '1+1+2');

        c.selectAnswer('B');
        async.elapse(const Duration(milliseconds: 100));

        expect(c.currentStreak, 0, reason: 'une erreur casse la série');
        expect(c.nextStreakTier, 1);
        expect(c.modePoints, 4, reason: 'ce qui est acquis reste acquis');

        c.dispose();
      });
    });

    test('une question passée casse aussi la série', () {
      fakeAsync((async) {
        final c = GamePlayController(
            mode: GameMode.streak,
            questions: qs(4),
            secondsPerQuestion: 30,
            revealDelayMs: 100);

        c.selectAnswer('A');
        async.elapse(const Duration(milliseconds: 100));
        c.skip();
        async.elapse(const Duration(milliseconds: 100));

        expect(c.currentStreak, 0);
        c.dispose();
      });
    });
  });

  // ─── Contre-la-montre ─────────────────────────────────────────────────────

  group('Contre-la-montre', () {
    GamePlayController build(int questions) => GamePlayController(
          mode: GameMode.timeattack,
          questions: qs(questions),
          secondsPerQuestion: 60,
          clock: GameClock.global,
          bonusSecondsPerCorrect: 5,
          revealDelayMs: 100,
        );

    test('une seule horloge : elle ne repart pas d\'une question à l\'autre',
        () {
      fakeAsync((async) {
        final c = build(4);
        expect(c.timeLeft, 60);

        async.elapse(const Duration(seconds: 10));
        expect(c.timeLeft, 50);

        c.selectAnswer('B'); // faux : aucun bonus
        async.elapse(const Duration(milliseconds: 100));

        expect(c.index, 1);
        expect(c.timeLeft, lessThanOrEqualTo(50),
            reason: 'la question suivante hérite du temps restant');

        c.dispose();
      });
    });

    test('une bonne réponse rend du temps', () {
      fakeAsync((async) {
        final c = build(4);
        async.elapse(const Duration(seconds: 10));
        expect(c.timeLeft, 50);

        c.selectAnswer('A');
        expect(c.timeLeft, 55, reason: '+5 s pour une bonne réponse');

        c.dispose();
      });
    });

    test('le chrono à zéro termine la manche, questions restantes ou non', () {
      fakeAsync((async) {
        final c = build(20);
        async.elapse(const Duration(seconds: 60));

        expect(c.phase, GamePhase.submitting);
        expect(c.index, 0, reason: 'on n\'a pas eu le temps d\'avancer');

        c.dispose();
      });
    });

    test('le temps passé est celui de l\'horloge, bonus compris', () {
      fakeAsync((async) {
        final c = build(4);
        async.elapse(const Duration(seconds: 25));

        expect(c.totalTime, 25);
        c.dispose();
      });
    });

    test('répondre à tout arrête l\'horloge avant la fin du temps', () {
      fakeAsync((async) {
        final c = build(2);

        c.selectAnswer('A');
        async.elapse(const Duration(milliseconds: 100));
        c.selectAnswer('A');
        async.elapse(const Duration(milliseconds: 100));

        expect(c.phase, GamePhase.submitting);
        final stoppedAt = c.totalTime;
        async.elapse(const Duration(seconds: 10));
        expect(c.totalTime, stoppedAt, reason: 'le chrono est bien arrêté');

        c.dispose();
      });
    });

    test('ce mode ne tient pas de total en points', () {
      fakeAsync((async) {
        final c = build(4);
        expect(c.modePoints, isNull);
        expect(c.maxModePoints, isNull);
        c.dispose();
      });
    });
  });

  // ─── Jokers ───────────────────────────────────────────────────────────────

  group('Jokers', () {
    GamePlayController build() => GamePlayController(
          mode: GameMode.jokers,
          questions: qs(5),
          secondsPerQuestion: 30,
          revealDelayMs: 100,
        );

    test('trois coups de pouce, pas un de plus', () {
      fakeAsync((async) {
        final c = build();
        expect(c.jokersLeft, ModeScoring.jokerCount);

        for (var i = 0; i < ModeScoring.jokerCount; i++) {
          expect(c.useJoker(), isTrue);
        }

        expect(c.jokersLeft, 0);
        expect(c.useJoker(), isFalse, reason: 'la réserve est vide');
        expect(c.jokersUsed, ModeScoring.jokerCount);

        c.dispose();
      });
    });

    test('un coup de pouce ne sert plus une fois la question jouée', () {
      fakeAsync((async) {
        final c = build();
        c.selectAnswer('A');

        expect(c.useJoker(), isFalse);
        expect(c.jokersUsed, 0);

        c.dispose();
      });
    });

    test('chaque coup de pouce coûte un point', () {
      fakeAsync((async) {
        final c = build();

        c.selectAnswer('A');
        async.elapse(const Duration(milliseconds: 100));
        expect(c.modePoints, 2);

        c.useJoker();
        expect(c.modePoints, 1, reason: '2 − 1');

        c.dispose();
      });
    });

    test('le joker du temps rallonge la question', () {
      fakeAsync((async) {
        final c = build();
        async.elapse(const Duration(seconds: 5));
        expect(c.timeLeft, 25);

        c.addSeconds(ModeScoring.jokerTimeBonus);

        expect(c.timeLeft, 40);
        expect(c.timePercent, lessThanOrEqualTo(1.0),
            reason: 'la barre ne doit pas déborder de son cadre');

        c.dispose();
      });
    });

    test('le maximum ignore les coups de pouce', () {
      expect(ModeScoring.maxPoints(GameMode.jokers, 10), 20);
      expect(
        ModeScoring.points(GameMode.jokers, List.filled(8, true), 2,
            jokersUsed: 3),
        13,
        reason: '8 justes × 2, moins 3',
      );
    });
  });

  // ─── La notation d'un invité suit la même route ───────────────────────────

  test('le scoring local applique le barème de la Série', () {
    final questions = qs(5);
    // Trois justes d'affilée, puis deux fausses : 1+1+2 = 4 sur 7.
    final result = QuizAttemptResult.fromLocalScoring(
      questions: questions,
      answers: {'1': 'A', '2': 'A', '3': 'A', '4': 'B', '5': 'B'},
      timeTaken: 30,
      mode: GameMode.streak,
    );

    expect(result.modePoints, 4);
    expect(result.maxModePoints, 9, reason: '1+1+2+2+3');
    expect(result.correctCount, 3);
  });

  test('le scoring local retire les coups de pouce', () {
    final result = QuizAttemptResult.fromLocalScoring(
      questions: qs(4),
      answers: {'1': 'A', '2': 'A', '3': 'A', '4': 'A'},
      timeTaken: 30,
      mode: GameMode.jokers,
      jokersUsed: 2,
    );

    expect(result.modePoints, 6, reason: '4 justes × 2, moins 2');
    expect(result.maxModePoints, 8);
  });
}
