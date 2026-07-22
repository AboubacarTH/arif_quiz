import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/features/journey/bloc/journey_controller.dart';
import 'package:arif_quiz/features/journey/data/journey_repository.dart';
import 'package:arif_quiz/features/journey/presentation/screens/journey_map_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

JourneyLevelModel _level(int n, {bool unlocked = false, int stars = 0}) =>
    JourneyLevelModel(
      id: 100 + n,
      level: n,
      title: 'Palier $n',
      difficulty: 'easy',
      questionCount: 5,
      isBoss: n % 5 == 0,
      unlocked: unlocked,
      stars: stars,
      bestScore: 0,
    );

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  group('JourneyLevelModel', () {
    test('lit id, titre et rang affiché séparément', () {
      final level = JourneyLevelModel.fromJson(const {
        'id': 42,
        'level': 3,
        'title': 'Les débuts',
        'difficulty': 'medium',
        'question_count': 7,
        'is_boss': true,
        'unlocked': true,
        'stars': 2,
        'best_score': 81.5,
      });

      // L'identifiant sert l'API, le rang sert l'affichage : ne pas confondre.
      expect(level.id, 42);
      expect(level.level, 3);
      expect(level.title, 'Les débuts');
      expect(level.isBoss, isTrue);
      expect(level.completed, isTrue);
    });

    test('un titre vide vaut absence de titre', () {
      final level = JourneyLevelModel.fromJson(const {'id': 1, 'title': '   '});
      expect(level.title, isNull);
    });
  });

  group('Map du parcours', () {
    testWidgets('le niveau 1 est en bas et la progression monte',
        (tester) async {
      final ctrl = JourneyController(JourneyRepository(ApiService()));
      ctrl.seed(JourneyMapModel(
        currentLevel: 2,
        levelCount: 4,
        // Tous débloqués : un palier verrouillé affiche un cadenas, pas son
        // numéro — on ne pourrait pas mesurer sa position.
        levels: [
          _level(1, unlocked: true, stars: 3),
          _level(2, unlocked: true, stars: 2),
          _level(3, unlocked: true, stars: 1),
          _level(4, unlocked: true),
        ],
      ));

      await tester.pumpWidget(_wrap(JourneyMapScreen(controller: ctrl)));
      await tester.pump();

      final y = <int, double>{};
      for (var n = 1; n <= 4; n++) {
        y[n] = tester.getCenter(find.text('$n')).dy;
      }

      // Ascension : chaque palier est strictement plus haut que le précédent.
      expect(y[1]! > y[2]!, isTrue, reason: 'le niveau 2 doit être au-dessus du 1');
      expect(y[2]! > y[3]!, isTrue, reason: 'le niveau 3 doit être au-dessus du 2');
      expect(y[3]! > y[4]!, isTrue, reason: 'le niveau 4 doit être au-dessus du 3');

      // La map anime en boucle (halo, énergie du sentier) : on démonte l'arbre
      // pour libérer les timers avant la fin du test.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('affiche le titre saisi par l\'admin sur les paliers ouverts',
        (tester) async {
      final ctrl = JourneyController(JourneyRepository(ApiService()));
      ctrl.seed(JourneyMapModel(
        currentLevel: 2,
        levelCount: 2,
        levels: [_level(1, unlocked: true, stars: 3), _level(2, unlocked: true)],
      ));

      await tester.pumpWidget(_wrap(JourneyMapScreen(controller: ctrl)));
      await tester.pump();

      // Le palier terminé porte son titre ; le palier courant affiche « JOUER ».
      expect(find.text('Palier 1'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
