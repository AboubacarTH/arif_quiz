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
    bg: Color(0xFFFFF7E6), // ivoire (couleur principale)
    cardBg: Color(0xFFFFFFFF), // blanc pur → fait « flotter » les cartes sur l'ivoire
    cardBgLight: Color(0xFFF7EFDD),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFEFE3CC),
    textPrimary: Color(0xFF1C1917), // 16.4:1 sur ivoire → AAA
    textSecondary: Color(0xFF57534E), // 7.2:1 → AAA
    textMuted: Color(0xFF797060), // 4.6:1 → AA
  );

  static const dark = AppColorScheme(
    bg: Color(0xFF14110D), // brun très foncé chaud (déclinaison de la crème)
    cardBg: Color(0xFF221E18),
    cardBgLight: Color(0xFF2E2920),
    surface: Color(0xFF221E18),
    border: Color(0xFF3A342A),
    textPrimary: Color(0xFFFFF7E6), // ivoire sur fond sombre → 17.7:1 (AAA)
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
  // ── Rust (couleur principale) ──
  static const primary = Color(0xFFC2410C); // bouton plein + blanc → 5.2:1 (AA)
  static const primaryLight = Color(0xFFEA580C);
  static const primaryDark = Color(0xFF9A3412); // texte/contour sur ivoire → 6.9:1 (AA)

  // ── Or (accent secondaire) ──
  // Rôle accent (texte/icône) : gold-700 #A16207, lisible sur ivoire (4.6:1, AA).
  // L'or vif #EAB308 (1.8:1 sur ivoire) est réservé aux remplissages avec texte
  // sombre → exposé via secondaryLight/accentLight.
  static const secondary = Color(0xFFA16207);
  static const secondaryLight = Color(0xFFEAB308);
  static const accent = Color(0xFFA16207);
  static const accentLight = Color(0xFFEAB308);

  // ── Status ──
  static const success = Color(0xFF15803D); // vert (distinct du rust)
  static const error = Color(0xFFEF4444); // rouge conservé (clarté sémantique)
  static const warning = Color(0xFFD97706); // ambre (distinct du rouge)
  static const info = Color(0xFF0284C7); // bleu

  // ── Difficulté ──
  static const easy = Color(0xFF15803D); // vert
  static const medium = Color(0xFFA16207); // or
  static const hard = Color(0xFFEF4444); // rouge

  // ── Grades ──
  static const gradeS = Color(0xFFA16207); // or
  static const gradeA = Color(0xFF15803D); // vert
  static const gradeB = Color(0xFF0284C7); // bleu
  static const gradeC = Color(0xFF9333EA); // violet
  static const gradeD = Color(0xFFD97706); // ambre
  static const gradeF = Color(0xFFEF4444); // rouge

  // ── Modes de jeu ──
  static const modeClassic = Color(0xFFC2410C); // rust
  static const modeSurvival = Color(0xFFEF4444); // rouge
  static const modeSpeed = Color(0xFFA16207); // or
  static const modePrecision = Color(0xFF0284C7); // bleu — le seul froid des
  // quatre, pour que le mode qui punit l'erreur ne se confonde avec aucun autre

  // ── Aliases backward-compat (pointent vers le thème dark) ──
  static const darkBg = Color(0xFF14110D);
  static const cardBg = Color(0xFF221E18);
  static const cardBgLight = Color(0xFF2E2920);
  static const surface = Color(0xFF221E18);
  static const background = Color(0xFFFFF7E6);
  static const textPrimary = Color(0xFFFFF7E6);
  static const textSecondary = Color(0xFFC9BCA0);
  static const textMuted = Color(0xFF8A7F68);

  // ── Podium ──
  // Or, argent, bronze : trois valeurs, une seule fois. Elles etaient recopiees
  // dans trois fichiers avec des teintes qui divergeaient d'un ecran a l'autre.
  static const rankGold = Color(0xFFD4A017);
  static const rankSilver = Color(0xFF8E8E93);
  static const rankBronze = Color(0xFFB06A34);

  static Color rankColor(int rank) => switch (rank) {
        1 => rankGold,
        2 => rankSilver,
        3 => rankBronze,
        _ => textMuted,
      };

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
        'precision' => modePrecision,
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
          onPrimary: Colors.white, // sur rust → 5.2:1 (AA)
          onSecondary: Colors.white, // sur gold-700 → 4.9:1 (AA)
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
          onSecondary: Colors.white, // sur gold-700 → 4.9:1 (AA)
          onSurface: Color(0xFFFFF7E6),
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
            fontSize: 19, // headlineMedium

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
              fontSize: 15, // titleMedium
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
        textTheme: _textTheme(cs),
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
          // Sans style explicite, l'onglet héritait du `titleSmall` par défaut
          // de Material (14) : sur un téléphone réglé en grande police, un
          // libellé de trois mots débordait de son tiers d'écran et se faisait
          // trancher. Un cran plus bas et des marges serrées lui laissent la
          // place de grandir.
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      );
}

