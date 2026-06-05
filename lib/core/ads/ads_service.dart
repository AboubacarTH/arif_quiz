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

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;

  bool get isAdReady => _rewardedAd != null;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    loadRewardedAd();
  }

  Future<void> loadRewardedAd() async {
    if (_isLoadingAd || _rewardedAd != null) return;
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
  /// [onRewarded] — appelé uniquement si l'utilisateur regarde jusqu'au bout.
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
        // Si fermée sans avoir obtenu la récompense → considéré comme échec
        if (!rewarded) onFailed();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        loadRewardedAd();
        onFailed();
      },
    );

    await ad.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
        onRewarded();
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
