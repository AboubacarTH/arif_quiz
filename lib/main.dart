import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_controller.dart';
import 'core/api/api_service.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

final apiService = ApiService();
final themeController = ThemeController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const QuizApp());
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
