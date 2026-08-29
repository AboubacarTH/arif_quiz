import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    // Battement d'opacité plutôt que balayage de couleur : un squelette de
    // chargement n'a pas besoin d'un dégradé mobile pour dire « ça arrive ».
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: context.appColors.cardBgLight,
          ),
        ),
      ),
    );
  }
}

// Quiz list skeleton
class QuizListSkeleton extends StatelessWidget {
  final int count;
  const QuizListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.appColors.cardBgLight),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 56, height: 56, radius: 14),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 14, radius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(width: 160, height: 11, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category row skeleton
class CategoryRowSkeleton extends StatelessWidget {
  const CategoryRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) =>
            const ShimmerBox(width: 96, height: 116, radius: 18),
      ),
    );
  }
}

// Profile skeleton
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          ShimmerBox(width: double.infinity, height: 200, radius: 24),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: ShimmerBox(
                      width: double.infinity, height: 90, radius: 16)),
              SizedBox(width: 12),
              Expanded(
                  child: ShimmerBox(
                      width: double.infinity, height: 90, radius: 16)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: ShimmerBox(
                      width: double.infinity, height: 90, radius: 16)),
              SizedBox(width: 12),
              Expanded(
                  child: ShimmerBox(
                      width: double.infinity, height: 90, radius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
