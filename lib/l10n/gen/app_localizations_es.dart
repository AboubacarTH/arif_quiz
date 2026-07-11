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

  @override
  String questionNumber(int number) {
    return 'Pregunta $number';
  }

  @override
  String get skip => 'Saltar →';

  @override
  String get loadQuestionsError => 'No se pudieron cargar las preguntas.';

  @override
  String get loadLevelError => 'No se pudo cargar este nivel.';

  @override
  String get invalidSession => 'Sesión inválida. Reintenta el nivel.';

  @override
  String get submitError => 'Error al enviar. Revisa tu conexión.';

  @override
  String get calculatingResults => 'Calculando resultados…';

  @override
  String get survivalTag => 'MODO SUPERVIVENCIA';

  @override
  String get gameOver => '¡Game Over!';

  @override
  String survivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sobreviviste a $count preguntas',
      one: 'Sobreviviste a 1 pregunta',
      zero: 'No sobreviviste a ninguna pregunta',
    );
    return '$_temp0';
  }

  @override
  String get seeResults => 'Ver resultados';

  @override
  String get quit => 'Salir';

  @override
  String get quitGameTitle => '¿Salir de la partida?';

  @override
  String get quitGameBody => 'Perderás tu progreso.';

  @override
  String get keepPlaying => 'Continuar';

  @override
  String get journeyMapTitle => 'Modo Aventura';

  @override
  String journeyLevelProgress(int current, int total) {
    return 'Nivel $current / $total';
  }

  @override
  String get journeyUnavailable => 'Aventura no disponible';

  @override
  String get comeBackLater => 'Vuelve más tarde';

  @override
  String levelsCount(int count) {
    return '🏁  $count niveles';
  }

  @override
  String get play => 'JUGAR';

  @override
  String bossShort(int level) {
    return 'JEFE $level';
  }

  @override
  String get resultPerfect => '¡Perfecto!';

  @override
  String get resultGreat => '¡Bien hecho!';

  @override
  String get resultPassed => 'Nivel superado';

  @override
  String get resultAlmost => '¡Casi!';

  @override
  String bossLevelLabel(int level) {
    return 'Jefe · Nivel $level';
  }

  @override
  String levelLabel(int level) {
    return 'Nivel $level';
  }

  @override
  String get nextLevel => 'Siguiente nivel';

  @override
  String get retry => 'Reintentar';

  @override
  String get replay => 'Volver a jugar';

  @override
  String get viewMap => 'Ver el mapa';

  @override
  String get score => 'Puntuación';

  @override
  String get correctLabel => 'Correctas';
}
