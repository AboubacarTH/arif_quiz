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
    bg: Color(0xFFF5E6CA), // crème (couleur principale)
    cardBg: Color(0xFFFFFDF8), // blanc cassé chaud → fait « flotter » les cartes
    cardBgLight: Color(0xFFEFE2C8),
    surface: Color(0xFFFFFDF8),
    border: Color(0xFFE3D5B8),
    textPrimary: Color(0xFF1C1917), // 14.2:1 sur crème → AAA
    textSecondary: Color(0xFF5C5648), // 5.9:1 → AA
    textMuted: Color(0xFF6B6452), // 4.8:1 → AA
  );

  static const dark = AppColorScheme(
    bg: Color(0xFF14110D), // brun très foncé chaud (déclinaison de la crème)
    cardBg: Color(0xFF221E18),
    cardBgLight: Color(0xFF2E2920),
    surface: Color(0xFF221E18),
    border: Color(0xFF3A342A),
    textPrimary: Color(0xFFF5E6CA), // crème sur fond sombre → 15.3:1 (AAA)
    textSecondary: Color(0xFFC9BCA0), // 10.0:1 (AAA)
    textMuted: Color(0xFF8A7F68), // 4.8:1 (AA)
  );

  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension AppColorSchemeExt on BuildContext {
  AppColorScheme get appColors => AppColorScheme.of(this);
}

// ─── Couleurs partagées (identiques dark & light) ───────────────────────────

class AppColors {
  // ── Teal (couleur principale) ──
  static const primary = Color(0xFF0F766E); // bouton plein + blanc → 5.5:1 (AA)
  static const primaryLight = Color(0xFF14B8A6);
  static const primaryDark = Color(0xFF115E59); // texte/contour sur crème → 6.2:1 (AA)

  // ── Corail (accent secondaire) ──
  // ⚠️ trop clair pour porter du texte blanc (2.5:1) ou servir de texte sur
  // crème (2.0:1) → à utiliser en remplissage avec texte sombre (onSecondary).
  static const secondary = Color(0xFFFF7F50);
  static const secondaryLight = Color(0xFFFF9D77);
  static const accent = Color(0xFFFF7F50);
  static const accentLight = Color(0xFFFF9D77);

  // ── Status ──
  static const success = Color(0xFF0F766E); // teal = succès (aligné primaire)
  static const error = Color(0xFFEF4444); // rouge conservé (clarté sémantique)
  static const warning = Color(0xFFD97706); // ambre (distinct du coral et du rouge)
  static const info = Color(0xFF0F766E);

  // ── Difficulté ──
  static const easy = Color(0xFF0F766E); // teal
  static const medium = Color(0xFFFF7F50); // coral
  static const hard = Color(0xFFEF4444); // rouge

  // ── Grades ──
  static const gradeS = Color(0xFFFF7F50); // coral
  static const gradeA = Color(0xFF0F766E); // teal
  static const gradeB = Color(0xFF14B8A6); // teal clair
  static const gradeC = Color(0xFFD97706); // ambre
  static const gradeD = Color(0xFFF59E0B);
  static const gradeF = Color(0xFFEF4444);

  // ── Modes de jeu ──
  static const modeClassic = Color(0xFF0F766E); // teal
  static const modeSurvival = Color(0xFFEF4444); // rouge
  static const modeSpeed = Color(0xFFFF7F50); // coral

  // ── Aliases backward-compat (pointent vers le thème dark) ──
  static const darkBg = Color(0xFF14110D);
  static const cardBg = Color(0xFF221E18);
  static const cardBgLight = Color(0xFF2E2920);
  static const surface = Color(0xFF221E18);
  static const background = Color(0xFFF5E6CA);
  static const textPrimary = Color(0xFFF5E6CA);
  static const textSecondary = Color(0xFFC9BCA0);
  static const textMuted = Color(0xFF8A7F68);

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
          surface: Color(0xFFFFFDF8),
          error: AppColors.error,
          onPrimary: Colors.white, // sur teal → 5.5:1 (AA)
          onSecondary: Color(0xFF1C1917), // sur coral → 7.1:1 (AAA), blanc échoue
          onSurface: Color(0xFF1C1917),
        ),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        cs: AppColorScheme.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Color(0xFF221E18),
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Color(0xFF1C1917), // sur coral → texte sombre, blanc échoue
          onSurface: Color(0xFFF5E6CA),
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
            foregroundColor: AppColors.primaryDark, // texte teal foncé → 6.2:1 (AA)
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
