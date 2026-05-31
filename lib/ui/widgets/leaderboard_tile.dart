import 'package:arif_quiz/shared/theme/app_theme.dart';
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

  Color get _rankColor => switch (rank) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFAEB0B5),
        3 => const Color(0xFFCD7F32),
        _ => AppColors.textMuted,
      };

  String get _rankEmoji => switch (rank) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => '#$rank',
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.15)
            : context.appColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.4)
              : context.appColors.cardBgLight,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: rank <= 3
                ? Text(_rankEmoji,
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center)
                : Text(
                    _rankEmoji,
                    style: TextStyle(
                      color: _rankColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                style: TextStyle(
                  color: isCurrentUser
                      ? AppColors.primary
                      : context.appColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
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
                        style: TextStyle(
                          color: isCurrentUser
                              ? AppColors.primary
                              : context.appColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$quizzesTaken quizzes · ${accuracy.toStringAsFixed(1)}% accuracy',
                  style:
                      TextStyle(color: context.appColors.textMuted, fontSize: 11),
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
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Text('points',
                  style: TextStyle(color: context.appColors.textMuted, fontSize: 10)),
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
      const Color(0xFFAEB0B5),
      const Color(0xFFFFD700),
      const Color(0xFFCD7F32),
    ];
    final medals = ['🥈', '🥇', '🥉'];

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
                Text(medals[i], style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
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
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: ranks[i] == 1 ? 24 : 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (user['name'] as String).split(' ')[0],
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${user['total_points']}pts',
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w700),
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
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
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
