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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
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
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: [
              context.appColors.cardBg,
              context.appColors.cardBgLight,
              context.appColors.cardBg,
            ],
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.cardBg,
          borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) =>
            const ShimmerBox(width: 90, height: 112, radius: 18),
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
