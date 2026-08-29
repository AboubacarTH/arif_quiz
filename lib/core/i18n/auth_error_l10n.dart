import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Codes d'erreur d'authentification.
///
/// Le contrôleur n'a pas de `BuildContext` : il émet un code stable, et l'écran
/// le traduit au build. Auparavant il émettait la phrase anglaise directement,
/// qui s'affichait telle quelle quelle que soit la langue choisie.
abstract final class AuthErrorCodes {
  static const invalidCredentials = 'invalid_credentials';
  static const registrationFailed = 'registration_failed';
  static const googleSignInFailed = 'google_sign_in_failed';
  static const googleUnavailable = 'google_unavailable';
  static const googleMisconfigured = 'google_misconfigured';
  static const useGoogleToSignIn = 'use_google_to_sign_in';
}

class AuthErrorL10n {
  const AuthErrorL10n._();

  static String message(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    return switch (code) {
      AuthErrorCodes.registrationFailed => l10n.registrationFailed,
      AuthErrorCodes.invalidCredentials => l10n.invalidCredentials,
      AuthErrorCodes.googleSignInFailed => l10n.googleSignInFailed,
      AuthErrorCodes.googleUnavailable => l10n.googleUnavailable,
      AuthErrorCodes.googleMisconfigured => l10n.googleMisconfigured,
      AuthErrorCodes.useGoogleToSignIn => l10n.useGoogleToSignIn,
      // Un code inconnu ne doit jamais fuir en anglais dans l'UI.
      _ => l10n.invalidCredentials,
    };
  }
}
