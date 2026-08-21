import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/widgets.dart';

/// Libellé localisé du statut d'un défi.
///
/// L'API renvoie un code technique (`open` / `completed` / `expired`). La carte
/// de défi affichait « Ouvert » écrit en dur pour l'un, et le code brut pour
/// les deux autres : un badge « open » apparaissait donc tel quel à l'écran,
/// dans les quatre langues.
class ChallengeStatusL10n {
  const ChallengeStatusL10n._();

  static String label(BuildContext context, ChallengeModel challenge) {
    final l10n = AppLocalizations.of(context);

    // Un défi encore marqué « open » côté serveur mais dont la date est passée
    // est expiré pour le joueur : c'est ce qu'il doit lire.
    if (challenge.isExpired) return l10n.challengeExpired;

    return switch (challenge.status) {
      'open' => l10n.challengeOpen,
      'completed' => l10n.challengeClosed,
      'expired' => l10n.challengeExpired,
      _ => l10n.challengeClosed,
    };
  }
}
