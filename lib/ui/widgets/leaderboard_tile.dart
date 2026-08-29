import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/rank_badge.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final String? avatar;
  final int points;
  final int quizzesTaken;
  final double accuracy;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    this.avatar,
    required this.points,
    required this.quizzesTaken,
    required this.accuracy,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.12)
            : context.cardElevated,
        borderRadius: AppRadius.rMd,
        border: isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.45), width: 1.5)
            : null,
        boxShadow: isCurrentUser ? null : AppShadows.card(context),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Center(child: RankBadge(rank: rank, size: 30)),
          ),
          const SizedBox(width: 8),

          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: isCurrentUser
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: context.type.titleLarge.copyWith(color: isCurrentUser
                      ? AppColors.primary
                      : context.appColors.textSecondary, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: context.type.titleMedium.copyWith(color: isCurrentUser
                              ? AppColors.primary
                              : context.appColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.xxs),
                        ),
                        child: Text(
                          'You',
                          style: context.type.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$quizzesTaken quizzes · ${accuracy.toStringAsFixed(1)}% accuracy',
                  style:
                      context.type.labelSmall.copyWith(color: context.appColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    '$points',
                    style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Text(AppLocalizations.of(context).points.toLowerCase(),
                  style: context.type.labelSmall.copyWith(color: context.appColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class PodiumDisplay extends StatelessWidget {
  final List<Map<String, dynamic>> top3;

  const PodiumDisplay({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) return const SizedBox.shrink();

    final podiumOrder = [top3[1], top3[0], top3[2]]; // 2nd, 1st, 3rd
    final heights = [90.0, 130.0, 70.0];
    final ranks = [2, 1, 3];
    final colors = [
      AppColors.rankSilver,
      AppColors.rankGold,
      AppColors.rankBronze,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final user = podiumOrder[i];
          final color = colors[i];
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RankBadge(rank: ranks[i], size: ranks[i] == 1 ? 34 : 28),
                const SizedBox(height: 6),
                // Avatar
                Container(
                  width: ranks[i] == 1 ? 56 : 46,
                  height: ranks[i] == 1 ? 56 : 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.25),
                    border: Border.all(color: color, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      (user['name'] as String)[0].toUpperCase(),
                      style: (ranks[i] == 1
                              ? context.type.headlineLarge
                              : context.type.headlineMedium)
                          .copyWith(color: color, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (user['name'] as String).split(' ')[0],
                  style: context.type.labelMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${user['total_points']}pts',
                  style: context.type.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Platform
                Container(
                  height: heights[i],
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${ranks[i]}',
                    style: context.type.headlineLarge.copyWith(color: color),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
