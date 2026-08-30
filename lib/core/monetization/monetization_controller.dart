import 'dart:async';

import 'package:arif_quiz/core/ads/ads_service.dart';
import 'package:arif_quiz/core/monetization/play_credits.dart';
import 'package:arif_quiz/core/subscriptions/subscription_service.dart';
import 'package:flutter/widgets.dart';

/// Contrôleur central : publicités récompensées + crédits de parties + abonnement.
///
/// Règle du jeu, pour un utilisateur **non abonné** :
///   1. s'il lui reste des crédits → la partie en débite un, sans publicité ;
///   2. sinon on lui propose une publicité récompensée : la regarder jusqu'au
///      bout crédite [PlayCreditsService.perAd] parties, dont celle qu'il
///      lance dans la foulée ;
///   3. si aucune publicité n'est disponible → paywall (abonnement).
///
/// Un abonné ne voit jamais ni publicité ni paywall.
class MonetizationController extends ChangeNotifier {
  final AdsService _ads;
  final SubscriptionService _subs;
  final PlayCreditsService _credits;

  /// Une seule demande à la fois : voir [requestPlay].
  bool _requestInFlight = false;

  /// Revérifie l'abonnement au retour dans l'app : voir [initialize].
  AppLifecycleListener? _lifecycle;

  // ═══════════════════════════════════════════════════════════════
  // Coupe-circuit global : passer à false rouvre l'app en accès libre
  // (aucune pub chargée, aucun paywall) — utile en démo ou si AdMob
  // pose problème en production.
  static const bool adsEnabled = true;
  // ═══════════════════════════════════════════════════════════════

  MonetizationController({
    AdsService? ads,
    SubscriptionService? subs,
    PlayCreditsService? credits,
  })  : _ads = ads ?? AdsService(),
        _subs = subs ?? SubscriptionService(),
        _credits = credits ?? PlayCreditsService() {
    // Un achat peut se conclure bien après le tap (paiement différé, restauration
    // au lancement) : l'UI doit se mettre à jour toute seule ce jour-là.
    _subs.onChanged = notifyListeners;
    // Idem pour l'arrivée d'une publicité : le paywall ouvert « en attente »
    // doit afficher le bouton dès qu'elle est prête, sans réouverture.
    _ads.onAvailabilityChanged = notifyListeners;
  }

  bool get isPremium => _subs.isPremium;

  /// Vrai quand une partie doit être « payée » (crédit ou publicité).
  ///
  /// Faux là où aucune publicité ne pourra jamais être servie : plateforme non
  /// configurée, ou consentement refusé. Enfermer derrière un paywall
  /// quelqu'un qui a exercé son droit de refus le priverait du jeu à vie —
  /// mieux vaut le laisser jouer. Passer `_ads.adsBlocked` à `false` ici
  /// rendrait le paywall obligatoire pour ces utilisateurs.
  bool get adsRequired =>
      adsEnabled && _ads.isSupported && !_ads.adsBlocked && !isPremium;

  bool get isAdReady => adsRequired && _ads.isAdReady;

  /// Une publicité est en cours de chargement : l'UI montre un spinner plutôt
  /// qu'un bouton mort.
  bool get isAdLoading => adsRequired && _ads.isAdLoading;

  /// Lance (ou relance) le chargement d'une publicité. Utilisé à l'ouverture du
  /// paywall et par son bouton « Réessayer ».
  Future<void> prepareAd() => _ads.loadRewardedAd();

  int get credits => _credits.credits;
  int get creditsPerAd => PlayCreditsService.perAd;

  Future<void> initialize() async {
    if (!adsEnabled) return; // ne charge ni AdMob ni le Play Billing
    await Future.wait([
      _ads.initialize(),
      _subs.initialize(),
      _credits.load(),
    ]);
    // Une échéance d'abonnement ne réveille pas l'app. Sans cette
    // revérification au retour au premier plan, un abonnement expiré pendant
    // que l'app dormait resterait « actif » jusqu'au prochain lancement à
    // froid — et l'app tourne des jours sans être tuée.
    _lifecycle ??= AppLifecycleListener(onResume: _subs.refreshEntitlement);
    notifyListeners();
  }

