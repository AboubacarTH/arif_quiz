import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Crédits de parties gagnés en regardant une publicité récompensée.
///
/// Une publicité vaut [perAd] parties **dont celle lancée juste après** :
/// l'utilisateur en consomme une immédiatement et repart avec `perAd - 1`
/// en réserve. Le solde est local (SharedPreferences) : une réinstallation
/// le remet à zéro, ce qui est sans conséquence — il ne s'achète pas.
class PlayCreditsService extends ChangeNotifier {
  /// Parties débloquées par publicité regardée jusqu'au bout.
  static const int perAd = 3;

  static const _key = 'play_credits';

  int _credits = 0;
  bool _loaded = false;

  int get credits => _credits;
  bool get hasCredits => _credits > 0;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _credits = prefs.getInt(_key) ?? 0;
    _loaded = true;
    notifyListeners();
  }

  /// Crédite la récompense d'une publicité regardée entièrement.
  Future<void> grantAdReward() => _set(_credits + perAd);

  /// Débite une partie. Renvoie `false` si le solde est vide : l'appelant doit
  /// alors proposer la publicité (ou l'abonnement).
  Future<bool> consumeOne() async {
    if (_credits <= 0) return false;
    await _set(_credits - 1);
    return true;
  }

  Future<void> reset() => _set(0);

  Future<void> _set(int value) async {
    _credits = value < 0 ? 0 : value;
    _loaded = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _credits);
  }
}
