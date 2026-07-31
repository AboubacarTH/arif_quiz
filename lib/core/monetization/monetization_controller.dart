import 'dart:async';

import 'package:arif_quiz/core/ads/ads_service.dart';
import 'package:arif_quiz/core/monetization/play_credits.dart';
import 'package:arif_quiz/core/subscriptions/subscription_service.dart';
import 'package:flutter/foundation.dart';

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

  int get credits => _credits.credits;
  int get creditsPerAd => PlayCreditsService.perAd;

  Future<void> initialize() async {
    if (!adsEnabled) return; // ne charge ni AdMob ni le Play Billing
    await Future.wait([
      _ads.initialize(),
      _subs.initialize(),
      _credits.load(),
    ]);
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
          await _credits.grantAdReward();
          // La partie qui suit la pub fait partie du lot.
          await _credits.consumeOne();
          notifyListeners();
          onGranted();
          finish();
        },
        onFailed: () {
          notifyListeners();
          onNoAd();
          finish();
        },
      );
    } catch (_) {
      // Échec d'affichage : ne jamais laisser l'appelant suspendu.
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

    await _credits.load();
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    try {
      await _ads.showRewardedAd(
        onRewarded: () async {
          await _credits.grantAdReward();
          notifyListeners();
          onRewarded();
          finish();
        },
        onFailed: () {
          notifyListeners();
          onFailed();
          finish();
        },
      );
    } catch (_) {
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
}
