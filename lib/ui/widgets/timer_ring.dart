import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TimerRing extends StatelessWidget {
  final int timeLeft;
  final int totalTime;
  final double size;

  const TimerRing({
    super.key,
    required this.timeLeft,
    required this.totalTime,
    this.size = 80,
  });

  Color get _color {
    final ratio = timeLeft / totalTime;
    if (ratio > 0.5) return AppColors.success;
    if (ratio > 0.25) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (timeLeft / totalTime).clamp(0.0, 1.0);
    final color = _color;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: size * 0.09,
              valueColor: AlwaysStoppedAnimation(context.appColors.cardBg),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: AnimatedProgressRing(
              value: ratio,
              color: color,
              strokeWidth: size * 0.09,
            ),
          ),
          // Glow effect
          if (ratio < 0.25)
            Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          // Number
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: color,
              fontSize: size * 0.32,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
            ),
            child: Text('$timeLeft'),
          ),
        ],
      ),
    );
  }
}

class AnimatedProgressRing extends StatefulWidget {
  final double value;
  final Color color;
  final double strokeWidth;

  const AnimatedProgressRing({
    super.key,
    required this.value,
    required this.color,
    required this.strokeWidth,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _from = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween(begin: widget.value, end: widget.value).animate(_ctrl);
  }

  @override
  void didUpdateWidget(AnimatedProgressRing old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _from = old.value;
      _anim = Tween(begin: _from, end: widget.value).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      );
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => CircularProgressIndicator(
          value: _anim.value,
          strokeWidth: widget.strokeWidth,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation(widget.color),
        ),
      );
}
