import 'package:flutter/material.dart';

import 'app_theme.dart';

/// ─── Design tokens premium « Soft depth » ───────────────────────────────────
///
/// Source unique de vérité pour les espacements, rayons et ombres.
/// La profondeur vient des ombres douces + du contraste de surface,
/// **jamais** d'un dégradé.

/// Grille 4 / 8 pt.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Marge horizontale d'un écran. Elle valait 16 sur certains écrans et 20 sur
  /// d'autres : en passant de l'accueil aux catégories, tout le contenu se
  /// décalait de 4 px. C'est le genre d'écart qu'on ne nomme pas mais qu'on voit.
  static const double gutter = 20;

  /// Respiration entre l'énoncé d'une question et ses choix, en jeu.
  /// Les réponses suivent l'énoncé (elles ne sont plus ancrées en bas) : cet
  /// écart doit rester assez large pour séparer nettement les deux blocs.
  static const double questionToAnswers = 28;
}

/// Rayons de coins cohérents.
abstract final class AppRadius {
  // Sept crans, du liseré à la pilule. Les écrans en utilisaient 14 valeurs
  // différentes posées à la main (2, 4, 6, 8, 10, 12, 13, 14, 15, 16, 18, 20,
  // 28, 999) : deux cartes voisines n'avaient pas le même arrondi.
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double pill = 999;

  static BorderRadius get rXxs => BorderRadius.circular(xxs);
  static BorderRadius get rXs => BorderRadius.circular(xs);
  static BorderRadius get rSm => BorderRadius.circular(sm);
  static BorderRadius get rMd => BorderRadius.circular(md);
  static BorderRadius get rLg => BorderRadius.circular(lg);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rPill => BorderRadius.circular(pill);
}

/// Ombres douces et diffuses — le cœur du rendu « soft depth ».
///
/// En thème clair, les cartes blanches « flottent » au-dessus du fond gris
/// clair grâce à des ombres très peu opaques mais largement floutées.
/// En thème sombre, on évite les halos : ombre noire discrète + l'élévation
/// de surface (`cardElevated`) porte la profondeur.
abstract final class AppShadows {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Ombre de carte standard.
  static List<BoxShadow> card(BuildContext context) {
    if (_isDark(context)) {
      return const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x0F111827), // ~6 %
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x0A111827), // ~4 %
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ];
  }

  /// Ombre plus marquée (carte active / mise en avant).
  static List<BoxShadow> floating(BuildContext context) {
    if (_isDark(context)) {
      return const [
        BoxShadow(
          color: Color(0x59000000),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x1A111827), // ~10 %
        blurRadius: 28,
        offset: Offset(0, 12),
      ),
      BoxShadow(
        color: Color(0x0D111827),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ];
  }

  /// Ombre de barre de navigation (projetée vers le haut).
  static List<BoxShadow> bottomBar(BuildContext context) {
    if (_isDark(context)) {
      return const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 20,
          offset: Offset(0, -4),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x12111827),
        blurRadius: 24,
        offset: Offset(0, -6),
      ),
    ];
  }

  // Il y avait ici un `tinted(context, color)` : une ombre de la COULEUR de
  // l'élément, floue sur 22 pixels. Sur une carte sélectionnée elle donnait une
  // auréole qui bavait tout autour du cadre — une tache de couleur, pas une
  // ombre. Une surface accentuée se marque par son cadre et son fond ; la
  // profondeur reste neutre, comme partout ailleurs.
}

/// Surface de carte « surélevée » : en sombre on relève la luminosité,
/// en clair on garde le blanc pur pour maximiser le contraste avec le fond.
///
/// Cette valeur était figée à `#232F3E`, un bleu ardoise hérité d'une palette
/// précédente. Toutes les cartes du thème sombre tiraient donc vers le bleu,
/// dans une application dont la palette est chaude — c'était le décalage le
/// plus visible de l'app. Elle prend maintenant le cran chaud que la palette
/// définit déjà pour ça.
extension AppSurfaceExt on BuildContext {
  Color get cardElevated => Theme.of(this).brightness == Brightness.dark
      ? appColors.cardBgLight // brun chaud, un cran au-dessus du fond
      : appColors.cardBg; // blanc pur : contraste maximal sur l'ivoire
}
