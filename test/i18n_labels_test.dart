import 'package:arif_quiz/core/i18n/auth_error_l10n.dart';
import 'package:arif_quiz/core/i18n/difficulty_l10n.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/ui/widgets/quiz_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'API renvoie des codes techniques (`easy`, `invalid_credentials`…) : ces
/// tests garantissent qu'aucun ne fuit tel quel dans l'interface.

Widget _app(Widget home, {Locale locale = const Locale('fr')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

QuizModel _quiz({String difficulty = 'easy'}) => QuizModel.fromJson({
      'id': 1,
      'title': 'Capitales du monde',
      'difficulty': difficulty,
      'time_limit': 30,
      'play_count': 12,
    });

void main() {
  group('Libellés de difficulté', () {
    for (final (locale, easy, hard) in const [
      ('fr', 'Facile', 'Difficile'),
      ('en', 'Easy', 'Hard'),
      ('es', 'Fácil', 'Difícil'),
    ]) {
      testWidgets('traduits en $locale', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(_app(
          Builder(builder: (c) {
            ctx = c;
            return const SizedBox();
          }),
          locale: Locale(locale),
        ));
        expect(DifficultyL10n.label(ctx, 'easy'), easy);
        expect(DifficultyL10n.label(ctx, 'hard'), hard);
        expect(DifficultyL10n.badge(ctx, 'easy'), easy.toUpperCase());
      });
    }

    testWidgets('une valeur inconnue retombe sur « moyen », jamais sur le code',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_app(Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));
      expect(DifficultyL10n.label(ctx, 'inconnu'), 'Moyen');
    });
  });

  testWidgets('le badge d\'une carte quiz suit la langue', (tester) async {
    await tester.pumpWidget(_app(
      Scaffold(body: QuizCard(quiz: _quiz(), onTap: () {})),
    ));
    expect(find.text('FACILE'), findsOneWidget);
    expect(find.text('EASY'), findsNothing);

    await tester.pumpWidget(_app(
      Scaffold(body: QuizCard(quiz: _quiz(difficulty: 'hard'), onTap: () {})),
      locale: const Locale('ar'),
    ));
    expect(find.text('صعب'), findsOneWidget);
  });

  testWidgets('les erreurs d\'authentification sont traduites', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    expect(AuthErrorL10n.message(ctx, AuthErrorCodes.invalidCredentials),
        contains('mot de passe'));
    expect(AuthErrorL10n.message(ctx, AuthErrorCodes.registrationFailed),
        contains('Inscription'));
    // Un code inattendu ne doit pas s'afficher brut.
    expect(AuthErrorL10n.message(ctx, 'boom'), isNot(contains('boom')));
  });

  group('Flèche retour de l\'écran Quiz', () {
    testWidgets('absente en onglet : rien à dépiler', (tester) async {
      await tester.pumpWidget(_app(const QuizListScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
      // Laisse expirer les timeouts réseau (15 s) déclenchés au initState,
      // sinon le binding signale un timer encore en vol à la fin du test.
      await tester.pump(const Duration(seconds: 20));
    });

    testWidgets('présente et fonctionnelle quand l\'écran est poussé',
        (tester) async {
      await tester.pumpWidget(_app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizListScreen()),
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('ouvrir'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('ouvrir'), findsOneWidget);
    });
  });
}
