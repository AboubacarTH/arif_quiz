import 'dart:io' show Platform;

import 'package:arif_quiz/core/ads/consent_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Identifiants AdMob.
/// L'App ID est lu depuis AndroidManifest.xml par le SDK.
/// Seul l'Ad Unit ID de la pub récompensée doit être configuré ici.
class _AdIds {
  // ── Production ────────────────────────────────────────────────────────────
  static const _androidRewardedId = 'ca-app-pub-2368108228720906/4975522909';

  // ── Test Google (debug uniquement) ────────────────────────────────────────
  static const _testAndroidRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // dart.vm.product == true en release, false en debug/profile
  static bool get _isTest =>
      const bool.fromEnvironment('dart.vm.product') == false;

  static String get rewardedId =>
      _isTest ? _testAndroidRewardedId : _androidRewardedId;
}

class AdsService {
  static final AdsService _instance = AdsService._();
  factory AdsService() => _instance;
  AdsService._();

  final ConsentService _consent = ConsentService();

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;

  /// Seul Android est configuré (App ID dans `AndroidManifest.xml`, unité
  /// récompensée ci-dessus). Sur iOS, initialiser le SDK sans
  /// `GADApplicationIdentifier` dans `Info.plist` fait planter l'app au
  /// démarrage : tant que la config iOS n'existe pas, on n'y touche pas.
  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Faux tant que le consentement n'est pas acquis (ou s'il a été refusé) :
  /// aucune publicité ne pourra alors être servie sur cet appareil.
  bool get canServeAds => isSupported && _consent.canRequestAds;

  /// Verdict **définitif** de refus : l'utilisateur a répondu, et la réponse
  /// interdit toute publicité. Tant que le consentement n'est pas résolu, on
  /// ne le suppose pas — c'est ce qui distingue « pas encore » de « jamais ».
  bool get adsBlocked =>
      isSupported && _consent.isResolved && !_consent.canRequestAds;

  ConsentService get consent => _consent;

  bool get isAdReady => _rewardedAd != null;

  Future<void> initialize() async {
    if (_initialized || !isSupported) return;

    // Le consentement passe avant tout : initialiser AdMob sans base légale
    // est précisément ce que la politique européenne interdit.
    final allowed = await _consent.ensureConsent();
    if (!allowed) return;

    await MobileAds.instance.initialize();
    _initialized = true;
    loadRewardedAd();
  }

  Future<void> loadRewardedAd() async {
    if (_isLoadingAd || _rewardedAd != null || !canServeAds) return;
    _isLoadingAd = true;

    await RewardedAd.load(
      adUnitId: _AdIds.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
          _isLoadingAd = false;
        },
      ),
    );
  }

  /// Affiche la pub récompensée.
  ///
  /// [onRewarded] — appelé une fois la pub **fermée**, si l'utilisateur l'a
  ///                regardée jusqu'au bout. Attendre la fermeture évite de
  ///                pousser un écran de jeu sous une pub plein écran.
  /// [onFailed]   — appelé si la pub est indisponible, échoue, ou est fermée
  ///                sans avoir été regardée entièrement.
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) {
        onFailed();
        return;
      }
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;

    // Indique si la récompense a bien été accordée avant la fermeture
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        loadRewardedAd(); // pré-charge la suivante
        if (rewarded) {
          onRewarded();
        } else {
          // Fermée avant la fin → aucune récompense.
          onFailed();
        }
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        loadRewardedAd();
        onFailed();
      },
    );

    await ad.show(onUserEarnedReward: (_, __) => rewarded = true);
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
