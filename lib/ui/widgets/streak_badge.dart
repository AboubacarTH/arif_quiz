import 'package:arif_quiz/shared/theme/app_tokens.dart';
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
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: streak > 0
              ? AppColors.warning.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              streak > 0
                  ? Icons.local_fire_department_rounded
                  : Icons.ac_unit_rounded,
              size: size + 4,
              color: streak > 0
                  ? AppColors.warning
                  : context.appColors.textMuted),
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
