/// Interprétation des réponses vrai/faux, indépendante de la langue.
///
/// Miroir de `App\Support\TrueFalse` côté serveur : l'API sert les deux choix
/// dans la langue du joueur, mais le client doit rester capable de reconnaître
/// « True » comme « Vrai » (scoring local invité, données mises en cache dans
/// une autre langue, ancienne version de l'app).
class TrueFalse {
  const TrueFalse._();

  static const _trueWords = {
    'true',
    'vrai',
    'verdadero',
    'صح',
    'صحيح',
    'yes',
    'oui',
    'sí',
    'si',
    'نعم',
    '1',
  };

  static const _falseWords = {
    'false',
    'faux',
    'falso',
    'خطأ',
    'خاطئ',
    'no',
    'non',
    'لا',
    '0',
  };

  /// null si la valeur n'est pas un vrai/faux reconnu.
  static bool? parse(String? answer) {
    if (answer == null) return null;
    final needle = answer.trim().toLowerCase();
    if (needle.isEmpty) return null;
    if (_trueWords.contains(needle)) return true;
    if (_falseWords.contains(needle)) return false;
    return null;
  }

  /// Deux réponses désignent-elles la même valeur, quelles que soient leurs
  /// langues ?
  static bool matches(String? a, String? b) {
    final left = parse(a);
    return left != null && left == parse(b);
  }
}
