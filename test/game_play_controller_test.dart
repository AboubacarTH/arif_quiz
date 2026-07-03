import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

QuestionModel _q(int id, String correct) => QuestionModel(
      id: id,
      text: 'Q$id',
      type: 'multiple_choice',
      options: const ['A', 'B'],
      correctAnswer: correct,
      points: 10,
      order: id,
    );

void main() {
  List<QuestionModel> qs() => [_q(1, 'A'), _q(2, 'B'), _q(3, 'A')];

  test('classique : la sélection avance après le délai de révélation', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.classic,
          questions: qs(),
          secondsPerQuestion: 10,
          revealDelayMs: 500);
      expect(c.phase, GamePhase.playing);
      expect(c.index, 0);
      c.selectAnswer('A');
      expect(c.answered, isTrue);
      expect(c.index, 0, reason: 'pas encore avancé avant le délai');
      async.elapse(const Duration(milliseconds: 500));
      expect(c.index, 1);
      expect(c.answered, isFalse);
      c.dispose();
    });
  });

  test('classique : timeout enregistre le temps plein puis avance', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.classic,
          questions: qs(),
          secondsPerQuestion: 3,
          revealDelayMs: 500);
      async.elapse(const Duration(seconds: 3));
      expect(c.answered, isTrue);
      async.elapse(const Duration(milliseconds: 500));
      expect(c.index, 1);
      expect(c.totalTime, greaterThanOrEqualTo(3));
      c.dispose();
    });
  });

  test('classique : la dernière question passe en submitting', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.classic,
          questions: qs(),
          secondsPerQuestion: 10,
          revealDelayMs: 100);
      for (var i = 0; i < 3; i++) {
        c.selectAnswer('A');
        async.elapse(const Duration(milliseconds: 100));
      }
      expect(c.phase, GamePhase.submitting);
      expect(c.playedQuestions.length, 3);
      c.dispose();
    });
  });

  test('classique : skip avance sans enregistrer de réponse', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.classic,
          questions: qs(),
          secondsPerQuestion: 10,
          revealDelayMs: 100);
      c.skip();
      async.elapse(const Duration(milliseconds: 100));
      expect(c.index, 1);
      expect(c.answers.isEmpty, isTrue);
      c.dispose();
    });
  });

  test('survie : mauvaise réponse déclenche game over', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.survival,
          questions: qs(),
          secondsPerQuestion: 10,
          revealDelayMs: 300);
      c.selectAnswer('B'); // Q1 correcte = A
      async.elapse(const Duration(milliseconds: 300));
      expect(c.phase, GamePhase.gameOver);
      expect(c.survivedCount, 0);
      expect(c.playedQuestions.length, 1);
      c.dispose();
    });
  });

  test('survie : bonnes réponses jusqu\'au bout → submitting', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.survival,
          questions: qs(),
          secondsPerQuestion: 10,
          revealDelayMs: 100);
      c.selectAnswer('A');
      async.elapse(const Duration(milliseconds: 100));
      expect(c.index, 1);
      c.selectAnswer('B');
      async.elapse(const Duration(milliseconds: 100));
      expect(c.index, 2);
      c.selectAnswer('A');
      async.elapse(const Duration(milliseconds: 100));
      expect(c.phase, GamePhase.submitting);
      expect(c.playedQuestions.length, 3);
      c.dispose();
    });
  });

  test('survie : le timeout compte comme une mort', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.survival,
          questions: qs(),
          secondsPerQuestion: 4,
          revealDelayMs: 200);
      async.elapse(const Duration(seconds: 4));
      async.elapse(const Duration(milliseconds: 200));
      expect(c.phase, GamePhase.gameOver);
      c.dispose();
    });
  });

  test('speed : timeout à 5s avance à la question suivante', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.speed,
          questions: qs(),
          secondsPerQuestion: 5,
          revealDelayMs: 200);
      async.elapse(const Duration(seconds: 5));
      async.elapse(const Duration(milliseconds: 200));
      expect(c.index, 1);
      c.dispose();
    });
  });

  test('progress et timePercent', () {
    fakeAsync((async) {
      final c = GamePlayController(
          mode: GameMode.classic, questions: qs(), secondsPerQuestion: 10);
      expect(c.progress, closeTo(1 / 3, 0.001));
      expect(c.timePercent, closeTo(1.0, 0.001));
      c.dispose();
    });
  });
}