// ─── Supprimé : plus de dégradés dans l'app ─────────────────────────────────
// AppGradients a été retiré. Utiliser AppColors.primary / AppColors.secondary
// comme couleurs pleines à la place.

// ─── Échelle typographique ──────────────────────────────────────────────────
//
// NEUF tailles, pas une de plus. Avant la refonte, l'app en comptait 29 (dont
// des demi-crans : 11,5 / 12,5 / 13,5 / 14,5) posées à la main dans 594
// `TextStyle` — le `textTheme` n'était appelé qu'une seule fois dans tout le
// projet. C'est ce qui empêchait deux écrans de s'accorder.
//
//   32  displayLarge    écran de résultat, grand titre d'accueil
//   26  displayMedium   titre d'écran héros
//   22  headlineLarge   titre de section fort
//   19  headlineMedium  titre de carte
//   17  titleLarge      titre de liste, entrée de menu
//   15  titleMedium / bodyLarge     sous-titre · texte courant
//   13  bodyMedium / labelLarge     texte secondaire · libellé de bouton
//   12  labelMedium     étiquette, méta
//   11  labelSmall      micro-étiquette, badge, puce
//
// Un écran n'écrit plus `fontSize:`. Il prend un rôle (`context.type.titleLarge`)
// et ne redéfinit que ce qui porte du sens : la couleur, parfois la graisse.
//
// SEULE exception documentée : les chiffres de score des écrans de résultat,
// où le nombre EST l'illustration. Ils passent par `AppType.score` /
// `AppType.scoreHero`, et nulle part ailleurs.

TextTheme _textTheme(AppColorScheme cs) => TextTheme(
      displayLarge: TextStyle(
          color: cs.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          height: 1.05,
          letterSpacing: -0.5),
      displayMedium: TextStyle(
          color: cs.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 26,
          height: 1.1,
          letterSpacing: -0.4),
      headlineLarge: TextStyle(
          color: cs.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          height: 1.15,
          letterSpacing: -0.3),
      headlineMedium: TextStyle(
          color: cs.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 19,
          height: 1.2,
          letterSpacing: -0.2),
      titleLarge: TextStyle(
          color: cs.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          height: 1.25),
      titleMedium: TextStyle(
          color: cs.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          height: 1.3),
      bodyLarge: TextStyle(color: cs.textPrimary, fontSize: 15, height: 1.45),
      bodyMedium: TextStyle(color: cs.textSecondary, fontSize: 13, height: 1.5),
      labelLarge: TextStyle(
          color: cs.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
      labelMedium: TextStyle(
          color: cs.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2),
      labelSmall: TextStyle(
          color: cs.textMuted,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.6),
    );

/// Accès court à l'échelle depuis n'importe quel widget : `context.type.titleLarge`.
///
/// Les rôles sont non-nuls : le thème de l'app les définit tous, et un écran qui
/// tombe sur un `null!` est un bug de thème, pas un cas à gérer.
extension AppTypeExt on BuildContext {
  AppTypeScale get type => AppTypeScale(Theme.of(this).textTheme);
}

class AppTypeScale {
  final TextTheme _t;
  const AppTypeScale(this._t);

  TextStyle get displayLarge => _t.displayLarge!;
  TextStyle get displayMedium => _t.displayMedium!;
  TextStyle get headlineLarge => _t.headlineLarge!;
  TextStyle get headlineMedium => _t.headlineMedium!;
  TextStyle get titleLarge => _t.titleLarge!;
  TextStyle get titleMedium => _t.titleMedium!;
  TextStyle get bodyLarge => _t.bodyLarge!;
  TextStyle get bodyMedium => _t.bodyMedium!;
  TextStyle get labelLarge => _t.labelLarge!;
  TextStyle get labelMedium => _t.labelMedium!;
  TextStyle get labelSmall => _t.labelSmall!;
}

/// Chiffres de score : la seule entorse à l'échelle, réservée aux écrans de
/// résultat où le nombre porte l'écran à lui seul.
abstract final class AppType {
  static const score = TextStyle(
      fontSize: 44,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: -1.5,
      fontFeatures: [FontFeature.tabularFigures()]);

  static const scoreHero = TextStyle(
      fontSize: 64,
      fontWeight: FontWeight.w800,
      height: 0.95,
      letterSpacing: -2.5,
      fontFeatures: [FontFeature.tabularFigures()]);
}
