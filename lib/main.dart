import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'l10n/gen/app_localizations.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_controller.dart';
import 'core/api/api_service.dart';
import 'core/i18n/locale_controller.dart';
import 'core/messaging/messaging_service.dart';
import 'core/monetization/monetization_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

final apiService = ApiService();
final themeController = ThemeController();
final localeController = LocaleController();
final monetizationController = MonetizationController();
final messagingService = MessagingService(apiService);
final ValueNotifier<bool> isGuest = ValueNotifier(false);
final navigatorKey = GlobalKey<NavigatorState>();
bool _handlingUnauthorized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Initialise AdMob + Play Billing en arrière-plan au démarrage
  monetizationController.initialize();
  // Initialise Firebase Messaging (push) en arrière-plan
  messagingService.initialize();
  _wireUnauthorizedRedirect();
  _wireLocale();
  runApp(const QuizApp());
}

/// Propage la langue choisie : en-tête API (contenu multilingue), messages
/// relatifs de timeago, et synchronisation du profil pour les connectés.
void _wireLocale() {
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('es', timeago.EsMessages());

  localeController.onChanged = (code) {
    apiService.setLocale(code);
    timeago.setDefaultLocale(code);
    if (!isGuest.value) {
      // Meilleur-effort : l'échec (hors-ligne, invité…) est sans conséquence.
      apiService.syncProfileLocale(code).catchError((_) {});
    }
  };
  // Applique la locale initiale (appareil ou persistée).
  localeController.onChanged!(localeController.code);
}

/// Redirige vers l'écran de connexion dès qu'une requête protégée renvoie 401
/// (session expirée). Un verrou évite les redirections multiples simultanées.
void _wireUnauthorizedRedirect() {
  apiService.onUnauthorized = () {
    final nav = navigatorKey.currentState;
    if (nav == null || _handlingUnauthorized) return;
    _handlingUnauthorized = true;
    isGuest.value = false;
    nav
        .pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        )
        .then((_) => _handlingUnauthorized = false);
  };
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeController, localeController]),
      builder: (_, __) {
        final isDark = themeController.mode == ThemeMode.dark ||
            (themeController.mode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark);

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDark
              ? AppColorScheme.dark.cardBg
              : AppColorScheme.light.cardBg,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ));

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Arif Quiz',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          locale: localeController.locale,
          supportedLocales: LocaleController.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
