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

/// Map du Mode Parcours : un sentier d'aventure sinueux de niveaux qui se
/// débloquent un à un (façon Candy Crush), avec fond d'ambiance animé, chemin
/// lumineux où l'énergie circule, nœuds glossy et boss médaillons couronnés.
class JourneyMapScreen extends StatefulWidget {
  /// Contrôleur injectable (tests / prévisualisation). En prod, laissé nul :
  /// l'écran crée le sien et charge la map via l'API.
  final JourneyController? controller;

  const JourneyMapScreen({super.key, this.controller});

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen>
    with SingleTickerProviderStateMixin {
  late final JourneyController _ctrl;
  late final bool _ownsCtrl;
  final _scrollCtrl = ScrollController();
  late final AnimationController _ambient;

  // Éléments décoratifs du fond, générés une fois (positions stables).
  late final List<_Star> _stars;
  late final List<_Orb> _orbs;

  static const double _rowHeight = 132;
  static const double _topPad = 40;
  static const double _bottomPad = 60;
  static const double _nodeSize = 70;
  static const double _bossSize = 92;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final rnd = math.Random(7);
    _stars = List.generate(46, (_) => _Star(
          dx: rnd.nextDouble(),
          dy: rnd.nextDouble(),
          radius: 0.6 + rnd.nextDouble() * 1.8,
          phase: rnd.nextDouble(),
          gold: rnd.nextDouble() > 0.35,
        ));
    _orbs = List.generate(6, (_) => _Orb(
          dx: rnd.nextDouble(),
          dy: rnd.nextDouble(),
          radius: 60 + rnd.nextDouble() * 90,
          phase: rnd.nextDouble(),
          gold: rnd.nextBool(),
        ));

    _ownsCtrl = widget.controller == null;
    _ctrl = widget.controller ?? JourneyController(JourneyRepository(apiService));
    _ctrl.addListener(_onChange);
    if (_ownsCtrl) {
      _ctrl.load();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final map = _ctrl.map;
        if (map != null) _scrollToCurrent(map);
      });
    }
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    final map = _ctrl.map;
    if (map != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent(map));
    }
  }

  void _scrollToCurrent(JourneyMapModel map) {
    if (!_scrollCtrl.hasClients) return;
    final target = ((map.currentLevel - 1) * _rowHeight - 220)
        .clamp(0.0, _scrollCtrl.position.maxScrollExtent);
    if ((_scrollCtrl.offset - target).abs() > 4) {
      _scrollCtrl.animateTo(target,
          duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChange);
    if (_ownsCtrl) _ctrl.dispose();
    _scrollCtrl.dispose();
    _ambient.dispose();
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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: Stack(
        children: [
          // Fond d'ambiance animé (fixe, donne de la profondeur).
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambient,
              builder: (_, __) => CustomPaint(
                painter: _AtmospherePainter(
                  t: _ambient.value,
                  isDark: _isDark,
                  baseBg: context.appColors.bg,
                  stars: _stars,
                  orbs: _orbs,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final map = _ctrl.map;
    final totalStars =
        map == null ? 0 : map.levels.fold<int>(0, (s, l) => s + l.stars);
    final maxStars = (map?.levelCount ?? 0) * 3;
    final progress = maxStars == 0 ? 0.0 : totalStars / maxStars;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardElevated.withValues(alpha: 0.72),
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.appColors.bg.withValues(alpha: 0.6),
                borderRadius: AppRadius.rMd,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: context.appColors.textSecondary, size: 15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🗺️', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('Mode Parcours',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Barre de progression globale.
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(
                          height: 6,
                          color: context.appColors.bg.withValues(alpha: 0.7)),
                      LayoutBuilder(
                        builder: (_, c) => Container(
                          height: 6,
                          width: c.maxWidth * progress,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppColors.secondary,
                              AppColors.secondaryLight,
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.secondary.withValues(alpha: 0.22),
                AppColors.secondaryLight.withValues(alpha: 0.16),
              ]),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.secondaryLight.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.secondaryLight, size: 16),
                const SizedBox(width: 5),
                Text('$totalStars',
                    style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
                Text('/$maxStars',
                    style: TextStyle(
                        color: context.appColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.3, curve: Curves.easeOut);
  }

  // ─── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_ctrl.isLoading || _ctrl.map == null) {
      if (_ctrl.error != null) {
        return ErrorState(message: _ctrl.error!, onRetry: _ctrl.load);
      }
      return const Center(
          child: CircularProgressIndicator(color: AppColors.secondary));
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
            _topPad + map.levels.length * _rowHeight + _bottomPad;

        final centers = <Offset>[
          for (var i = 0; i < map.levels.length; i++)
            Offset(width * _xFraction(i),
                _topPad + i * _rowHeight + _rowHeight / 2),
        ];

        return SingleChildScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: width,
            height: canvasHeight,
            child: Stack(
              children: [
                // Chemin lumineux + énergie qui circule.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _ambient,
                    builder: (_, __) => CustomPaint(
                      painter: _TrailPainter(
                        centers: centers,
                        levels: map.levels,
                        flow: _ambient.value,
                        lockedColor: context.appColors.border,
                      ),
                    ),
                  ),
                ),
                // Nœuds.
                for (var i = 0; i < map.levels.length; i++)
                  _positionedNode(map.levels[i], centers[i], i),
                // Bannière de fin.
                Positioned(
                  top: canvasHeight - _bottomPad + 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text('🏁  ${map.levelCount} niveaux',
                        style: TextStyle(
                            color: context.appColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _positionedNode(JourneyLevelModel level, Offset center, int index) {
    final size = level.isBoss ? _bossSize : _nodeSize;
    // Zone plus large que le disque pour loger halo/étoiles/étiquette.
    const box = 150.0;
    return Positioned(
      left: center.dx - box / 2,
      top: center.dy - box / 2,
      width: box,
      height: box,
      child: Center(
        child: _LevelNode(
          level: level,
          size: size,
          ambient: _ambient,
          onTap: () => _play(level),
        ).animate().fadeIn(
              delay: (index.clamp(0, 14) * 45).ms,
              duration: 350.ms,
            ).scale(
              begin: const Offset(0.4, 0.4),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}

// ─── Node ────────────────────────────────────────────────────────────────────

class _LevelNode extends StatelessWidget {
  final JourneyLevelModel level;
  final double size;
  final Animation<double> ambient;
  final VoidCallback onTap;

  const _LevelNode({
    required this.level,
    required this.size,
    required this.ambient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !level.unlocked;
    final completed = level.completed;
    final isCurrent = level.unlocked && !completed;

    final baseColor = level.isBoss
        ? AppColors.error
        : completed
            ? AppColors.success
            : AppColors.primary;

    return GestureDetector(
      onTap: locked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Halo « sonar » du niveau courant.
            if (isCurrent) _pulseHalo(baseColor),
            // Anneau lumineux rotatif (boss & courant).
            if (isCurrent || level.isBoss)
              _rotatingRing(baseColor, level.isBoss ? size + 22 : size + 14),
            // Disque du nœud.
            _disc(context, baseColor, locked),
            // Étoiles au-dessus (niveaux complétés).
            if (completed)
              Positioned(
                top: 150 / 2 - size / 2 - 20,
                left: 0,
                right: 0,
                child: Center(child: _StarsArc(stars: level.stars)),
              ),
            // Étiquette « JOUER » sous le niveau courant.
            if (isCurrent)
              Positioned(
                top: 150 / 2 + size / 2 + 6,
                left: 0,
                right: 0,
                child: Center(child: _playPill()),
              ),
            // Couronne au-dessus des boss non encore terminés.
            if (level.isBoss && !completed)
              Positioned(
                top: 150 / 2 - size / 2 - 18,
                left: 0,
                right: 0,
                child: Center(
                  child: const Text('👑', style: TextStyle(fontSize: 22))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: 0, end: -3, duration: 1100.ms, curve: Curves.easeInOut),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _disc(BuildContext context, Color color, bool locked) {
    final Widget disc = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: locked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.appColors.cardBgLight,
                  context.appColors.cardBg,
                ],
              )
            : RadialGradient(
                center: const Alignment(-0.35, -0.4),
                radius: 1.1,
                colors: [
                  Color.lerp(color, Colors.white, 0.45)!,
                  color,
                  Color.lerp(color, Colors.black, 0.28)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
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
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Center(child: _content(context, locked)),
    );

    if (locked) return disc;

    // Reflet « verre » en haut du disque.
    return Stack(
      alignment: Alignment.center,
      children: [
        disc,
        Align(
          alignment: const Alignment(0, -0.5),
          child: Container(
            width: size * 0.5,
            height: size * 0.28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, bool locked) {
    if (locked) {
      return Icon(Icons.lock_rounded,
          color: context.appColors.textMuted, size: size * 0.34);
    }
    return Text(
      '${level.level}',
      style: TextStyle(
        color: Colors.white,
        fontSize: size * (level.isBoss ? 0.32 : 0.38),
        fontWeight: FontWeight.w900,
        shadows: const [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))],
      ),
    );
  }

  Widget _pulseHalo(Color color) {
    Widget ring(int delayMs) => Container(
          width: size + 8,
          height: size + 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.55), width: 3),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scaleXY(begin: 0.85, end: 1.7, duration: 1800.ms, delay: delayMs.ms, curve: Curves.easeOut)
            .fade(begin: 0.6, end: 0.0, duration: 1800.ms, delay: delayMs.ms);
    return Stack(alignment: Alignment.center, children: [ring(0), ring(900)]);
  }

  Widget _rotatingRing(Color color, double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            color.withValues(alpha: 0.0),
            color.withValues(alpha: 0.0),
            AppColors.secondaryLight.withValues(alpha: 0.9),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 0.78, 1.0],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .rotate(duration: level.isBoss ? 3600.ms : 5200.ms);
  }

  Widget _playPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryLight]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.secondaryLight.withValues(alpha: 0.5),
              blurRadius: 12),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
          SizedBox(width: 2),
          Text('JOUER',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: 4, duration: 900.ms, curve: Curves.easeInOut);
  }
}

// ─── Étoiles arquées (niveaux complétés) ─────────────────────────────────────

class _StarsArc extends StatelessWidget {
  final int stars;
  const _StarsArc({required this.stars});

  @override
  Widget build(BuildContext context) {
    Widget star(int i) {
      final earned = i < stars;
      final s = Icon(
        earned ? Icons.star_rounded : Icons.star_outline_rounded,
        size: i == 1 ? 22 : 18,
        color:
            earned ? AppColors.secondaryLight : context.appColors.textMuted,
        shadows: earned
            ? [BoxShadow(color: AppColors.secondaryLight.withValues(alpha: 0.8), blurRadius: 8)]
            : null,
      );
      if (!earned) return Padding(padding: EdgeInsets.only(top: i == 1 ? 0 : 6), child: s);
      return Padding(
        padding: EdgeInsets.only(top: i == 1 ? 0 : 6),
        child: s
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.9, end: 1.12, duration: 1200.ms, delay: (i * 200).ms, curve: Curves.easeInOut),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [star(0), const SizedBox(width: 2), star(1), const SizedBox(width: 2), star(2)],
    );
  }
}

// ─── Peintre du chemin ───────────────────────────────────────────────────────

class _TrailPainter extends CustomPainter {
  final List<Offset> centers;
  final List<JourneyLevelModel> levels;
  final double flow;
  final Color lockedColor;

  _TrailPainter({
    required this.centers,
    required this.levels,
    required this.flow,
    required this.lockedColor,
  });

  Path _buildPath(int from, int to) {
    final path = Path()..moveTo(centers[from].dx, centers[from].dy);
    for (var i = from; i < to; i++) {
      final a = centers[i];
      final b = centers[i + 1];
      final midY = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final full = _buildPath(0, centers.length - 1);

    // 1) Base : trait sombre large et flou (ombre du sentier).
    canvas.drawPath(
      full,
      Paint()
        ..color = lockedColor.withValues(alpha: 0.6)
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // 2) Base : trait plein pointillé (dalles du sentier).
    canvas.drawPath(
      full,
      Paint()
        ..color = lockedColor
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Portion débloquée = préfixe contigu.
    var lastUnlocked = -1;
    for (var i = 0; i < levels.length; i++) {
      if (levels[i].unlocked) {
        lastUnlocked = i;
      } else {
        break;
      }
    }
    if (lastUnlocked < 1) return;

    final activePath = _buildPath(0, lastUnlocked);

    // 3) Glow doré du sentier débloqué.
    canvas.drawPath(
      activePath,
      Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.55)
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    // 4) Trait doré vif.
    canvas.drawPath(
      activePath,
      Paint()
        ..color = AppColors.secondaryLight
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // 5) Énergie qui circule : points lumineux le long du sentier débloqué.
    for (final metric in activePath.computeMetrics()) {
      const spacing = 46.0;
      final count = (metric.length / spacing).floor();
      for (var k = 0; k <= count; k++) {
        final d = ((k + flow) * spacing) % metric.length;
        final tan = metric.getTangentForOffset(d);
        if (tan == null) continue;
        canvas.drawCircle(
          tan.position,
          3.2,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.9)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) =>
      old.flow != flow || old.centers != centers || old.levels != levels;
}

// ─── Peintre du fond d'ambiance ──────────────────────────────────────────────

class _Star {
  final double dx, dy, radius, phase;
  final bool gold;
  _Star({required this.dx, required this.dy, required this.radius, required this.phase, required this.gold});
}

class _Orb {
  final double dx, dy, radius, phase;
  final bool gold;
  _Orb({required this.dx, required this.dy, required this.radius, required this.phase, required this.gold});
}

class _AtmospherePainter extends CustomPainter {
  final double t; // 0..1
  final bool isDark;
  final Color baseBg;
  final List<_Star> stars;
  final List<_Orb> orbs;

  _AtmospherePainter({
    required this.t,
    required this.isDark,
    required this.baseBg,
    required this.stars,
    required this.orbs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final twinkle = 2 * math.pi * t;

    // Dégradé chaud vertical.
    final top = isDark
        ? Color.lerp(baseBg, Colors.black, 0.35)!
        : Color.lerp(baseBg, const Color(0xFFF3D9A6), 0.5)!;
    final bottom = isDark
        ? Color.lerp(baseBg, AppColors.primaryDark, 0.18)!
        : baseBg;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, baseBg, bottom],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // Orbes flous dorés/rust qui respirent et dérivent lentement.
    for (final o in orbs) {
      final drift = math.sin(twinkle + o.phase * 6.28) * 18;
      final center = Offset(o.dx * size.width, o.dy * size.height + drift);
      final pulse = 0.5 + 0.5 * math.sin(twinkle + o.phase * 6.28);
      final color = (o.gold ? AppColors.secondary : AppColors.primary)
          .withValues(alpha: (isDark ? 0.10 : 0.08) * (0.6 + pulse * 0.4));
      canvas.drawCircle(
        center,
        o.radius,
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, o.radius * 0.6),
      );
    }

    // Étoiles / poussières scintillantes.
    for (final s in stars) {
      final tw = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(twinkle + s.phase * 6.28));
      final color = (s.gold ? AppColors.secondaryLight : Colors.white)
          .withValues(alpha: (isDark ? 0.9 : 0.5) * tw);
      canvas.drawCircle(
        Offset(s.dx * size.width, s.dy * size.height),
        s.radius,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) =>
      old.t != t || old.isDark != isDark || old.baseBg != baseBg;
}
