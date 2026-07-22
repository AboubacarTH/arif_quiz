import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/widgets.dart';

/// Libellés « vrai / faux » dans la langue de l'interface.
/// L'interprétation d'une réponse (toutes langues) vit dans [TrueFalse].
class TrueFalseL10n {
  const TrueFalseL10n._();

  /// Les deux choix dans la langue courante, dans l'ordre [vrai, faux].
  static List<String> options(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [l10n.answerTrue, l10n.answerFalse];
  }
}

extension QuestionChoices on QuestionModel {
  /// Choix à afficher : ceux servis par l'API (déjà localisés) ou — pour une
  /// question vrai/faux sans options — les libellés de la langue courante,
  /// plutôt qu'un « True/False » anglais figé.
  List<String> choices(BuildContext context) {
    final served = options;
    if (served != null && served.isNotEmpty) return served;
    return TrueFalseL10n.options(context);
  }
}
