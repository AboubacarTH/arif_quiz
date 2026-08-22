import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/widgets.dart';

/// Libellés localisés des modes de jeu (l'enum ne peut pas porter de context).
extension GameModeL10n on GameMode {
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      GameMode.classic => l10n.modeClassicShort,
      GameMode.survival => l10n.modeSurvivalShort,
      GameMode.speed => l10n.modeSpeedShort,
      GameMode.precision => l10n.modePrecisionShort,
      GameMode.streak => l10n.modeStreakShort,
      GameMode.timeattack => l10n.modeTimeAttackShort,
      GameMode.jokers => l10n.modeJokersShort,
    };
  }

  String localizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      GameMode.classic => l10n.modeClassicDesc,
      GameMode.survival => l10n.modeSurvivalDesc,
      GameMode.speed => l10n.modeSpeedDesc,
      GameMode.precision => l10n.modePrecisionDesc,
      GameMode.streak => l10n.modeStreakDesc,
      GameMode.timeattack => l10n.modeTimeAttackDesc,
      GameMode.jokers => l10n.modeJokersDesc,
    };
  }
}
