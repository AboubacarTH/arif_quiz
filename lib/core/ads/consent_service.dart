import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Recueil du consentement publicitaire (SDK UMP de Google).
///
/// Obligatoire dans l'EEE, au Royaume-Uni et dans les États américains
/// régulés : sans base légale, AdMob ne sert rien et le compte est en
/// infraction. Le SDK décide seul si un formulaire doit s'afficher — ailleurs
/// dans le monde, ce code ne fait que constater que tout est déjà permis.
///
/// Le message lui-même se configure dans AdMob → Confidentialité et messages ;
/// l'app ne fait que le déclencher et respecter la réponse.
class ConsentService {
  /// Pour tester le formulaire européen depuis un pays non concerné :
  /// renseigner l'identifiant de l'appareil (visible dans les logs AdMob au
  /// premier lancement, ligne « Use ConsentDebugSettings.Builder().addTestDeviceHashedId »).
  /// À laisser vide en production — ces réglages n'ont d'effet qu'en debug.
  static const List<String> debugTestDeviceIds = [];

  bool _resolved = false;
  bool _canRequestAds = false;

  /// Dernier verdict connu : `true` si l'app a le droit de demander des pubs.
  bool get canRequestAds => _canRequestAds;

  /// Vrai une fois le SDK interrogé. Distinguer « pas encore résolu » de
  /// « refusé » évite d'ouvrir le jeu en accès libre pendant la seconde de
  /// démarrage, avant que le verdict ne soit connu.
  bool get isResolved => _resolved;

  /// Met à jour le consentement et affiche le formulaire s'il est requis.
  ///
  /// Renvoie `true` si les publicités peuvent être demandées. Un refus, une
  /// panne réseau ou un formulaire indisponible renvoient `false` : l'appelant
  /// ne doit alors **pas** initialiser AdMob.
  Future<bool> ensureConsent() async {
    if (_resolved) return _canRequestAds;

    final params = ConsentRequestParameters(
      consentDebugSettings: kDebugMode && debugTestDeviceIds.isNotEmpty
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: debugTestDeviceIds,
            )
          : null,
    );

    // `requestConsentInfoUpdate` est à callbacks : on le referme sur un Future
    // pour que le démarrage de l'app puisse simplement l'attendre.
    final updated = await _requestUpdate(params);

    if (updated) {
      // Ne montre le formulaire que si le SDK le juge nécessaire ; sinon
      // retourne immédiatement. Une erreur ici n'est pas fatale : le statut
      // consenti d'une session précédente reste valable.
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          debugPrint('UMP: formulaire non affiché — ${error.message}');
        }
      });
    }

    // Fait foi dans tous les cas, y compris après un échec de mise à jour :
    // un consentement obtenu lors d'une session précédente est mis en cache.
    _canRequestAds = await _safeCanRequestAds();
    _resolved = true;
    return _canRequestAds;
  }

  Future<bool> _requestUpdate(ConsentRequestParameters params) {
    final completer = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        if (!completer.isCompleted) completer.complete(true);
      },
      (error) {
        debugPrint('UMP: mise à jour du consentement échouée — ${error.message}');
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    return completer.future;
  }

  Future<bool> _safeCanRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      debugPrint('UMP: canRequestAds indisponible — $e');
      return false;
    }
  }

  /// Vrai quand la loi impose un point d'entrée permanent « Confidentialité »
  /// dans l'app (typiquement pour un utilisateur de l'EEE).
  Future<bool> isPrivacyOptionsRequired() async {
    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Rouvre le formulaire pour modifier un choix déjà fait (écran Profil).
  Future<void> showPrivacyOptions() async {
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) {
        debugPrint('UMP: options de confidentialité — ${error.message}');
      }
    });
    _canRequestAds = await _safeCanRequestAds();
  }

  /// Remet le consentement à zéro. Réservé aux tests : permet de revoir le
  /// formulaire sans réinstaller l'app.
  Future<void> reset() async {
    await ConsentInformation.instance.reset();
    _resolved = false;
    _canRequestAds = false;
  }
}