  /// Demande l'autorisation de lancer une partie.
  ///
  /// [onGranted] — la partie peut démarrer (accès libre, abonné, crédit débité,
  ///               ou publicité regardée jusqu'au bout puis fermée).
  /// [onNoAd]    — rien à débiter et pas de publicité disponible : l'appelant
  ///               affiche le paywall.
  Future<void> requestPlay({
    required VoidCallback onGranted,
    required VoidCallback onNoAd,
  }) async {
    if (!adsRequired) {
      onGranted();
      return;
    }

    // Un second appel pendant qu'une publicité est à l'écran ne trouverait plus
    // de pub disponible et ouvrirait le paywall PAR-DESSUS la publicité en
    // cours : à sa fermeture, le jeu démarrait sous une feuille modale restée
    // ouverte, écran apparemment gelé qu'il fallait quitter et rouvrir. Un
    // double tap suffisait à provoquer ça.
    if (_requestInFlight) return;
    _requestInFlight = true;

    try {
      await _resolvePlay(onGranted: onGranted, onNoAd: onNoAd);
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> _resolvePlay({
    required VoidCallback onGranted,
    required VoidCallback onNoAd,
  }) async {
    // `initialize()` n'est pas attendu au lancement : sans ce garde-fou, une
    // partie démarrée dans la première seconde verrait un solde à zéro et
    // imposerait une pub à quelqu'un qui avait déjà des crédits.
    await _credits.load();

    if (await _credits.consumeOne()) {
      notifyListeners();
      onGranted();
      return;
    }

    if (!_ads.isAdReady) {
      _ads.loadRewardedAd(); // prépare la suivante pour le prochain essai
      onNoAd();
      return;
    }

    // Les callbacks d'AdMob arrivent après la fermeture de la pub : sans ce
    // Completer, `requestPlay` rendrait la main avant même que le crédit soit
    // débité, et l'appelant croirait la demande résolue.
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    try {
      await _ads.showRewardedAd(
        onRewarded: () async {
          try {
            await _credits.grantAdReward();
            // La partie qui suit la pub fait partie du lot.
            await _credits.consumeOne();
            notifyListeners();
            onGranted();
          } catch (e) {
            // Une erreur du code appelant (navigation sur un écran démonté…)
            // ne doit ni remonter en erreur asynchrone non capturée, ni — c'est
            // ce qui figeait le paywall — empêcher la complétion ci-dessous.
            debugPrint('Monétisation: lancement de la partie échoué — $e');
          } finally {
            finish();
          }
        },
        onFailed: () {
          try {
            notifyListeners();
            onNoAd();
          } catch (e) {
            debugPrint('Monétisation: ouverture du paywall échouée — $e');
          } finally {
            finish();
          }
        },
      );
    } catch (e) {
      debugPrint('Monétisation: publicité non aboutie — $e');
      onNoAd();
      finish();
    }

    await done.future;
  }

  /// Regarde une publicité **hors partie** (depuis le profil) : crédite le lot
  /// sans en consommer, contrairement à [requestPlay] qui débite la partie
  /// lancée dans la foulée.
  Future<void> watchAdForCredits({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    if (!adsRequired || !_ads.isAdReady) {
      _ads.loadRewardedAd();
      onFailed();
      return;
    }

    // Même verrou que [requestPlay] : jamais deux publicités en concurrence.
    if (_requestInFlight) return;
    _requestInFlight = true;

    try {
      await _watchAd(onRewarded: onRewarded, onFailed: onFailed);
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> _watchAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    await _credits.load();
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    try {
      await _ads.showRewardedAd(
        onRewarded: () async {
          try {
            await _credits.grantAdReward();
            notifyListeners();
            onRewarded();
          } catch (e) {
            debugPrint('Monétisation: crédit non répercuté à l\'écran — $e');
          } finally {
            finish();
          }
        },
        onFailed: () {
          try {
            notifyListeners();
            onFailed();
          } catch (e) {
            debugPrint('Monétisation: retour d\'échec non traité — $e');
          } finally {
            finish();
          }
        },
      );
    } catch (e) {
      debugPrint('Monétisation: publicité non aboutie — $e');
      onFailed();
      finish();
    }

    await done.future;
  }

  /// Google exige un point d'entrée permanent dans l'app pour revenir sur son
  /// choix — mais uniquement là où la loi l'impose (EEE, UK, États US régulés).
  Future<bool> isPrivacyOptionsRequired() async {
    if (!adsEnabled || !_ads.isSupported) return false;
    return _ads.consent.isPrivacyOptionsRequired();
  }

  /// Rouvre le formulaire de consentement depuis les réglages.
  Future<void> showPrivacyOptions() async {
    if (!adsEnabled || !_ads.isSupported) return;
    await _ads.consent.showPrivacyOptions();
    // Un consentement retiré coupe les pubs, un consentement donné les rouvre :
    // dans les deux cas l'écran doit se réafficher.
    notifyListeners();
  }

  void refresh() => notifyListeners();

  /// Redemande au serveur l'abonnement du compte connecté. Appelé au retour
  /// dans l'app et à chaque changement d'identité.
  Future<void> refreshSubscription() => _subs.refreshEntitlement();

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }
}
