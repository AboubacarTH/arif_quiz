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

  @override
  String get challengesTitle => 'Desafíos';

  @override
  String get joinBtn => 'Unirse';

  @override
  String get createChallenge => 'Crear un desafío';

  @override
  String get noChallengesYet => 'Aún no hay desafíos';

  @override
  String get createOrJoin => '¡Crea o únete a un desafío!';

  @override
  String get createBtn => 'Crear';

  @override
  String get myCreatedChallenges => 'Mis desafíos creados';

  @override
  String get deleteBtn => 'Eliminar';

  @override
  String get joinedChallenges => 'Desafíos unidos';

  @override
  String get deleteChallengeTitle => '¿Eliminar el desafío?';

  @override
  String deleteChallengeBody(String title) {
    return 'El desafío \"$title\" se eliminará definitivamente.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get challengeDeleted => 'Desafío eliminado';

  @override
  String get deleteError => 'Error al eliminar';

  @override
  String get stepSource => 'Fuente de preguntas';

  @override
  String get stepPickCategory => 'Elegir una categoría';

  @override
  String get stepPickQuiz => 'Elegir un quiz';

  @override
  String get stepConfigure => 'Configurar el desafío';

  @override
  String get enterChallengeTitle => 'Escribe un título para el desafío';

  @override
  String get createError => 'Error al crear';

  @override
  String get srcQuizLabel => 'Un quiz específico';

  @override
  String get srcQuizDesc => '10 preguntas de un quiz de tu elección';

  @override
  String get srcCategoryLabel => 'Por categoría';

  @override
  String get srcCategoryDesc =>
      '10 preguntas aleatorias de todos los quizzes de una categoría';

  @override
  String get srcAllDesc =>
      '10 preguntas aleatorias de todos los quizzes disponibles';

  @override
  String get whereQuestionsFrom => '¿De dónde vienen las preguntas?';

  @override
  String get noCategoryAvailable => 'Ninguna categoría disponible';

  @override
  String get noQuizInCategory => 'Ningún quiz en esta categoría';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get challengeTitleLabel => 'Título del desafío';

  @override
  String get challengeTitleHint => 'Ej.: ¿Quién sabe de aviación?';

  @override
  String get creating => 'Creando…';

  @override
  String get createChallengeBtn => 'Crear el desafío';

  @override
  String get joinChallengeTitle => 'Unirse a un desafío';

  @override
  String get enterChallengeCode => 'Introduce el código del desafío';

  @override
  String get codeHelp =>
      'El código de 8 caracteres te lo compartió el creador del desafío.';

  @override
  String get joinChallengeBtn => 'Unirse al desafío';

  @override
  String get challengeFound => '¡Desafío encontrado!';

  @override
  String byCreator(String name) {
    return 'por $name';
  }

  @override
  String get codeLengthError => 'El código debe tener 8 caracteres';

  @override
  String get rematchError => 'Revancha imposible. Inténtalo de nuevo.';

  @override
  String get rematch => 'Revancha';

  @override
  String get playThisChallenge => 'Jugar este desafío';

  @override
  String get alreadyPlayed =>
      'Ya jugaste este desafío. Consulta el ranking más abajo.';

  @override
  String leaderboardCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completados',
      one: '1 completado',
    );
    return 'Ranking ($_temp0)';
  }

  @override
  String get nobodyCompleted => 'Nadie ha completado este desafío todavía.';

  @override
  String pendingCount(int count) {
    return 'En espera ($count)';
  }

  @override
  String get pendingLabel => 'En espera';

  @override
  String get wrongPasswordOrNetwork => 'Contraseña incorrecta o error de red.';

  @override
  String get deleteAccountTitle => '¿Eliminar la cuenta?';

  @override
  String get password => 'Contraseña';

  @override
  String get logoutTitle => '¿Cerrar sesión?';

  @override
  String get logoutBody =>
      'Tendrás que iniciar sesión de nuevo para acceder a tu cuenta.';

  @override
  String get logoutBtn => 'Cerrar sesión';

  @override
  String get logOutAction => 'Cerrar sesión';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get editBtn => 'Editar';

  @override
  String rankLabel(int rank) {
    return 'Rango #$rank';
  }

  @override
  String nextLevelIn(int level, int xp) {
    return 'Nivel $level en $xp XP';
  }

  @override
  String get quizzesPlayed => 'Quizzes jugados';

  @override
  String get goodAnswers => 'Resp. correctas';

  @override
  String get accuracy => 'Precisión';

  @override
  String get currentStreak => 'Racha actual';

  @override
  String get bestStreak => 'Mejor racha';

  @override
  String get achievements => 'Logros';

  @override
  String get unlockBadgesByPlaying => 'Desbloquea insignias jugando';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeSystemDesc => 'Sigue el tema del dispositivo';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeDarkDesc => 'Interfaz gaming oscura';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeLightDesc => 'Interfaz luminosa';

  @override
  String get recentActivity => 'Actividad reciente';

  @override
  String get noQuizPlayed => 'Ningún quiz jugado';

  @override
  String get playFirstQuiz =>
      '¡Juega tu primer quiz para ver tus resultados aquí!';

  @override
  String get playBtn => 'Jugar';

  @override
  String get adminPanel => 'Panel de administración';

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get fillAllFields => 'Completa todos los campos';

  @override
  String get enterFullName => 'Introduce tu nombre completo';

  @override
  String get enterValidEmail => 'Introduce un correo válido';

  @override
  String get updateProfileFailed =>
      'No se pudo actualizar el perfil. Inténtalo de nuevo.';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get yourNameHint => 'Tu nombre';

  @override
  String get email => 'Correo electrónico';

  @override
  String get loadHistoryError => 'No se pudo cargar el historial.';

  @override
  String get quizHistory => 'Historial de quizzes';

  @override
  String get noAttemptsYet => 'Sin partidas aún';

  @override
  String get attemptsAppearHere =>
      'Juega un quiz y tus resultados aparecerán aquí.';

  @override
  String get refresh => 'Actualizar';

  @override
  String pointsShort(int points) {
    return '+$points pts';
  }

  @override
  String get loadBadgesError => 'No se pudieron cargar los logros.';

  @override
  String get progression => 'Progreso';

  @override
  String get alreadyPlayedToday => '¡Ya jugaste hoy!';

  @override
  String get dailyChallengeScreenTitle => 'Desafío Diario';

  @override
  String get noDailyToday => 'Hoy no hay desafío';

  @override
  String get comeBackTomorrow => '¡Vuelve mañana!';

  @override
  String get todaysChallengeTag => 'DESAFÍO DEL DÍA';

  @override
  String renewsIn(int h, int m) {
    return 'Se renueva en ${h}h ${m}m';
  }

  @override
  String get challengeCompleted => '¡Desafío completado!';

  @override
  String yourScoreGrade(String score, String grade) {
    return 'Tu puntuación: $score% • Grado $grade';
  }

  @override
  String get bonusXp30 => '⚡ +30 XP extra';

  @override
  String get takeChallenge => 'Aceptar el desafío';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get emailRequired => 'El correo es obligatorio';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

  @override
  String get welcomeBack => '¡Bienvenido\nde nuevo!';

  @override
  String get signInSubtitle => 'Inicia sesión para continuar tu aventura quiz';

  @override
  String get emailHint => 'tu@ejemplo.com';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get continueAsGuest => 'Continuar sin cuenta';

  @override
  String get scoresNotSaved => 'Las puntuaciones no se guardarán';

  @override
  String get passwordMin8 => 'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get registrationFailed =>
      'Registro fallido. El correo puede estar ya en uso.';

  @override
  String get createAccountTitle => 'Crear una\ncuenta';

  @override
  String get joinThousands => 'Únete a miles de jugadores';

  @override
  String get choosePassword => 'Elige una contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get repeatPassword => 'Repite tu contraseña';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get resetSendFailed =>
      'No se pudo enviar el código. Inténtalo de nuevo.';

  @override
  String get resetPasswordTitle => 'Restablecer\ncontraseña';

  @override
  String get resetPasswordSubtitle =>
      'Introduce tu correo para recibir un enlace de restablecimiento';

  @override
  String get sendResetLink => 'Enviar el enlace';

  @override
  String get backToSignIn => 'Volver a iniciar sesión';

  @override
  String get enterSixDigitCode =>
      'Introduce el código de 6 dígitos recibido por correo.';

  @override
  String get passwordResetSuccess => '¡Contraseña restablecida con éxito!';

  @override
  String get codeInvalidOrExpired =>
      'Código incorrecto o caducado. Inténtalo de nuevo.';

  @override
  String newCodeSentTo(String email) {
    return 'Se ha enviado un nuevo código a $email.';
  }

  @override
  String get resendCodeFailed =>
      'No se pudo reenviar el código. Inténtalo de nuevo.';

  @override
  String get newPasswordTitle => 'Nueva\ncontraseña';

  @override
  String enterCodeAndNewPassword(String email) {
    return 'Introduce el código recibido en $email y tu nueva contraseña.';
  }

  @override
  String get verificationCode => 'Código de verificación';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get resetPasswordBtn => 'Restablecer contraseña';

  @override
  String get resendCode => 'Reenviar el código';

  @override
  String get enterYourEmail => 'Introduce tu dirección de correo';

  @override
  String get enterConfirmationCode => 'Introduce el código de confirmación';

  @override
  String get emailConfirmed => 'Correo electrónico confirmado.';

  @override
  String get confirmCodeFailed => 'No se pudo confirmar este código.';

  @override
  String get confirmationEmailResent =>
      'Se ha enviado un nuevo correo de confirmación.';

  @override
  String get confirmationEmailResendFailed =>
      'No se pudo reenviar el correo de confirmación.';

  @override
  String get confirmEmail => 'Confirmar correo';

  @override
  String get confirmEmailTitle => 'Confirmar\ncorreo';

  @override
  String get validateEmailSubtitle =>
      'Valida tu correo para proteger tu cuenta';

  @override
  String get confirmationCode => 'Código de confirmación';

  @override
  String get enterYourCode => 'Introduce tu código';

  @override
  String get resendEmail => 'Reenviar correo';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get guestScreenBody =>
      'Guarda tu progreso, crea desafíos\ny encuentra a tus amigos.';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get appTagline => 'Desafía a tus amigos. Domina el quiz.';

  @override
  String get exitAppTitle => '¿Salir de la aplicación?';

  @override
  String get exitAppBody => '¿Seguro que quieres salir de ArifQuiz?';

  @override
  String get profileTab => 'Perfil';

  @override
  String get playNow => 'Jugar ahora';

  @override
  String get keepPlayingTitle => 'Sigue jugando';

  @override
  String get paywallBody =>
      'Mira un anuncio corto o pásate a Premium\npara jugar sin interrupciones.';

  @override
  String get adLoading => 'Cargando anuncio…';

  @override
  String get yearly => 'Anual';

  @override
  String get monthly => 'Mensual';

  @override
  String get premiumBanner =>
      'Arif Quiz Premium\nSin anuncios · Todas las funciones';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get watchAd => 'Ver un anuncio (≈30s)';

  @override
  String get somethingWrong => 'Algo salió mal.';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get noInternet => 'Sin conexión a internet';
}
