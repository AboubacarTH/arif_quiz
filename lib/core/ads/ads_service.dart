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

  /// Prévient quand la disponibilité d'une pub change (chargée, consommée,
  /// échec de chargement). Sans ce signal, un écran ouvert alors qu'aucune pub
  /// n'était prête reste figé sur « chargement » même une fois la pub arrivée.
  VoidCallback? onAvailabilityChanged;

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;
  DateTime? _loadStartedAt;

  /// Au-delà de ce délai, une demande de chargement est considérée comme
  /// perdue : sans ce garde-fou, un `_isLoadingAd` resté à `true` (exception
  /// réseau, callback jamais reçu) bloquerait toute publicité **à vie**.
  static const _loadTimeout = Duration(seconds: 60);

  bool get isAdLoading => _isLoadingAd;

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
    if (_rewardedAd != null || !canServeAds) return;
    if (_isLoadingAd && !_loadIsStale) return;

    _isLoadingAd = true;
    _loadStartedAt = DateTime.now();

    try {
      await RewardedAd.load(
        adUnitId: _AdIds.rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoadingAd = false;
            _setAd(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob: chargement échoué — ${error.message}');
            _isLoadingAd = false;
            _setAd(null);
            // Notifie même sans changement d'état : l'écran doit pouvoir
            // proposer « Réessayer » plutôt que de tourner dans le vide.
            onAvailabilityChanged?.call();
          },
        ),
      );
    } catch (e) {
      debugPrint('AdMob: demande de chargement impossible — $e');
      _isLoadingAd = false;
      onAvailabilityChanged?.call();
    }
  }

  bool get _loadIsStale =>
      _loadStartedAt == null ||
      DateTime.now().difference(_loadStartedAt!) > _loadTimeout;

  /// Publie une annonce fraîchement chargée. Le garde-fou d'expiration peut
  /// relancer un chargement pendant qu'un autre aboutit : sans cette
  /// libération, l'annonce remplacée resterait en mémoire, jamais affichée et
  /// jamais détruite.
  void _setAd(RewardedAd? ad) {
    final previous = _rewardedAd;
    if (previous != null && !identical(previous, ad)) previous.dispose();
    _rewardedAd = ad;
    if ((previous != null) != (ad != null)) onAvailabilityChanged?.call();
  }

  /// Retire l'annonce du stock **sans la détruire** : elle part à l'affichage,
  /// c'est le callback de fermeture qui la libérera.
  RewardedAd? _takeAd() {
    final ad = _rewardedAd;
    _rewardedAd = null;
    if (ad != null) onAvailabilityChanged?.call();
    return ad;
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

    final ad = _takeAd()!;

    // Indique si la récompense a bien été accordée avant la fermeture
    var rewarded = false;
    // Une pub ne doit jamais rendre deux verdicts : le second laisserait
    // l'appelant dans un état incohérent.
    var settled = false;
    void settle(VoidCallback outcome) {
      if (settled) return;
      settled = true;
      outcome();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        loadRewardedAd(); // pré-charge la suivante
        settle(rewarded ? onRewarded : onFailed);
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        loadRewardedAd();
        settle(onFailed);
      },
    );

    try {
      await ad.show(onUserEarnedReward: (_, __) => rewarded = true);
    } catch (e) {
      // `show()` a échoué avant d'armer quoi que ce soit : aucun callback ne
      // viendra, il faut rendre la main nous-mêmes sous peine de tout figer.
      debugPrint('AdMob: affichage impossible — $e');
      ad.dispose();
      loadRewardedAd();
      settle(onFailed);
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
