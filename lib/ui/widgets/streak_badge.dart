import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool large;

  const StreakBadge({super.key, required this.streak, this.large = false});

  @override
  Widget build(BuildContext context) {
    final size = large ? 14.0 : 11.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: streak > 0
            ? AppColors.warning.withValues(alpha: 0.15)
            : context.appColors.cardBgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: streak > 0
              ? AppColors.warning.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(streak > 0 ? '🔥' : '❄️',
              style: TextStyle(fontSize: size + 2)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              color: streak > 0 ? AppColors.warning : context.appColors.textMuted,
              fontSize: size,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
