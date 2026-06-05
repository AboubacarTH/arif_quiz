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

  static const light = AppColorScheme(
    bg: Color(0xFFFFFFFF),
    cardBg: Color(0xFFFFFFFF),
    cardBgLight: Color(0xFFF0FFF4),
    surface: Color(0xFFF9FAFB),
    border: Color(0xFFD1FAE5),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
  );

  static const dark = AppColorScheme(
    bg: Color(0xFF111827),
    cardBg: Color(0xFF1F2937),
    cardBgLight: Color(0xFF374151),
    surface: Color(0xFF1F2937),
    border: Color(0xFF374151),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFFD1D5DB),
    textMuted: Color(0xFF6B7280),
  );

  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension AppColorSchemeExt on BuildContext {
  AppColorScheme get appColors => AppColorScheme.of(this);
}

// ─── Couleurs partagées (identiques dark & light) ───────────────────────────

class AppColors {
  // ── Vert (couleur principale) ──
  static const primary = Color(0xFF16A34A);
  static const primaryLight = Color(0xFF22C55E);
  static const primaryDark = Color(0xFF15803D);

  // ── Orange (accent) ──
  static const secondary = Color(0xFFF97316);
  static const secondaryLight = Color(0xFFFB923C);
  static const accent = Color(0xFFF97316);
  static const accentLight = Color(0xFFFB923C);

  // ── Status ──
  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF97316);
  static const info = Color(0xFF3B82F6);

  // ── Difficulté ──
  static const easy = Color(0xFF16A34A);
  static const medium = Color(0xFFF97316);
  static const hard = Color(0xFFEF4444);

  // ── Grades ──
  static const gradeS = Color(0xFFF97316);
  static const gradeA = Color(0xFF16A34A);
  static const gradeB = Color(0xFF3B82F6);
  static const gradeC = Color(0xFF8B5CF6);
  static const gradeD = Color(0xFFF59E0B);
  static const gradeF = Color(0xFFEF4444);

  // ── Modes de jeu ──
  static const modeClassic = Color(0xFF16A34A);
  static const modeSurvival = Color(0xFFEF4444);
  static const modeSpeed = Color(0xFFF97316);

  // ── Aliases backward-compat (pointent vers le thème dark) ──
  static const darkBg = Color(0xFF111827);
  static const cardBg = Color(0xFF1F2937);
  static const cardBgLight = Color(0xFF374151);
  static const surface = Color(0xFF1F2937);
  static const background = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFFD1D5DB);
  static const textMuted = Color(0xFF6B7280);

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
        _ => const Color(0xFF6B7280),
      };

  static Color modeColor(String mode) => switch (mode) {
        'survival' => modeSurvival,
        'speed' => modeSpeed,
        _ => modeClassic,
      };
}

// ─── Thèmes Material3 ───────────────────────────────────────────────────────

class AppTheme {
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
          onSurface: Color(0xFF111827),
        ),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        cs: AppColorScheme.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Color(0xFF1F2937),
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFF9FAFB),
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

// ─── Supprimé : plus de dégradés dans l'app ─────────────────────────────────
// AppGradients a été retiré. Utiliser AppColors.primary / AppColors.secondary
// comme couleurs pleines à la place.
