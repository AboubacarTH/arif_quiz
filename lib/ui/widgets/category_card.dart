import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(category.color.replaceFirst('#', 'FF'), radix: 16));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.25) : context.appColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : context.appColors.cardBgLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon ?? '📚', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                category.name,
                style: TextStyle(
                  color: selected ? color : context.appColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(category.color.replaceFirst('#', 'FF'), radix: 16));
    final compact = MediaQuery.sizeOf(context).width < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 88 : 100,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 12 : 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon ?? '📚', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            AutoSizeText(
              category.name,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 12, // 👈 Taille maximale de départ
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // 👈 Reste sur une seule ligne
              minFontSize:
                  10, // 👈 Taille minimale autorisée avant d'afficher les "..."
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${category.quizCount} quiz${category.quizCount != 1 ? 'zes' : ''}',
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
