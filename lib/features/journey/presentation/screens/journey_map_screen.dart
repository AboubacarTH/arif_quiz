import 'dart:math' as math;

import 'package:arif_quiz/features/journey/bloc/journey_controller.dart';
import 'package:arif_quiz/features/journey/data/journey_repository.dart';
import 'package:arif_quiz/features/journey/presentation/screens/journey_play_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/paywall_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Map du Mode Parcours : un chemin sinueux de niveaux qui se débloquent un à
/// un (façon Candy Crush). Le niveau 1 est en haut ; on descend en progressant.
class JourneyMapScreen extends StatefulWidget {
  const JourneyMapScreen({super.key});

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen> {
  late final JourneyController _ctrl;
  final _scrollCtrl = ScrollController();

  static const double _rowHeight = 116;
  static const double _topPad = 24;
  static const double _nodeSize = 66;
  static const double _bossSize = 82;

  @override
  void initState() {
    super.initState();
    _ctrl = JourneyController(JourneyRepository(apiService));
    _ctrl.addListener(_onChange);
    _ctrl.load();
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    // Recentre sur le niveau courant une fois la map chargée.
    final map = _ctrl.map;
    if (map != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent(map));
    }
  }

  void _scrollToCurrent(JourneyMapModel map) {
    if (!_scrollCtrl.hasClients) return;
    final target = ((map.currentLevel - 1) * _rowHeight - 200)
        .clamp(0.0, _scrollCtrl.position.maxScrollExtent);
    if ((_scrollCtrl.offset - target).abs() > 4) {
      _scrollCtrl.animateTo(target,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChange);
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _play(JourneyLevelModel level) {
    if (!level.unlocked) return;
    void launch() {
      Navigator.push(
        context,
        SlideRightRoute(
            page: JourneyPlayScreen(level: level.level, isBoss: level.isBoss)),
      ).then((_) => _ctrl.refresh());
    }

    monetizationController.requestPlay(
      onGranted: launch,
      onNoAd: () => PaywallSheet.show(
        context,
        ctrl: monetizationController,
        onGranted: launch,
      ),
    );
  }

  // Position horizontale (fraction 0..1) d'un niveau — onde sinusoïdale.
  double _xFraction(int index) => 0.5 + 0.30 * math.sin(index * 0.9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final map = _ctrl.map;
    final totalStars = map == null
        ? 0
        : map.levels.fold<int>(0, (sum, l) => sum + l.stars);
    final maxStars = (map?.levelCount ?? 0) * 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.cardElevated,
                borderRadius: AppRadius.rMd,
                boxShadow: AppShadows.card(context),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: context.appColors.textSecondary, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mode Parcours',
                    style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                if (map != null)
                  Text('Niveau ${map.currentLevel} / ${map.levelCount}',
                      style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 12)),
              ],
            ),
          ),
          if (map != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 5),
                  Text('$totalStars/$maxStars',
                      style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.isLoading || _ctrl.map == null) {
      if (_ctrl.error != null) {
        return ErrorState(message: _ctrl.error!, onRetry: _ctrl.load);
      }
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final map = _ctrl.map!;
    if (map.levels.isEmpty) {
      return const EmptyState(
          title: 'Parcours indisponible',
          subtitle: 'Reviens plus tard',
          emoji: '🗺️');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final canvasHeight =
            _topPad * 2 + map.levels.length * _rowHeight;

        // Centres des nœuds (level 1 en haut).
        final centers = <Offset>[
          for (var i = 0; i < map.levels.length; i++)
            Offset(width * _xFraction(i), _topPad + i * _rowHeight + _rowHeight / 2),
        ];

        return SingleChildScrollView(
          controller: _scrollCtrl,
          child: SizedBox(
            width: width,
            height: canvasHeight,
            child: Stack(
              children: [
                // Chemin reliant les niveaux.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(
                      centers: centers,
                      levels: map.levels,
                      lineColor: context.appColors.border,
                      activeColor: AppColors.primary,
                    ),
                  ),
                ),
                // Nœuds.
                for (var i = 0; i < map.levels.length; i++)
                  _positionedNode(map.levels[i], centers[i]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _positionedNode(JourneyLevelModel level, Offset center) {
    final size = level.isBoss ? _bossSize : _nodeSize;
    // Bloc nœud + étoiles, centré horizontalement, étoiles au-dessus.
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2 - 16,
      child: _LevelNode(
        level: level,
        size: size,
        onTap: () => _play(level),
      ),
    );
  }
}

// ─── Node ────────────────────────────────────────────────────────────────────

class _LevelNode extends StatelessWidget {
  final JourneyLevelModel level;
  final double size;
  final VoidCallback onTap;

  const _LevelNode(
      {required this.level, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = !level.unlocked;
    final completed = level.completed;
    final isCurrent = level.unlocked && !completed;

    final baseColor = level.isBoss ? AppColors.error : AppColors.primary;
    final Color fill;
    final Color fg;
    if (locked) {
      fill = context.appColors.cardBg;
      fg = context.appColors.textMuted;
    } else if (completed) {
      fill = baseColor;
      fg = Colors.white;
    } else {
      fill = baseColor;
      fg = Colors.white;
    }

    Widget node = GestureDetector(
      onTap: locked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Étoiles (niveaux complétés).
          SizedBox(
            height: 16,
            child: completed
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final earned = i < level.stars;
                      return Icon(
                        earned
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: earned
                            ? AppColors.accent
                            : context.appColors.border,
                      );
                    }),
                  )
                : null,
          ),
          const SizedBox(height: 2),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(
                color: locked
                    ? context.appColors.border
                    : Colors.white.withValues(alpha: 0.85),
                width: 3,
              ),
              boxShadow: locked
                  ? null
                  : [
                      BoxShadow(
                        color: fill.withValues(alpha: 0.45),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: Center(child: _nodeContent(context, locked, fg)),
          ),
        ],
      ),
    );

    // Le niveau courant pulse pour attirer l'œil.
    if (isCurrent) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1, end: 1.08, duration: 900.ms, curve: Curves.easeInOut);
    }
    return node;
  }

  Widget _nodeContent(BuildContext context, bool locked, Color fg) {
    if (locked) {
      return Icon(Icons.lock_rounded, color: fg, size: size * 0.34);
    }
    if (level.isBoss) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('👑', style: TextStyle(fontSize: size * 0.30)),
          Text('${level.level}',
              style: TextStyle(
                  color: fg, fontSize: size * 0.22, fontWeight: FontWeight.w800)),
        ],
      );
    }
    return Text('${level.level}',
        style: TextStyle(
            color: fg, fontSize: size * 0.36, fontWeight: FontWeight.w800));
  }
}

// ─── Path painter ────────────────────────────────────────────────────────────

class _PathPainter extends CustomPainter {
  final List<Offset> centers;
  final List<JourneyLevelModel> levels;
  final Color lineColor;
  final Color activeColor;

  _PathPainter({
    required this.centers,
    required this.levels,
    required this.lineColor,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < centers.length - 1; i++) {
      // Un segment est « actif » (coloré) si le niveau de départ est débloqué.
      final active = levels[i].unlocked;
      final paint = Paint()
        ..color = active
            ? activeColor.withValues(alpha: 0.55)
            : lineColor.withValues(alpha: 0.7)
        ..strokeWidth = active ? 6 : 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final a = centers[i];
      final b = centers[i + 1];
      // Courbe douce entre deux nœuds (contrôle au milieu vertical).
      final midY = (a.dy + b.dy) / 2;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.centers != centers || old.levels != levels;
}
