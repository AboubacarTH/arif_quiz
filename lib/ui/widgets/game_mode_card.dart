import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameModeCard extends StatelessWidget {
  final GameMode mode;
  final bool selected;
  final VoidCallback onTap;

  const GameModeCard({
    super.key,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  Color get _modeColor => switch (mode) {
        GameMode.classic => AppColors.primary,
        GameMode.survival => AppColors.error,
        GameMode.speed => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? _modeColor.withValues(alpha: 0.15)
              : context.appColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _modeColor : const Color(0xFF2A2A4A),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _modeColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _modeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(mode.icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _modeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mode.label,
              style: TextStyle(
                color: selected ? _modeColor : context.appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode.description,
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (mode.index * 80).ms).slideY(begin: 0.2);
  }
}
