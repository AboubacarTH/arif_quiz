import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class XpProgressBar extends StatelessWidget {
  final int level;
  final double percent;
  final int xpProgress;
  final int xpNeeded;

  const XpProgressBar({
    super.key,
    required this.level,
    required this.percent,
    required this.xpProgress,
    required this.xpNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                AppLocalizations.of(context).levelShort(level),
                style: context.type.labelSmall.copyWith(color: Colors.white),
              ),
            ),
            Text(
              '$xpProgress / $xpNeeded XP',
              style: context.type.labelSmall.copyWith(color: context.appColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Stack(
            children: [
              Container(height: 8, color: context.appColors.cardBgLight),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}
