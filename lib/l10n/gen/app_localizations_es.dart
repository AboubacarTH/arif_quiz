// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String greeting(String name) {
    return 'Hola, $name 👋';
  }

  @override
  String get guest => 'Invitado';

  @override
  String get readyToPlay => '¿Listo para jugar?';

  @override
  String get categories => 'Categorías';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get popular => '🔥 Populares';

  @override
  String get friendsLeaderboard => '🏅 Ranking de amigos';

  @override
  String get guestBannerTitle => '¡Guarda tu progreso!';

  @override
  String get guestBannerSubtitle =>
      'Crea una cuenta para desbloquear XP, rachas y ranking.';

  @override
  String get signUp => 'Registrarse';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get dailyChallengeTag => 'DESAFÍO DIARIO';

  @override
  String get dailyChallengeTitle => 'Un quiz especial cada día';

  @override
  String get dailyChallengeSubtitle => '+30 XP extra · Mantiene tu racha';

  @override
  String get journeyTag => 'MODO AVENTURA';

  @override
  String get journeyTitle => 'Sube los niveles del mapa';

  @override
  String get journeySubtitle => 'Desbloquea niveles, gana estrellas ⭐';

  @override
  String levelShort(int level) {
    return 'Niv. $level';
  }

  @override
  String quizCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quizzes',
      one: '1 quiz',
      zero: '0 quizzes',
    );
    return '$_temp0';
  }

  @override
  String get language => 'Idioma';

  @override
  String get chooseLanguage => 'Elige tu idioma';

  @override
  String get languageSystemNote =>
      'También se aplica al contenido de quizzes y preguntas.';
}
