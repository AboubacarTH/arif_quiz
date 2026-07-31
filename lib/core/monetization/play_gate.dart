import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/ui/widgets/paywall_sheet.dart';
import 'package:flutter/widgets.dart';

/// Portail unique devant **toute** partie : quiz classique, survie, speed,
/// entraînement et niveaux du mode parcours.
///
/// Centralisé pour une raison concrète : chaque écran qui pousse un écran de
/// jeu sans passer par ici rouvre une porte dérobée vers du contenu gratuit.
/// Un seul appel à faire côté écran :
///
/// ```dart
/// PlayGate.requestPlay(context, onGranted: _launch);
/// ```
class PlayGate {
  const PlayGate._();

  static Future<void> requestPlay(
    BuildContext context, {
    required VoidCallback onGranted,
  }) async {
    await monetizationController.requestPlay(
      onGranted: onGranted,
      onNoAd: () {
        if (!context.mounted) return;
        PaywallSheet.show(
          context,
          ctrl: monetizationController,
          onGranted: onGranted,
        );
      },
    );
  }
}
