import 'dart:async';

import 'package:arif_quiz/core/api/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IDs des produits dans Google Play Console.
/// Tu dois créer ces abonnements dans la console Play avant le lancement.
class SubscriptionIds {
  static const monthly = 'arif_quiz_premium_monthly';
  static const yearly = 'arif_quiz_premium_yearly';
  static const all = {monthly, yearly};
}

/// Ce que le serveur dit de l'abonnement du compte connecté.
class _Entitlement {
  final bool isPremium;
  final DateTime? until;

  const _Entitlement(this.isPremium, this.until);

  factory _Entitlement.fromJson(Map<String, dynamic> json) => _Entitlement(
        json['is_premium'] == true,
        DateTime.tryParse('${json['expires_at']}'),
      );
}

/// Statut premium de l'utilisateur.
///
/// Trois sources, par ordre d'autorité :
///
///   1. **le serveur**, qui a interrogé l'API Google Play Developer. Seule
///      source qu'on ne peut pas fabriquer, et la seule qui vaille pour tous
///      les appareils du compte ;
///   2. **la boutique locale**, quand il n'y a pas de compte connecté (invité)
///      ou que le serveur est injoignable ;
///   3. **le cache**, borné par l'échéance connue — il tient l'app à flot hors
///      ligne sans jamais devenir un abonnement à vie.
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._();

  /// [api] n'est renseigné qu'au câblage de l'application (`main.dart`).
  /// Sans lui le service reste utilisable, en mode boutique seule.
  factory SubscriptionService({ApiService? api}) {
    if (api != null) _instance._api = api;
    return _instance;
  }

  SubscriptionService._();

  static const _premiumKey = 'is_premium';

  /// Échéance connue de l'abonnement. Ce qui empêche le cache hors ligne de
  /// survivre à l'abonnement lui-même.
  static const _untilKey = 'premium_until';

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  ApiService? _api;

  bool _isPremium = false;
  DateTime? _premiumUntil;
  List<ProductDetails> _products = [];

  /// Rafraîchissement en cours : complété par l'instantané que la boutique
  /// dépose sur le flux d'achats. Voir [refreshEntitlement].
  Completer<List<PurchaseDetails>>? _refresh;

  /// Notifié quand le statut premium change — y compris **hors tap** : paiement
  /// différé validé plus tard par Google Play, restauration au lancement,
  /// abonnement arrivé à échéance.
  VoidCallback? onChanged;

  bool get isPremium => _isPremium;

  /// Fin de l'accès, quand le serveur nous l'a dite. Nulle pour un invité.
  DateTime? get premiumUntil => _premiumUntil;

  List<ProductDetails> get products => _products;

  ProductDetails? get monthlyProduct =>
      _products.cast<ProductDetails?>().firstWhere(
        (p) => p?.id == SubscriptionIds.monthly,
        orElse: () => null,
      );

  ProductDetails? get yearlyProduct =>
      _products.cast<ProductDetails?>().firstWhere(
        (p) => p?.id == SubscriptionIds.yearly,
        orElse: () => null,
      );

  Future<void> initialize() async {
    await _loadCache();

    final available = await _iap.isAvailable();
    if (!available) {
      // Pas de Play Billing (émulateur, appareil sans Services Google) : le
      // serveur reste consultable, un abonnement pris ailleurs vaut ici aussi.
      await _reconcile(null);
      return;
    }

    // Écoute les achats entrants (restauration, nouveaux achats)
    _subscription = _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (_) {},
    );

    // Charge les produits depuis le Play Store
    await _loadProducts();

    await refreshEntitlement();
  }

  /// Statut mis en cache : évite d'imposer une publicité à un abonné pendant la
  /// seconde où la boutique et le serveur répondent.
  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    _premiumUntil = DateTime.tryParse(prefs.getString(_untilKey) ?? '');

    final until = _premiumUntil;
    // Une échéance connue prime sur le booléen : même sans réseau, l'accès
    // s'arrête le jour dit au lieu de durer indéfiniment.
    _isPremium =
        until != null ? until.isAfter(DateTime.now()) : (prefs.getBool(_premiumKey) ?? false);
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(SubscriptionIds.all);
    _products = response.productDetails;
  }

  /// Reconstitue l'accès à partir de la boutique **puis** du serveur.
  ///
  /// Aucun événement n'est émis à l'échéance d'un abonnement : Google Play se
  /// contente de ne plus le renvoyer dans `queryPurchases`, qui ne liste que
  /// les achats encore valides (période de grâce comprise). Son absence de
  /// l'instantané est donc la seule façon de l'apprendre côté appareil — et
  /// c'est le serveur qui tranche pour le compte.
  Future<void> refreshEntitlement() async {
    // Un seul rafraîchissement à la fois : deux appels concurrents (lancement
    // + retour dans l'app) se partagent le même instantané.
    final pending = _refresh;
    if (pending != null) {
      await pending.future.catchError((_) => const <PurchaseDetails>[]);
      return;
    }

    final completer = Completer<List<PurchaseDetails>>();
    _refresh = completer;

    List<PurchaseDetails>? snapshot;
    try {
      await _iap.restorePurchases();
      // L'instantané arrive sur le flux d'achats, pas en valeur de retour :
      // sans cette attente l'appelant lirait `isPremium` avant sa mise à jour
      // — c'est ce qui rendait « Restaurer les achats » inopérant au premier
      // tap. Le délai borné évite de rester suspendu si rien n'arrive.
      snapshot = await completer.future.timeout(const Duration(seconds: 10));
    } catch (_) {
      // Boutique injoignable (hors ligne, service indisponible) : une réponse
      // manquante n'est pas une preuve d'expiration. `null` dit « je ne sais
      // pas », ce qui n'est pas la même chose qu'une liste vide.
      snapshot = null;
    } finally {
      _refresh = null;
    }

    await _reconcile(snapshot);
  }

  /// Vrai si l'instantané contient un abonnement de l'app encore valide.
  @visibleForTesting
  static bool hasActiveSubscription(List<PurchaseDetails> purchases) =>
      activeSubscriptions(purchases).isNotEmpty;

  /// Les abonnements de l'app présents dans un instantané de la boutique.
  @visibleForTesting
  static List<PurchaseDetails> activeSubscriptions(List<PurchaseDetails> purchases) =>
      purchases
          .where((p) =>
              SubscriptionIds.all.contains(p.productID) &&
              (p.status == PurchaseStatus.purchased ||
                  p.status == PurchaseStatus.restored))
          .toList();

  /// Qui l'emporte, du serveur, de la boutique ou du cache.
  ///
  /// [serverPremium] et [storeActive] valent `null` quand la source n'a pas su
  /// répondre — ce qui n'est jamais la même chose que « non ». Renvoie `null`
  /// quand personne n'a rien à dire : l'état connu survit alors tel quel.
  @visibleForTesting
  static bool? decideEntitlement({
    required bool? serverPremium,
    required bool? storeActive,
    required bool cachedStillValid,
  }) {
    // Le serveur a interrogé Google pour le compte entier : il prime, y compris
    // pour fermer l'accès que la boutique locale croirait encore ouvert.
    if (serverPremium != null) return serverPremium;

    // Sans verdict du serveur, la boutique vaut pour cet appareil, et le cache
    // — borné par l'échéance — couvre un abonnement pris sur un autre.
    if (storeActive != null) return storeActive || cachedStillValid;

    return null;
  }

  /// Tranche entre ce que dit la boutique et ce que dit le serveur.
  ///
  /// [snapshot] vaut `null` quand la boutique n'a pas répondu — à distinguer
  /// d'une liste vide, qui elle signifie « plus rien d'actif sur cet appareil ».
  Future<void> _reconcile(List<PurchaseDetails>? snapshot) async {
    final active = snapshot == null
        ? const <PurchaseDetails>[]
        : activeSubscriptions(snapshot);
    final cachedStillValid = _premiumUntil?.isAfter(DateTime.now()) ?? false;

    final server = await _askServer(active);

    final decision = decideEntitlement(
      serverPremium: server?.isPremium,
      storeActive: snapshot == null ? null : active.isNotEmpty,
      cachedStillValid: cachedStillValid,
    );

    if (server != null) _premiumUntil = server.until;
    if (decision != null) await _setPremium(decision);
  }

  /// Interroge le serveur, qui confronte les jetons d'achat à Google Play.
  ///
  /// Renvoie `null` quand il n'a pas pu se prononcer — pas de compte connecté,
  /// réseau coupé, ou achat que la vérification n'a pas encore pu trancher.
  Future<_Entitlement?> _askServer(List<PurchaseDetails> active) async {
    final api = _api;
    if (api == null) return null;

    // Un invité n'a pas de compte auquel rattacher l'abonnement.
    if (await api.getToken() == null) return null;

    var unresolved = false;
    for (final purchase in active) {
      final token = purchase.verificationData.serverVerificationData;
      if (token.isEmpty) continue;
      try {
        await api.verifySubscription(
          purchaseToken: token,
          productId: purchase.productID,
        );
      } on DioException catch (e) {
        // 409 : l'achat appartient déjà à un autre compte. C'est une réponse,
        // pas une panne — inutile de faire prévaloir la boutique là-dessus.
        if (e.response?.statusCode != 409) unresolved = true;
      } catch (_) {
        unresolved = true;
      }
    }

    try {
      final entitlement = _Entitlement.fromJson(await api.subscriptionStatus());

      // Un achat que le serveur n'a pas réussi à vérifier laisse la question
      // ouverte : refuser l'accès à quelqu'un qui vient de payer, parce que
      // Google était injoignable une seconde, serait le pire des verdicts.
      if (!entitlement.isPremium && unresolved) return null;

      return entitlement;
    } catch (_) {
      return null;
    }
  }

  void _handlePurchases(List<PurchaseDetails> purchases) async {
    // La boutique estampille en `restored` chaque ligne d'un instantané, et
    // uniquement celles-là. Une liste vide en fait partie : c'est justement
    // le cas « plus aucun abonnement actif ». Un achat qui se conclut pendant
    // un rafraîchissement n'est donc jamais pris pour l'instantané attendu.
    final refresh = _refresh;
    final isSnapshot = refresh != null &&
        !refresh.isCompleted &&
        purchases.every((p) => p.status == PurchaseStatus.restored);

    if (isSnapshot) {
      await _completeAll(purchases);
      refresh.complete(purchases);
      return;
    }

    var purchased = false;
    for (final purchase in purchases) {
      if ((purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) &&
          SubscriptionIds.all.contains(purchase.productID)) {
        purchased = true;
      }
      // Un achat non acquitté sous trois jours est remboursé par Google Play.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    if (purchased) {
      // Quelqu'un vient de payer : on ouvre l'accès sans attendre le serveur,
      // qui prendra le relais — et le rattachera au compte — dans la foulée.
      await _setPremium(true);
      unawaited(refreshEntitlement());
    }
  }

  Future<void> _completeAll(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setPremium(bool value) async {
    final changed = _isPremium != value;
    _isPremium = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);

    final until = _premiumUntil;
    if (value && until != null) {
      await prefs.setString(_untilKey, until.toIso8601String());
    } else {
      _premiumUntil = null;
      await prefs.remove(_untilKey);
    }

    if (changed) onChanged?.call();
  }

  Future<bool> buySubscription(ProductDetails product) async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    final param = PurchaseParam(productDetails: product);
    try {
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (_) {
      return false;
    }
  }

  /// Utilisé pour tester : forcer le statut premium localement.
  Future<void> debugSetPremium(bool value) async {
    await _setPremium(value);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
