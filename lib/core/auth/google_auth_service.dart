import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Pourquoi une tentative de connexion Google n'a pas abouti.
///
/// L'écran ne montre pas la même chose selon les cas : une annulation est un
/// choix de l'utilisateur et ne mérite aucun message, une configuration
/// manquante est un bug de notre côté.
enum GoogleAuthFailure {
  /// L'utilisateur a fermé le sélecteur de compte. Silence.
  cancelled,

  /// Ni Google Play Services ni Credential Manager exploitables sur cet
  /// appareil.
  unavailable,

  /// Identifiants OAuth absents ou empreinte SHA-1 non déclarée : rien de ce
  /// que l'utilisateur peut faire n'y changera quelque chose.
  misconfigured,

  /// Le reste — réseau, interruption, erreur inattendue.
  failed,
}

class GoogleAuthException implements Exception {
  final GoogleAuthFailure reason;
  final String? details;

  const GoogleAuthException(this.reason, [this.details]);

  @override
  String toString() => 'GoogleAuthException($reason)${details == null ? '' : ': $details'}';
}

/// Obtention d'un ID token Google pour l'authentification maison.
///
/// L'app ne se sert de Google que pour faire prouver son identité à
/// l'utilisateur : le jeton obtenu ici part vers `/auth/google`, qui le vérifie
/// et ouvre une vraie session applicative. Aucune donnée Google n'est
/// consultée, aucun scope n'est demandé au-delà de l'identité.
class GoogleAuthService {
  /// Identifiant client **Web** servant d'audience à l'ID token.
  ///
  /// Vide par défaut : le plugin Android le lit alors tout seul dans
  /// `google-services.json` (entrée `oauth_client` de `client_type: 3`), ce qui
  /// évite d'avoir la même valeur à deux endroits. Le `--dart-define` n'est là
  /// que pour les cas où ce fichier ne le contient pas.
  ///
  ///   flutter build apk --dart-define=GOOGLE_SERVER_CLIENT_ID=...
  static const String _serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  Future<void>? _initialization;

  /// Plateformes où un bouton « Continuer avec Google » a du sens.
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// `initialize()` ne doit être appelé qu'une fois, et tout le reste doit
  /// l'attendre — d'où ce Future mémorisé plutôt qu'un appel au démarrage de
  /// l'app : inutile de payer ce coût pour quelqu'un qui se connecte par
  /// mot de passe.
  Future<void> _ensureInitialized() {
    return _initialization ??= GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
  }

  /// Ouvre le sélecteur de compte Google et renvoie l'ID token à transmettre
  /// au backend.
  ///
  /// Lève [GoogleAuthException] dans tous les cas où l'utilisateur ne finit
  /// pas connecté, l'annulation comprise.
  Future<String> obtainIdToken() async {
    if (!isSupported) {
      throw const GoogleAuthException(GoogleAuthFailure.unavailable);
    }

    try {
      await _ensureInitialized();

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      // Un compte sans ID token signifie presque toujours qu'aucun client Web
      // n'est déclaré : Google a bien identifié la personne, mais n'a rien
      // signé que notre serveur puisse vérifier.
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          GoogleAuthFailure.misconfigured,
          'Google returned no ID token (missing web OAuth client?)',
        );
      }

      return idToken;
    } on GoogleSignInException catch (e) {
      // L'initialisation a pu échouer : la relancer au prochain essai plutôt
      // que de resservir éternellement un Future en erreur.
      _initialization = null;
      throw GoogleAuthException(_reasonFor(e.code), e.description);
    } on GoogleAuthException {
      rethrow;
    } catch (e) {
      _initialization = null;
      throw GoogleAuthException(GoogleAuthFailure.failed, e.toString());
    }
  }

  GoogleAuthFailure _reasonFor(GoogleSignInExceptionCode code) {
    return switch (code) {
      GoogleSignInExceptionCode.canceled => GoogleAuthFailure.cancelled,
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        GoogleAuthFailure.misconfigured,
      GoogleSignInExceptionCode.uiUnavailable => GoogleAuthFailure.unavailable,
      _ => GoogleAuthFailure.failed,
    };
  }

  /// Oublie le compte côté Google.
  ///
  /// Sans cela, la déconnexion de l'app laisserait Google reconnecter
  /// silencieusement le même compte au clic suivant — l'utilisateur ne
  /// pourrait jamais en changer.
  Future<void> signOut() async {
    if (!isSupported || _initialization == null) return;

    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // Se déconnecter de l'app doit aboutir quoi qu'il arrive côté Google.
      debugPrint('Google sign-out ignoré : $e');
    }
  }
}
