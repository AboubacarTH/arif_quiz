import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Libellé localisé d'une difficulté.
///
/// L'API renvoie un code technique (`easy` / `medium` / `hard`) : l'afficher
/// tel quel — souvent en `toUpperCase()` — figeait « EASY » sur les badges,
/// quelle que soit la langue de l'interface.
class DifficultyL10n {
  const DifficultyL10n._();

  static String label(BuildContext context, String difficulty) {
    final l10n = AppLocalizations.of(context);
    return switch (difficulty) {
      'easy' => l10n.diffEasy,
      'hard' => l10n.diffHard,
      _ => l10n.diffMedium,
    };
  }

  /// Variante capitales pour les badges compacts. `toUpperCase()` est sans
  /// effet en arabe, qui n'a pas de casse : le libellé reste correct.
  static String badge(BuildContext context, String difficulty) =>
      label(context, difficulty).toUpperCase();
}
