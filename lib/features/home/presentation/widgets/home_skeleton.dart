import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';

/// Mesures partagées entre l'accueil et son squelette.
///
/// Elles vivent ici pour que les deux ne puissent plus diverger : le squelette
/// annonçait une liste VERTICALE de trois cartes là où arrivait un carrousel
/// horizontal, et ignorait quatre blocs de la page. À chaque rafraîchissement,
/// la mise en page se réorganisait entièrement sous les yeux du joueur.
const double kHomeGutter = AppSpacing.gutter;
const double kHomeCategoryRow = 132;
const double kHomeFeaturedRow = 222;
const EdgeInsets kHomeRowPadding = EdgeInsets.fromLTRB(20, 2, 20, 16);

/// Largeur d'une tuile de catégorie et d'une carte « populaire ».
const double kHomeCategoryTile = 96;
const double kHomeFeaturedCard = 220;

/// Le squelette de l'accueil, calqué sur la page réelle : mêmes blocs, mêmes
/// hauteurs, mêmes sens de défilement. Ce qui apparaît pendant le chargement a
/// donc la forme de ce qui va arriver, et le contenu ne fait plus sauter la page.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barre d'XP — mesurée sur la carte réelle, comme les deux suivantes.
        _Block(height: 74, top: 16),
        // Mode Parcours
        _Block(height: 110, top: 14),
        // Défi du jour
        _Block(height: 110, top: 14),

        SizedBox(height: 26),
        _SectionTitleBar(),
        _Row(
          height: kHomeCategoryRow,
          itemWidth: kHomeCategoryTile,
          itemHeight: kHomeCategoryRow - 18,
          count: 5,
        ),

        SizedBox(height: 8),
        _SectionTitleBar(),
        _Row(
          height: kHomeFeaturedRow,
          itemWidth: kHomeFeaturedCard,
          itemHeight: kHomeFeaturedRow - 18,
          count: 3,
        ),
        SizedBox(height: 32),
      ],
    );
  }
}

/// Une carte pleine largeur.
class _Block extends StatelessWidget {
  final double height;
  final double top;

  const _Block({required this.height, required this.top});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(kHomeGutter, top, kHomeGutter, 0),
        child: ShimmerBox(
            width: double.infinity, height: height, radius: AppRadius.lg),
      );
}

/// Le trait d'un titre de section, à sa place et à sa taille.
class _SectionTitleBar extends StatelessWidget {
  const _SectionTitleBar();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(kHomeGutter, 0, kHomeGutter, 14),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ShimmerBox(width: 140, height: 18, radius: AppRadius.xs),
        ),
      );
}

/// Un carrousel horizontal — le sens de défilement compte autant que la taille.
class _Row extends StatelessWidget {
  final double height;
  final double itemWidth;
  final double itemHeight;
  final int count;

  const _Row({
    required this.height,
    required this.itemWidth,
    required this.itemHeight,
    required this.count,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: ListView.separated(
          padding: kHomeRowPadding,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => ShimmerBox(
              width: itemWidth, height: itemHeight, radius: AppRadius.lg),
        ),
      );
}

/// En-tête pendant le chargement.
///
/// L'accueil y appelait `_header(null)`, qui affiche « Bonjour, Invité » et
/// zéro point : le temps d'un rafraîchissement, l'écran annonçait une
/// déconnexion qui n'avait pas eu lieu. On ne montre plus que la place que
/// prendra le texte.
class HomeHeaderSkeleton extends StatelessWidget {
  const HomeHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(kHomeGutter, 20, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 150, height: 15, radius: AppRadius.xs),
                  SizedBox(height: 8),
                  ShimmerBox(width: 220, height: 26, radius: AppRadius.xs),
                ],
              ),
            ),
            SizedBox(width: 8),
            ShimmerBox(width: 78, height: 38, radius: AppRadius.lg),
            SizedBox(width: 10),
            ShimmerBox(width: 44, height: 44, radius: AppRadius.md),
          ],
        ),
      );
}
