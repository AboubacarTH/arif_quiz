import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// ─── Régions de la map du parcours ──────────────────────────────────────────
///
/// La map n'est plus une sinusoïde calculée au-dessus d'un fond peint à la
/// volée : c'est une pile de **bandes illustrées**, chacune portant cinq points
/// d'ancrage dessinés à des coordonnées fixes. Un niveau ne choisit pas sa
/// position, il tombe sur l'ancre que son numéro désigne :
///
///   r      = (n − 1) ÷ ancresParRégion
///   région = r mod (nombre de régions)
///   tour   = r ÷ (nombre de régions)
///
/// Le parcours est évolutif et n'a donc pas de plafond. Quand les niveaux
/// dépassent le nombre de régions livrées, la série reboucle — mais pas à
/// l'identique : chaque tour applique une **ambiance** différente à la même
/// illustration. Six régions × quatre ambiances = 24 bandes distinctes, soit
/// 120 niveaux avant le moindre vrai doublon, sans dessiner une image de plus.

/// Nombre de niveaux portés par une bande.
const int kAnchorsPerRegion = 5;

/// Le décor d'une bande. `artLight`/`artDark` restent nuls tant qu'aucune
/// illustration peinte n'a été fournie : la bande est alors dessinée en
/// vectoriel par [RegionPainter]. Déposer deux images et renseigner leurs
/// chemins ici suffit à les remplacer — aucun autre code ne bouge.
@immutable
class JourneyRegion {
  final String id;
  final RegionScenery scenery;

  /// Cinq ancres en coordonnées normalisées (0..1), rangées **du bas vers le
  /// haut** : c'est le sens dans lequel le joueur gravit la map.
  final List<Offset> anchors;

  final String? artLight;
  final String? artDark;

  const JourneyRegion({
    required this.id,
    required this.scenery,
    required this.anchors,
    this.artLight,
    this.artDark,
  });
}

/// Le motif dessiné par le peintre vectoriel de repli.
enum RegionScenery { library, temple, observatory, scriptorium, amphitheatre, garden }

/// Les ancres sont identiques d'une région à l'autre : c'est ce qui donne au
/// sentier un rythme régulier quand les bandes s'empilent. Le décor de chaque
/// région est composé autour d'elles, pas l'inverse.
const List<Offset> _kAnchors = [
  Offset(0.50, 0.88),
  Offset(0.74, 0.69),
  Offset(0.79, 0.50),
  Offset(0.63, 0.31),
  Offset(0.37, 0.12),
];

abstract final class JourneyRegions {
  static const List<JourneyRegion> all = [
    JourneyRegion(
        id: 'bibliotheque', scenery: RegionScenery.library, anchors: _kAnchors),
    JourneyRegion(
        id: 'temple', scenery: RegionScenery.temple, anchors: _kAnchors),
    JourneyRegion(
        id: 'observatoire',
        scenery: RegionScenery.observatory,
        anchors: _kAnchors),
    JourneyRegion(
        id: 'scriptorium',
        scenery: RegionScenery.scriptorium,
        anchors: _kAnchors),
    JourneyRegion(
        id: 'amphitheatre',
        scenery: RegionScenery.amphitheatre,
        anchors: _kAnchors),
    JourneyRegion(
        id: 'jardin', scenery: RegionScenery.garden, anchors: _kAnchors),
  ];

  static int get count => all.length;

  /// Nombre de bandes necessaires pour porter [levelCount] niveaux.
  static int bandsFor(int levelCount) =>
      (levelCount / kAnchorsPerRegion).ceil().clamp(1, 1 << 20);

  /// La région d'une bande, en rebouclant sur la série.
  static JourneyRegion regionForBand(int band) => all[band % all.length];

  /// Le tour d'une bande : il ne change pas le décor, seulement sa lumière.
  static int tourForBand(int band) => band ~/ all.length;
}

/// ─── Ambiances ──────────────────────────────────────────────────────────────
///
/// Quatre lumières posées sur le même décor. Le décor reste reconnaissable, la
/// lumière ne l'est pas : c'est ce qui empêche la boucle de se lire comme une
/// répétition subie.
enum JourneyAmbience {
  dawn,
  day,
  dusk,
  night;

  static JourneyAmbience forTour(int tour) =>
      JourneyAmbience.values[tour % JourneyAmbience.values.length];

  /// Les quatre teintes d'une bande, déclinées par thème. Toutes sortent de la
  /// palette de l'app — aucune couleur inventée pour la map.
  RegionPalette palette(bool isDark) => switch (this) {
        JourneyAmbience.dawn => RegionPalette(
            sky: isDark ? const Color(0xFF241A12) : const Color(0xFFFBEBD0),
            ground: isDark ? const Color(0xFF2E2117) : const Color(0xFFF2DFBE),
            landmark: isDark ? const Color(0xFF4A3524) : const Color(0xFFE3C79A),
            detail: AppColors.secondary,
          ),
        JourneyAmbience.day => RegionPalette(
            sky: isDark ? const Color(0xFF1E1A14) : const Color(0xFFFFF7E6),
            ground: isDark ? const Color(0xFF2A251C) : const Color(0xFFF7EFDD),
            landmark: isDark ? const Color(0xFF443C2E) : const Color(0xFFE8DCC2),
            detail: AppColors.primary,
          ),
        JourneyAmbience.dusk => RegionPalette(
            sky: isDark ? const Color(0xFF261510) : const Color(0xFFF6DFC9),
            ground: isDark ? const Color(0xFF321C14) : const Color(0xFFEBCFB4),
            landmark: isDark ? const Color(0xFF52301F) : const Color(0xFFDDB894),
            detail: AppColors.primaryLight,
          ),
        JourneyAmbience.night => RegionPalette(
            sky: isDark ? const Color(0xFF14110D) : const Color(0xFF3B3226),
            ground: isDark ? const Color(0xFF1E1A14) : const Color(0xFF4A4032),
            landmark: isDark ? const Color(0xFF35301F) : const Color(0xFF61553F),
            detail: AppColors.secondaryLight,
          ),
      };

  /// Une nuit se signale par un ciel étoilé — le seul ornement du décor.
  bool get hasStars => this == JourneyAmbience.night;
}

@immutable
class RegionPalette {
  final Color sky;
  final Color ground;
  final Color landmark;
  final Color detail;

  const RegionPalette({
    required this.sky,
    required this.ground,
    required this.landmark,
    required this.detail,
  });
}
