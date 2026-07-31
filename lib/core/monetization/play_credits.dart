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

  /// Plafond du solde. Une publicité regardée alors qu'il reste des crédits
  /// (possible depuis le profil) ne les cumule pas : le solde est ramené au
  /// plafond. Sans cela on pouvait accumuler 5, 8, 11 parties d'avance.
  static const int maxCredits = perAd;

  static const _key = 'play_credits';

  int _credits = 0;
  bool _loaded = false;

  int get credits => _credits;
  bool get hasCredits => _credits > 0;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    // Le clamp s'applique aussi à la relecture : un solde gonflé par l'ancienne
    // version redescend au plafond dès le premier chargement.
    _credits = (prefs.getInt(_key) ?? 0).clamp(0, maxCredits);
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
    // Borné des deux côtés : un solde négatif serait un bug de comptage, un
    // solde au-dessus du plafond une accumulation non voulue. Le clamp couvre
    // aussi les valeurs héritées d'une version précédente, déjà en base.
    _credits = value.clamp(0, maxCredits);
    _loaded = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _credits);
  }
}
