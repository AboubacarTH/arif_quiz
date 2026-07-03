import 'package:arif_quiz/shared/models/models.dart';
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
  group('gradeForScore', () {
    test('barème par palier', () {
      expect(gradeForScore(100), 'S');
      expect(gradeForScore(90), 'S');
      expect(gradeForScore(89.9), 'A');
      expect(gradeForScore(80), 'A');
      expect(gradeForScore(70), 'B');
      expect(gradeForScore(60), 'C');
      expect(gradeForScore(50), 'D');
      expect(gradeForScore(49.9), 'F');
      expect(gradeForScore(0), 'F');
    });
  });

  group('QuizAttemptResult.fromLocalScoring', () {
    test('score, comptage et note', () {
      final questions = [_q(1, 'A'), _q(2, 'B'), _q(3, 'A'), _q(4, 'B')];
      final answers = {'1': 'A', '2': 'B', '3': 'A', '4': 'X'}; // 3/4
      final r = QuizAttemptResult.fromLocalScoring(
          questions: questions, answers: answers, timeTaken: 42);
      expect(r.correctCount, 3);
      expect(r.totalQuestions, 4);
      expect(r.score, 75);
      expect(r.grade, 'B');
      expect(r.timeTaken, 42);
      expect(r.results.length, 4);
      expect(r.results.firstWhere((e) => e.questionId == 4).isCorrect, false);
    });

    test('comparaison insensible à la casse et aux espaces', () {
      final r = QuizAttemptResult.fromLocalScoring(
          questions: [_q(1, 'Paris')],
          answers: {'1': '  paris '},
          timeTaken: 0);
      expect(r.correctCount, 1);
      expect(r.score, 100);
      expect(r.grade, 'S');
    });

    test('réponse manquante comptée fausse', () {
      final r = QuizAttemptResult.fromLocalScoring(
          questions: [_q(1, 'A'), _q(2, 'B')],
          answers: {'1': 'A'},
          timeTaken: 0);
      expect(r.correctCount, 1);
      expect(r.score, 50);
      expect(r.grade, 'D');
    });

    test('liste vide → score 0, note F', () {
      final r = QuizAttemptResult.fromLocalScoring(
          questions: [], answers: {}, timeTaken: 0);
      expect(r.score, 0);
      expect(r.totalQuestions, 0);
      expect(r.grade, 'F');
    });
  });
}
