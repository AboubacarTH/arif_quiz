import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Draws subtle blob shapes for screen backgrounds
class BlobPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const BlobPainter({this.color = AppColors.primary, this.opacity = 0.06});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: opacity);

    // Top-right blob
    final path1 = Path()
      ..moveTo(size.width * 0.6, 0)
      ..cubicTo(
        size.width * 1.1,
        0,
        size.width * 1.1,
        size.height * 0.4,
        size.width * 0.75,
        size.height * 0.3,
      )
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width * 0.4,
        0,
        size.width * 0.6,
        0,
      )
      ..close();
    canvas.drawPath(path1, paint);

    // Bottom-left blob
    final paint2 = Paint()
      ..color = AppColors.accent.withValues(alpha: opacity * 0.7);
    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        -size.width * 0.15,
        size.height * 0.6,
        size.width * 0.2,
        size.height * 0.5,
        size.width * 0.25,
        size.height * 0.7,
      )
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.9,
        0,
        size.height,
        0,
        size.height * 0.75,
      )
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(BlobPainter old) => false;
}

/// Draws a grid dot pattern
class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  const DotGridPainter({
    this.color = AppColors.cardBgLight,
    this.spacing = 24,
    this.radius = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) => false;
}

/// Score arc painter for results screen
class ScoreArcPainter extends CustomPainter {
  final double score; // 0.0 to 1.0
  final Color color;
  final double strokeWidth;

  const ScoreArcPainter({
    required this.score,
    required this.color,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.cardBgLight
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.35, // ~135deg from bottom-left
      5.65, // 324deg sweep
      false,
      bgPaint,
    );

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = strokeWidth * 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweep = 5.65 * score;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.35,
      sweep,
      false,
      glowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.35,
      sweep,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(ScoreArcPainter old) =>
      old.score != score || old.color != color;
}

// Wrapper widget for BlobPainter
class BlobBackground extends StatelessWidget {
  final Widget child;
  final Color color;

  const BlobBackground(
      {super.key, required this.child, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlobPainter(color: color),
      child: child,
    );
  }
}
