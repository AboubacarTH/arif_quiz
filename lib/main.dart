import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_controller.dart';
import 'core/api/api_service.dart';
import 'core/messaging/messaging_service.dart';
import 'core/monetization/monetization_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

final apiService = ApiService();
final themeController = ThemeController();
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
  runApp(const QuizApp());
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
      listenable: themeController,
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
          home: const SplashScreen(),
        );
      },
    );
  }
}
