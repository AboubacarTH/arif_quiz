import 'package:arif_quiz/core/ads/ads_service.dart';
import 'package:arif_quiz/core/ads/consent_service.dart';
import 'package:arif_quiz/core/monetization/monetization_controller.dart';
import 'package:arif_quiz/core/monetization/play_credits.dart';
import 'package:arif_quiz/core/subscriptions/subscription_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Règle métier : sans abonnement, une publicité regardée jusqu'au bout vaut
/// [PlayCreditsService.perAd] parties **dont celle lancée juste après**.

class _FakeAds implements AdsService {
  /// Réglés par les tests pour rejouer les scénarios réels : pas d'inventaire
  /// AdMob, ou pub fermée avant la fin.
  bool ready = true;
  bool rewardUser = true;
  int shown = 0;

  /// Consentement refusé : aucune pub ne pourra jamais être servie.
  bool blocked = false;
  bool loading = false;
  int loadCalls = 0;

  /// Faux = l'inventaire reste vide (hors ligne, aucune pub à servir).
  bool loadSucceeds = true;

  @override
  VoidCallback? onAvailabilityChanged;

  @override
  bool get isAdLoading => loading;

  @override
  bool get isSupported => true;

  @override
  bool get adsBlocked => blocked;

  @override
  bool get canServeAds => !blocked;

  @override
  ConsentService get consent => throw UnimplementedError();

  @override
  bool get isAdReady => ready;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> loadRewardedAd() async {
    loadCalls++;
    if (loadSucceeds) ready = true;
    onAvailabilityChanged?.call();
  }

  @override
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    shown++;
    ready = false;
    if (rewardUser) {
      onRewarded();
    } else {
      onFailed();
    }
    // Le vrai service précharge la suivante dès la fermeture.
    ready = true;
  }

  @override
  void dispose() {}
}

class _FakeSubs implements SubscriptionService {
  @override
  bool isPremium;

  @override
  VoidCallback? onChanged;

  _FakeSubs({this.isPremium = false});

  @override
  Future<void> initialize() async {}

  @override
  List<ProductDetails> get products => const [];

  @override
  ProductDetails? get monthlyProduct => null;

  @override
  ProductDetails? get yearlyProduct => null;

  @override
  Future<bool> buySubscription(ProductDetails product) async => false;

  @override
  Future<void> restorePurchases() async {}

  @override
  Future<void> debugSetPremium(bool value) async => isPremium = value;

  @override
  void dispose() {}
}

