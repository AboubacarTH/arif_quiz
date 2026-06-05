import 'package:arif_quiz/core/ads/ads_service.dart';
import 'package:arif_quiz/core/subscriptions/subscription_service.dart';
import 'package:flutter/foundation.dart';

/// Contrôleur central qui combine publicités + abonnements.
///
/// 🔧 Pour activer les pubs et abonnements en production :
///    Passer [adsEnabled] à `true`.
class MonetizationController extends ChangeNotifier {
  final AdsService _ads;
  final SubscriptionService _subs;

  // ═══════════════════════════════════════════════════════════════
  // Mettre à true pour activer les publicités et le paywall
  static const bool adsEnabled = false;
  // ═══════════════════════════════════════════════════════════════

  MonetizationController({
    AdsService? ads,
    SubscriptionService? subs,
  })  : _ads = ads ?? AdsService(),
        _subs = subs ?? SubscriptionService();

  bool get isPremium => !adsEnabled || _subs.isPremium;
  bool get isAdReady => adsEnabled && _ads.isAdReady;

  Future<void> initialize() async {
    if (!adsEnabled) return; // ne charge pas AdMob si désactivé
    await Future.wait([
      _ads.initialize(),
      _subs.initialize(),
    ]);
    notifyListeners();
  }

  /// Demande à jouer.
  /// - Pubs désactivées → [onGranted] directement (accès libre)
  /// - Premium → [onGranted] directement
  /// - Pub disponible → affiche la pub, puis [onGranted] sur récompense
  /// - Pas de pub → [onNoAd] (affiche le paywall)
  Future<void> requestPlay({
    required VoidCallback onGranted,
    required VoidCallback onNoAd,
  }) async {
    if (!adsEnabled) {
      onGranted();
      return;
    }

    if (isPremium) {
      onGranted();
      return;
    }

    if (_ads.isAdReady) {
      await _ads.showRewardedAd(
        onRewarded: () {
          notifyListeners();
          onGranted();
        },
        onFailed: () {
          notifyListeners();
          onNoAd();
        },
      );
    } else {
      _ads.loadRewardedAd();
      onNoAd();
    }
  }

  void refresh() => notifyListeners();
}
