import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

QuestionModel _trueFalse(String correct) => QuestionModel(
      id: 1,
      text: 'Le ciel est bleu.',
      type: 'true_false',
      options: const ['Vrai', 'Faux'],
      correctAnswer: correct,
      points: 10,
      order: 1,
    );

void main() {
  group('TrueFalse.parse', () {
    test('reconnaît les libellés de toutes les langues supportées', () {
      for (final v in ['True', 'Vrai', 'صح', 'Verdadero', 'oui', 'YES', '1']) {
        expect(TrueFalse.parse(v), isTrue, reason: '« $v » devrait valoir vrai');
      }
      for (final v in ['False', 'faux', 'خطأ', 'FALSO', 'non', 'no', '0']) {
        expect(TrueFalse.parse(v), isFalse, reason: '« $v » devrait valoir faux');
      }
    });

    test('renvoie null hors vrai/faux', () {
      expect(TrueFalse.parse('peut-être'), isNull);
      expect(TrueFalse.parse(''), isNull);
      expect(TrueFalse.parse(null), isNull);
    });
  });

  group('QuestionModel.isCorrect (vrai/faux)', () {
    test('accepte la bonne réponse quelle que soit sa langue', () {
      final q = _trueFalse('Vrai');
      // Le serveur peut avoir servi « Vrai » et le client renvoyer « True »
      // (données en cache, langue changée en cours de partie) : même réponse.
      expect(q.isCorrect('Vrai'), isTrue);
      expect(q.isCorrect('True'), isTrue);
      expect(q.isCorrect(' verdadero '), isTrue);
      expect(q.isCorrect('صح'), isTrue);
    });

    test('rejette la valeur opposée et les valeurs inconnues', () {
      final q = _trueFalse('Vrai');
      expect(q.isCorrect('Faux'), isFalse);
      expect(q.isCorrect('False'), isFalse);
      expect(q.isCorrect('peut-être'), isFalse);
      expect(q.isCorrect(null), isFalse);
    });

    test('les autres types gardent la comparaison littérale', () {
      const q = QuestionModel(
        id: 2,
        text: 'Capitale de la France ?',
        type: 'short_answer',
        correctAnswer: 'Paris',
        points: 10,
        order: 2,
      );
      expect(q.isCorrect(' paris '), isTrue);
      expect(q.isCorrect('Lyon'), isFalse);
    });
  });
}
