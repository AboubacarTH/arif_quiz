import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IDs des produits dans Google Play Console.
/// Tu dois créer ces abonnements dans la console Play avant le lancement.
class SubscriptionIds {
  static const monthly = 'arif_quiz_premium_monthly';
  static const yearly = 'arif_quiz_premium_yearly';
  static const all = {monthly, yearly};
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._();
  factory SubscriptionService() => _instance;
  SubscriptionService._();

  static const _premiumKey = 'is_premium';

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  List<ProductDetails> _products = [];

  bool get isPremium => _isPremium;
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
    // Charge le statut premium mis en cache
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;

    final available = await _iap.isAvailable();
    if (!available) return;

    // Écoute les achats entrants (restauration, nouveaux achats)
    _subscription = _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (_) {},
    );

    // Charge les produits depuis le Play Store
    await _loadProducts();

    // Restaure les achats existants
    await _iap.restorePurchases();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(SubscriptionIds.all);
    _products = response.productDetails;
  }

  void _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _setPremium(true);
        await _iap.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        // Ne rien faire
      }
    }
  }

  Future<void> _setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
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

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Utilisé pour tester : forcer le statut premium localement.
  Future<void> debugSetPremium(bool value) async {
    await _setPremium(value);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