/// Lance une partie et dit ce qui s'est passé.
Future<({bool granted, bool paywall})> play(
    MonetizationController ctrl) async {
  var granted = false;
  var paywall = false;
  await ctrl.requestPlay(
    onGranted: () => granted = true,
    onNoAd: () => paywall = true,
  );
  return (granted: granted, paywall: paywall);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAds ads;
  late _FakeSubs subs;
  late PlayCreditsService credits;
  late MonetizationController ctrl;

  Future<void> build({bool premium = false, int startCredits = 0}) async {
    SharedPreferences.setMockInitialValues({'play_credits': startCredits});
    ads = _FakeAds();
    subs = _FakeSubs(isPremium: premium);
    credits = PlayCreditsService();
    await credits.load();
    ctrl = MonetizationController(ads: ads, subs: subs, credits: credits);
  }

  setUp(() => build());

  test('le coupe-circuit est armé (sinon rien de tout ceci ne s\'applique)', () {
    expect(MonetizationController.adsEnabled, isTrue);
  });

  test('un abonné joue sans pub ni débit', () async {
    await build(premium: true);

    final r = await play(ctrl);

    expect(r.granted, isTrue);
    expect(r.paywall, isFalse);
    expect(ads.shown, 0);
    expect(ctrl.credits, 0);
  });

  test('une pub regardée = 3 parties, dont celle lancée dans la foulée',
      () async {
    final first = await play(ctrl);

    expect(first.granted, isTrue);
    expect(ads.shown, 1);
    expect(ctrl.credits, PlayCreditsService.perAd - 1); // 2 en réserve

    // Les parties suivantes puisent dans la réserve, sans nouvelle pub.
    final second = await play(ctrl);
    final third = await play(ctrl);

    expect(second.granted, isTrue);
    expect(third.granted, isTrue);
    expect(ads.shown, 1);
    expect(ctrl.credits, 0);

    // La 4e repasse par la case publicité.
    final fourth = await play(ctrl);
    expect(fourth.granted, isTrue);
    expect(ads.shown, 2);
    expect(ctrl.credits, PlayCreditsService.perAd - 1);
  });

  test('pub fermée avant la fin : aucun crédit, paywall proposé', () async {
    ads.rewardUser = false;

    final r = await play(ctrl);

    expect(r.granted, isFalse);
    expect(r.paywall, isTrue);
    expect(ctrl.credits, 0);
  });

  test('aucune pub disponible : paywall, et une pub est mise en chargement',
      () async {
    ads.ready = false;

    final r = await play(ctrl);

    expect(r.granted, isFalse);
    expect(r.paywall, isTrue);
    expect(ads.shown, 0);
    expect(ads.isAdReady, isTrue, reason: 'la suivante doit être préchargée');
  });

  test('depuis le profil, la pub crédite sans consommer de partie', () async {
    var rewarded = false;
    await ctrl.watchAdForCredits(
      onRewarded: () => rewarded = true,
      onFailed: () {},
    );

    expect(rewarded, isTrue);
    expect(ctrl.credits, PlayCreditsService.perAd); // 3, pas 2
  });

  test('le solde survit au redémarrage de l\'app', () async {
    await play(ctrl); // laisse 2 crédits en base

    final revived = PlayCreditsService();
    await revived.load();

    expect(revived.credits, PlayCreditsService.perAd - 1);
  });

  test('un solde existant évite la pub au démarrage', () async {
    await build(startCredits: 2);

    final r = await play(ctrl);

    expect(r.granted, isTrue);
    expect(ads.shown, 0);
    expect(ctrl.credits, 1);
  });

  test('une partie lancée avant la fin du chargement voit son vrai solde',
      () async {
    // `initialize()` n'est pas attendu au lancement de l'app : le contrôleur
    // doit charger le solde lui-même plutôt que de le croire vide.
    SharedPreferences.setMockInitialValues({'play_credits': 2});
    final cold = MonetizationController(
      ads: _FakeAds(),
      subs: _FakeSubs(),
      credits: PlayCreditsService(), // jamais chargé
    );

    final r = await play(cold);

    expect(r.granted, isTrue);
    expect(cold.credits, 1, reason: 'le solde persisté doit être relu');
  });

  test('consentement refusé : on laisse jouer plutôt que d\'enfermer', () async {
    ads.blocked = true;

    final r = await play(ctrl);

    expect(r.granted, isTrue);
    expect(r.paywall, isFalse, reason: 'un refus ne doit pas priver du jeu');
    expect(ads.shown, 0);
    expect(ctrl.adsRequired, isFalse);
  });

  test('consentement pas encore résolu : le portail reste fermé', () async {
    // Au démarrage, `adsBlocked` est faux tant que le SDK n'a pas répondu :
    // sans cette nuance, la première seconde de l'app serait gratuite.
    ads.blocked = false;
    ads.ready = false;

    final r = await play(ctrl);

    expect(r.granted, isFalse);
    expect(r.paywall, isTrue);
  });

  group('Non-régression : le paywall figé après épuisement des crédits', () {
    test('la demande se termine même si le lancement de la partie échoue',
        () async {
      // Le paywall appelait `Navigator.pop` sur une feuille parfois déjà
      // fermée : l'exception sautait la complétion et le bouton tournait
      // indéfiniment, sans aucune issue pour le joueur.
      var completed = false;

      await ctrl.requestPlay(
        onGranted: () => throw StateError('navigation impossible'),
        onNoAd: () {},
      ).whenComplete(() => completed = true);

      expect(completed, isTrue, reason: 'ne doit jamais rester suspendu');
      // La récompense reste acquise : la pub a bien été regardée.
      expect(ctrl.credits, PlayCreditsService.perAd - 1);
    });

    test('l\'arrivée d\'une pub réveille l\'écran ouvert', () async {
      // Le paywall s'ouvre faute de pub ; il doit se reconstruire tout seul
      // dès qu'une pub devient disponible, sans que l'utilisateur le referme.
      ads.ready = false;
      await play(ctrl); // ouvre le paywall (onNoAd)

      var notified = 0;
      ctrl.addListener(() => notified++);

      await ctrl.prepareAd();

      expect(ctrl.isAdReady, isTrue);
      expect(notified, greaterThan(0), reason: 'l\'UI doit être prévenue');
    });

    test('un échec de pub laisse toujours une action possible', () async {
      ads.ready = false;
      ads.loading = false;
      ads.loadSucceeds = false; // rien à servir, même après relance

      final r = await play(ctrl);

      expect(r.paywall, isTrue);
      // Ni pub prête ni chargement en cours : l'écran propose « Réessayer »
      // plutôt qu'un spinner sans fin.
      expect(ctrl.isAdReady, isFalse);
      expect(ctrl.isAdLoading, isFalse);
      expect(ads.loadCalls, greaterThan(0), reason: 'une relance est amorcée');
    });
  });

  test('devenir premium notifie l\'UI sans nouveau tap', () async {
    var notified = 0;
    ctrl.addListener(() => notified++);

    subs.isPremium = true;
    subs.onChanged?.call();

    expect(notified, 1);
    expect(ctrl.isPremium, isTrue);
    expect(ctrl.adsRequired, isFalse);
  });
}
