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

  @override
  String get trainingResultNote =>
      'Modo práctica — este resultado no afecta tu XP ni el ranking.';

  @override
  String get answerReview => 'Revisión de respuestas';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get homeLabel => 'Inicio';

  @override
  String get viewChallenge => 'Ver el desafío';

  @override
  String get headlineOutstanding => '¡Impresionante! 🤩';

  @override
  String get headlineExcellent => '¡Excelente! 🎉';

  @override
  String get headlineGreat => '¡Bien hecho! 👏';

  @override
  String get headlineNotBad => '¡Nada mal! 👍';

  @override
  String get headlineKeepGoing => '¡Sigue así! 💪';

  @override
  String get headlineTryAgain => '¡Inténtalo de nuevo! 🔄';

  @override
  String get yourAnswer => 'Tu respuesta';

  @override
  String get points => 'Puntos';

  @override
  String get timeLabel => 'Tiempo';

  @override
  String get reportQuestionAction => 'Reportar un error';

  @override
  String get reportQuestionTitle => 'Reportar esta pregunta';

  @override
  String get reportReasonLabel => 'Motivo';

  @override
  String get reasonWrongAnswer => 'La respuesta correcta es incorrecta';

  @override
  String get reasonAmbiguous => 'Pregunta ambigua o mal formulada';

  @override
  String get reasonTypo => 'Error ortográfico';

  @override
  String get reasonOutdated => 'Información desactualizada';

  @override
  String get reasonOther => 'Otro';

  @override
  String get commentOptional => 'Comentario (opcional)';

  @override
  String get sendReport => 'Enviar el reporte';

  @override
  String get sendFailed => 'Fallo al enviar. Inténtalo de nuevo.';

  @override
  String get allQuizzes => 'Todos los quizzes';

  @override
  String get searchQuizHint => 'Buscar un quiz…';

  @override
  String get loadingEllipsis => 'Cargando…';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get diffEasy => 'Fácil';

  @override
  String get diffMedium => 'Medio';

  @override
  String get diffHard => 'Difícil';

  @override
  String get allFilter => 'Todos';

  @override
  String get noQuizFound => 'No se encontró ningún quiz';

  @override
  String get tryAnotherFilter => 'Prueba otro filtro u otra búsqueda';

  @override
  String get searchCategoryHint => 'Buscar una categoría…';

  @override
  String noResultsFor(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get loadQuizError => 'No se pudo cargar el quiz.';

  @override
  String get quizDetails => 'Detalles del quiz';

  @override
  String get questions => 'Preguntas';

  @override
  String get perQuestion => 'Por pregunta';

  @override
  String get pointsPerQ => 'Puntos / P';

  @override
  String get plays => 'Partidas';

  @override
  String get ruleSelectOne => 'Elige una respuesta por pregunta';

  @override
  String get ruleTimer => 'Responde antes de que acabe el tiempo';

  @override
  String rulePoints(int points) {
    return 'Gana $points puntos por respuesta correcta';
  }

  @override
  String get ruleReview => 'Revisa las explicaciones al terminar';

  @override
  String get startQuiz => 'Empezar el quiz 🚀';

  @override
  String get tryAnotherDifficulty => 'Prueba otro filtro de dificultad';

  @override
  String get loadCategoriesError => 'No se pudieron cargar las categorías';

  @override
  String get noCategories => 'Sin categorías';

  @override
  String get comeBackSoon => 'Vuelve más tarde, pronto habrá contenido nuevo';

  @override
  String get chooseMode => 'Elegir modo';

  @override
  String get randomQuestions10 => '10 preguntas aleatorias';

  @override
  String get questions10 => '10 preguntas';

  @override
  String get gameModeLabel => 'Modo de juego';

  @override
  String get modeClassic => 'Modo Clásico';

  @override
  String get modeClassicDesc =>
      '10 preguntas aleatorias · Temporizador por pregunta · Puntuación en %';

  @override
  String get modeSurvival => 'Modo Supervivencia';

  @override
  String get modeSurvivalDesc =>
      '10 preguntas · Un error y se acabó · Bono ×1.3';

  @override
  String get modeSpeed => 'Ronda Rápida';

  @override
  String get modeSpeedDesc =>
      '10 preguntas · 5 segundos por pregunta · Bono XP ×1.5';

  @override
  String playInMode(String mode) {
    return 'Jugar en modo $mode';
  }

  @override
  String get trainingMode => 'Modo práctica';

  @override
  String get trainingSubtitle => 'Elige el número de preguntas · sin riesgo';

  @override
  String get trainingSheetBody => 'Juega sin afectar tu XP ni el ranking.';

  @override
  String get questionCountLabel => 'Número de preguntas';

  @override
  String get startBtn => 'Empezar';

  @override
  String get oneLife => '1 vida';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get markAllRead => 'Leer todo';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get friends => 'Amigos';

  @override
  String get requestsTab => 'Solicitudes';

  @override
  String get activityTab => 'Actividad';

  @override
  String get noFriendsYet => 'Aún no tienes amigos';

  @override
  String get searchPlayersToAdd => '¡Busca jugadores para añadir!';

  @override
  String get addFriends => 'Añadir amigos';

  @override
  String sinceLabel(String time) {
    return 'Desde $time';
  }

  @override
  String get noPendingRequests => 'Sin solicitudes pendientes';

  @override
  String get noRecentActivity => 'Sin actividad reciente';

  @override
  String get removeFriend => 'Eliminar este amigo';

  @override
  String get searchByNameHint => 'Buscar por nombre o @username…';

  @override
  String get noPlayerFound => 'Ningún jugador encontrado';

  @override
  String get requestSent => '¡Solicitud enviada!';

  @override
  String get sentLabel => 'Enviada';

  @override
  String get receivedLabel => 'Recibida';

  @override
  String get addBtn => 'Añadir';

  @override
  String get modeClassicShort => 'Clásico';

  @override
  String get modeSurvivalShort => 'Supervivencia';

  @override
  String get modeSpeedShort => 'Ronda Rápida';
}
