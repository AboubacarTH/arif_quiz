import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Rang d'un joueur au classement.
///
/// Le podium etait rendu avec les emoji medailles. Trois problemes : leur
/// dessin change selon l'appareil, ils ignorent la couleur du theme, et sous
/// 20 px on ne distingue plus l'or de l'argent. Un disque plein numerote reste
/// lisible partout et se lit d'un coup jusqu'au rang 999.
class RankBadge extends StatelessWidget {
  final int rank;
  final double size;

  const RankBadge({super.key, required this.rank, this.size = 32});

  bool get _isPodium => rank >= 1 && rank <= 3;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.rankColor(rank);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isPodium ? color : Colors.transparent,
        border: _isPodium
            ? null
            : Border.all(color: context.appColors.border, width: 1.5),
      ),
      child: Text(
        '$rank',
        maxLines: 1,
        style: TextStyle(
          color: _isPodium ? Colors.white : context.appColors.textMuted,
          fontSize: size * 0.44,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
