import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les colonnes `decimal` de MySQL ressortent en CHAÎNE dans le JSON de Laravel
/// tant qu'aucun cast ne les convertit. En développement, SQLite renvoie un
/// nombre : le bug était donc invisible sous les tests et ne se déclenchait
/// qu'en production, et seulement une fois qu'un score existait.
///
/// Concrètement : dès que le joueur avait joué le défi du jour, l'accueil
/// n'arrivait plus à lire la réponse et masquait la carte.
void main() {
  group('asDouble', () {
    test('accepte un nombre, une chaine decimale, et rien', () {
      expect(asDouble(100), 100.0);
      expect(asDouble(87.5), 87.5);
      expect(asDouble('100.00'), 100.0);
      expect(asDouble('87.5'), 87.5);
      expect(asDouble(null), isNull);
    });

    test('ne jette pas sur une valeur inattendue', () {
      expect(asDouble('pas un nombre'), isNull);
      expect(asDouble(true), isNull);
      expect(asDouble(<String>[]), isNull);
    });
  });

  group('Defi du jour', () {
    Map<String, dynamic> payload(Object? myScore) => {
          'id': 7,
          'challenge_date': '2026-08-21',
          'already_played': myScore != null,
          'my_score': myScore,
          'my_grade': myScore == null ? null : 'S',
          'seconds_until_reset': 3600,
          'quiz': {
            'id': 3,
            'title': 'Informatique & Internet',
            'difficulty': 'medium',
            'time_limit': 30,
          },
        };

    test('un score renvoye en chaine ne fait plus echouer la lecture', () {
      final model = DailyChallengeModel.fromJson(payload('100.00'));

      expect(model.myScore, 100.0);
      expect(model.alreadyPlayed, isTrue);
      expect(model.quiz.title, 'Informatique & Internet');
    });

    test('un score renvoye en nombre reste lu correctement', () {
      expect(DailyChallengeModel.fromJson(payload(87.5)).myScore, 87.5);
    });

    test('pas encore joue : aucun score, et rien ne casse', () {
      final model = DailyChallengeModel.fromJson(payload(null));

      expect(model.myScore, isNull);
      expect(model.alreadyPlayed, isFalse);
    });
  });

  group('Tentative de quiz', () {
    test('le score d une tentative accepte les deux formes', () {
      Map<String, dynamic> attempt(Object? score) => {
            'id': 1,
            'score': score,
            'correct_count': 9,
            'total_questions': 10,
            'points_earned': 90,
            'time_taken': 42,
            'grade': 'A',
          };

      expect(QuizAttemptResult.fromJson(attempt('90.00')).score, 90.0);
      expect(QuizAttemptResult.fromJson(attempt(90)).score, 90.0);
    });
  });
}
