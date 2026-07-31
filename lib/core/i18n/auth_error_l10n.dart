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
}

class AuthErrorL10n {
  const AuthErrorL10n._();

  static String message(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    return switch (code) {
      AuthErrorCodes.registrationFailed => l10n.registrationFailed,
      AuthErrorCodes.invalidCredentials => l10n.invalidCredentials,
      // Un code inconnu ne doit jamais fuir en anglais dans l'UI.
      _ => l10n.invalidCredentials,
    };
  }
}
