import 'package:flutter/material.dart';

// ─── Palettes dépendantes du thème ─────────────────────────────────────────

class AppColorScheme {
  final Color bg;
  final Color cardBg;
  final Color cardBgLight;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const AppColorScheme({
    required this.bg,
    required this.cardBg,
    required this.cardBgLight,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const dark = AppColorScheme(
    bg: Color(0xFF0D0D1A),
    cardBg: Color(0xFF161629),
    cardBgLight: Color(0xFF1E1E38),
    surface: Color(0xFF111122),
    border: Color(0xFF2A2A4A),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
  );

  static const light = AppColorScheme(
    bg: Color(0xFFF5F3FF),
    cardBg: Color(0xFFFFFFFF),
    cardBgLight: Color(0xFFEDE9FE),
    surface: Color(0xFFF0EEFF),
    border: Color(0xFFDDD6FE),
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF4C3D8F),
    textMuted: Color(0xFF9083C5),
  );

  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension AppColorSchemeExt on BuildContext {
  AppColorScheme get appColors => AppColorScheme.of(this);
}

// ─── Couleurs partagées (identiques dark & light) ───────────────────────────

class AppColors {
  // Accents neon — identiques dans les deux thèmes
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFF9D5FF7);
  static const primaryDark = Color(0xFF5B21B6);
  static const secondary = Color(0xFF06B6D4);
  static const secondaryLight = Color(0xFF22D3EE);
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);

  // Status
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF06B6D4);

  // Difficulté
  static const easy = Color(0xFF10B981);
  static const medium = Color(0xFFF59E0B);
  static const hard = Color(0xFFEF4444);

  // Grades
  static const gradeS = Color(0xFFF59E0B);
  static const gradeA = Color(0xFF10B981);
  static const gradeB = Color(0xFF06B6D4);
  static const gradeC = Color(0xFF7C3AED);
  static const gradeD = Color(0xFFF97316);
  static const gradeF = Color(0xFFEF4444);

  // Modes de jeu
  static const modeClassic = Color(0xFF7C3AED);
  static const modeSurvival = Color(0xFFEF4444);
  static const modeSpeed = Color(0xFF06B6D4);

  // ── Aliases de compatibilité (backward compat) ──
  // Ces valeurs pointent vers le thème dark ; les écrans migrent vers context.appColors
  static const darkBg = Color(0xFF0D0D1A);
  static const cardBg = Color(0xFF161629);
  static const cardBgLight = Color(0xFF1E1E38);
  static const surface = Color(0xFF111122);
  static const background = darkBg;
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);

  static Color gradeColor(String grade) => switch (grade) {
        'S' => gradeS,
        'A' => gradeA,
        'B' => gradeB,
        'C' => gradeC,
        'D' => gradeD,
        _ => gradeF,
      };

  static Color difficultyColor(String difficulty) => switch (difficulty) {
        'easy' => easy,
        'medium' => medium,
        'hard' => hard,
        _ => const Color(0xFF94A3B8),
      };

  static Color modeColor(String mode) => switch (mode) {
        'survival' => modeSurvival,
        'speed' => modeSpeed,
        _ => modeClassic,
      };
}

// ─── Thèmes Material3 ───────────────────────────────────────────────────────

class AppTheme {
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        cs: AppColorScheme.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Color(0xFF161629),
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFF1F5F9),
          onError: Colors.white,
        ),
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        cs: AppColorScheme.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Color(0xFFFFFFFF),
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1E1B4B),
          onError: Colors.white,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required AppColorScheme cs,
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        brightness: brightness,
        scaffoldBackgroundColor: cs.bg,
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: cs.bg,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: cs.textPrimary),
          titleTextStyle: TextStyle(
            color: cs.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Nunito',
          ),
        ),
        cardTheme: CardThemeData(
          color: cs.cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.border, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cs.cardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: cs.textSecondary),
          hintStyle: TextStyle(color: cs.textMuted),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w800),
          headlineLarge: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: cs.textPrimary),
          bodyMedium: TextStyle(color: cs.textSecondary),
          labelLarge: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w700),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: cs.cardBg,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: cs.textMuted,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
        ),
        dividerTheme: DividerThemeData(color: cs.border, thickness: 1),
        chipTheme: ChipThemeData(
          backgroundColor: cs.cardBgLight,
          labelStyle: TextStyle(color: cs.textPrimary),
          side: BorderSide(color: cs.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        listTileTheme: ListTileThemeData(
          tileColor: Colors.transparent,
          textColor: cs.textPrimary,
          iconColor: cs.textSecondary,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: cs.cardBg,
          contentTextStyle: TextStyle(color: cs.textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: cs.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: cs.cardBg,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: cs.textMuted,
          indicatorColor: AppColors.primary,
          dividerColor: cs.border,
        ),
      );
}

// ─── Gradients ──────────────────────────────────────────────────────────────

class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondary = LinearGradient(
    colors: [AppColors.secondary, Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gold = LinearGradient(
    colors: [AppColors.accent, AppColors.accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient dark(BuildContext context) {
    final cs = context.appColors;
    return LinearGradient(
      colors: [cs.bg, cs.cardBg],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static const survival = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const speed = LinearGradient(
    colors: [AppColors.secondary, Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
