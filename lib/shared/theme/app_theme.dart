import 'package:flutter/material.dart';

import 'app_tokens.dart';

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
    bg: Color(0xFFF6F7F9), // gris très clair → fait « flotter » les cartes blanches
    cardBg: Color(0xFFFFFFFF),
    cardBgLight: Color(0xFFEFF1F4),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFEAECEF),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textMuted: Color(0xFF94A3B8),
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
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.22),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxxl, vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
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
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl, vertical: AppSpacing.md + 2),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cs.surface,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          border: OutlineInputBorder(
            borderRadius: AppRadius.rMd,
            borderSide: BorderSide(color: cs.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.rMd,
            borderSide: BorderSide(color: cs.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.rMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: cs.textSecondary),
          hintStyle: TextStyle(color: cs.textMuted),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              color: cs.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              height: 1.1,
              letterSpacing: -0.5),
          displayMedium: TextStyle(
              color: cs.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1.1,
              letterSpacing: -0.4),
          headlineLarge: TextStyle(
              color: cs.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 24,
              height: 1.15,
              letterSpacing: -0.3),
          headlineMedium: TextStyle(
              color: cs.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.2,
              letterSpacing: -0.2),
          titleLarge: TextStyle(
              color: cs.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              height: 1.25),
          titleMedium: TextStyle(
              color: cs.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
          bodyLarge: TextStyle(color: cs.textPrimary, fontSize: 15, height: 1.4),
          bodyMedium:
              TextStyle(color: cs.textSecondary, fontSize: 13, height: 1.45),
          labelLarge: TextStyle(
              color: cs.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
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
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rSm),
        ),
        listTileTheme: ListTileThemeData(
          tileColor: Colors.transparent,
          textColor: cs.textPrimary,
          iconColor: cs.textSecondary,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: cs.cardBg,
          contentTextStyle: TextStyle(color: cs.textPrimary),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: cs.cardBg,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
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
