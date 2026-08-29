import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/core/auth/google_auth_service.dart';
import 'package:arif_quiz/core/i18n/auth_error_l10n.dart';
import 'package:arif_quiz/features/auth/bloc/auth_controller.dart';
import 'package:arif_quiz/features/auth/data/auth_repository.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Connexion Google, côté application.
///
/// Ce qui compte ici n'est pas le dialogue avec Google — il est natif et hors
/// de portée d'un test unitaire — mais ce que l'app en fait : une annulation
/// doit rester silencieuse, un échec doit produire un message traduit, et le
/// serveur doit pouvoir dire « ce compte passe par Google » sans que ça
/// ressemble à un mot de passe erroné.

const _user = UserModel(
  id: 1,
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  role: 'user',
  hasPassword: false,
  totalPoints: 0,
  quizzesTaken: 0,
  correctAnswers: 0,
  accuracy: 0,
);

/// Remplace les échanges réseau par un verdict décidé par le test.
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.googleOutcome, this.loginOutcome})
      : super(ApiService());

  final Object? googleOutcome;
  final Object? loginOutcome;

  @override
  Future<({UserModel user, String token})> signInWithGoogle() async {
    if (googleOutcome is Exception) throw googleOutcome as Exception;
    return (user: _user, token: 'jeton-de-test');
  }

  @override
  Future<({UserModel user, String token})> login(
      String email, String password) async {
    if (loginOutcome is Exception) throw loginOutcome as Exception;
    return (user: _user, token: 'jeton-de-test');
  }
}

Widget _app(Widget home, {Locale locale = const Locale('fr')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  group('AuthController.signInWithGoogle', () {
    test('un jeton accepté authentifie l\'utilisateur', () async {
      final auth = AuthController(_FakeAuthRepository());

      expect(await auth.signInWithGoogle(), isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.email, 'ada@example.com');
      expect(auth.errorCode, isNull);
    });

    test('une annulation ne produit aucun message', () async {
      final auth = AuthController(_FakeAuthRepository(
        googleOutcome: const GoogleAuthException(GoogleAuthFailure.cancelled),
      ));

      expect(await auth.signInWithGoogle(), isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorCode, isNull,
          reason: 'Fermer le sélecteur de compte est un choix, pas une erreur.');
    });

    test('une configuration manquante a son propre message', () async {
      final auth = AuthController(_FakeAuthRepository(
        googleOutcome:
            const GoogleAuthException(GoogleAuthFailure.misconfigured),
      ));

      expect(await auth.signInWithGoogle(), isFalse);
      expect(auth.errorCode, AuthErrorCodes.googleMisconfigured);
    });

    test('Google indisponible a son propre message', () async {
      final auth = AuthController(_FakeAuthRepository(
        googleOutcome: const GoogleAuthException(GoogleAuthFailure.unavailable),
      ));

      await auth.signInWithGoogle();
      expect(auth.errorCode, AuthErrorCodes.googleUnavailable);
    });

    test('un échec côté serveur reste un échec de connexion Google', () async {
      final auth = AuthController(
          _FakeAuthRepository(googleOutcome: Exception('500')));

      await auth.signInWithGoogle();
      expect(auth.errorCode, AuthErrorCodes.googleSignInFailed);
    });
  });

  group('Connexion par mot de passe sur un compte Google', () {
    test('oriente vers Google au lieu de parler d\'identifiants', () async {
      final auth = AuthController(
          _FakeAuthRepository(loginOutcome: const GoogleAccountException()));

      expect(await auth.login('ada@example.com', 'peu importe'), isFalse);
      expect(auth.errorCode, AuthErrorCodes.useGoogleToSignIn);
    });

    test('un vrai mauvais mot de passe garde son message', () async {
      final auth =
          AuthController(_FakeAuthRepository(loginOutcome: Exception('401')));

      await auth.login('ada@example.com', 'mauvais');
      expect(auth.errorCode, AuthErrorCodes.invalidCredentials);
    });
  });

  group('UserModel.hasPassword', () {
    test('absent de la réponse → compte classique', () {
      final user = UserModel.fromJson({'id': 1, 'name': 'Ada', 'role': 'user'});
      expect(user.hasPassword, isTrue);
    });

    test('faux quand le serveur le dit', () {
      final user = UserModel.fromJson(
          {'id': 1, 'name': 'Ada', 'role': 'user', 'has_password': false});
      expect(user.hasPassword, isFalse);
    });
  });

  group('Messages traduits', () {
    const codes = [
      AuthErrorCodes.googleSignInFailed,
      AuthErrorCodes.googleUnavailable,
      AuthErrorCodes.googleMisconfigured,
      AuthErrorCodes.useGoogleToSignIn,
    ];

    for (final locale in ['fr', 'en', 'es', 'ar']) {
      testWidgets('aucun code technique ne fuit en $locale', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(_app(
          Builder(builder: (c) {
            ctx = c;
            return const SizedBox();
          }),
          locale: Locale(locale),
        ));

        for (final code in codes) {
          final message = AuthErrorL10n.message(ctx, code);
          expect(message, isNotEmpty);
          expect(message, isNot(contains('_')),
              reason: '$code ressort tel quel en $locale');
          // Le message générique est le repli des codes inconnus : le voir ici
          // signifierait qu'un code Google n'a pas sa propre traduction.
          expect(message, isNot(AppLocalizations.of(ctx).invalidCredentials));
        }
      });
    }
  });
}
