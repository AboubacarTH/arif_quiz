import 'package:arif_quiz/core/monetization/play_gate.dart';
import 'package:arif_quiz/features/journey/bloc/journey_controller.dart';
import 'package:arif_quiz/features/journey/data/journey_repository.dart';
import 'package:arif_quiz/features/journey/presentation/map/journey_region.dart';
import 'package:arif_quiz/features/journey/presentation/map/region_painter.dart';
import 'package:arif_quiz/features/journey/presentation/screens/journey_play_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Map du Mode Parcours : une carte illustrée que le joueur gravit du bas vers
/// le haut.
///
/// Elle était auparavant entièrement calculée — les niveaux posés sur une
/// sinusoïde au-dessus d'un fond peint à la volée (étoiles scintillantes,
/// orbes flous, dégradé vertical, anneaux rotatifs, halos pulsants). C'est
/// maintenant une pile de **bandes illustrées** portant des points d'ancrage
/// dessinés : un niveau ne choisit pas sa position, il tombe sur l'ancre que
/// son numéro désigne. Voir [JourneyRegions] pour le mécanisme et les tours.
class JourneyMapScreen extends StatefulWidget {
  /// Contrôleur injectable (tests / prévisualisation). En prod, laissé nul :
  /// l'écran crée le sien et charge la map via l'API.
  final JourneyController? controller;

  const JourneyMapScreen({super.key, this.controller});

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen> {
  late final JourneyController _ctrl;
  late final bool _ownsCtrl;
  final _scrollCtrl = ScrollController();

  /// Décalage du plan des décors, alimenté par le défilement. C'est toute la
  /// parallaxe : le décor avance moins vite que le sentier, ce qui donne la
  /// sensation de carte sans la moindre animation en boucle.
  double _parallax = 0;

  /// Hauteur d'une bande. Cinq niveaux y tiennent, soit 132 px par niveau — le
  /// pas de l'ancienne map, conservé pour ne pas dérégler le défilement.
  static const double _bandHeight = kAnchorsPerRegion * 132.0;
  static const double _nodeSize = 66;
  static const double _bossSize = 84;
  static const double _nodeBox = 132;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);

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

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    // Le décor suit à 88 % du sentier : le complément est ce qu'on lui rend.
    final next = _scrollCtrl.offset * 0.12;
    if ((next - _parallax).abs() > 0.5) setState(() => _parallax = next);
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    final map = _ctrl.map;
    if (map != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent(map));
    }
  }

  /// Amène le niveau courant sous les yeux du joueur.
  ///
  /// La vue est en `reverse: true` : l'offset 0 est le PIED de la map
  /// (niveau 1) et grandit à mesure qu'on monte.
  void _scrollToCurrent(JourneyMapModel map) {
    if (!_scrollCtrl.hasClients || map.levels.isEmpty) return;
    final index = (map.currentLevel - 1).clamp(0, map.levels.length - 1);
    final target = (_distanceFromBottom(index) - 220)
        .clamp(0.0, _scrollCtrl.position.maxScrollExtent);
    if ((_scrollCtrl.offset - target).abs() > 4) {
      _scrollCtrl.animateTo(target,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic);
    }
  }

  /// Distance entre le pied de la map et le nœud d'index [index].
  double _distanceFromBottom(int index) {
    final band = index ~/ kAnchorsPerRegion;
    final anchor =
        JourneyRegions.regionForBand(band).anchors[index % kAnchorsPerRegion];
    return band * _bandHeight + (1 - anchor.dy) * _bandHeight;
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChange);
    if (_ownsCtrl) _ctrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _play(JourneyLevelModel level) {
    if (!level.unlocked) return;
    void launch() {
      Navigator.push(
        context,
        SlideRightRoute(
          page: JourneyPlayScreen(
            levelId: level.id,
            levelNumber: level.level,
            title: level.title,
            isBoss: level.isBoss,
          ),
        ),
      ).then((_) => _ctrl.refresh());
    }

    PlayGate.requestPlay(context, onGranted: launch);
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

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

  // ─── En-tête ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final map = _ctrl.map;
    final totalStars =
        map == null ? 0 : map.levels.fold<int>(0, (s, l) => s + l.stars);
    final maxStars = (map?.levelCount ?? 0) * 3;
    final progress = maxStars == 0 ? 0.0 : totalStars / maxStars;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm + 2, AppSpacing.lg, AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).journeyMapTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.titleMedium,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: AppRadius.rXxs,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: context.appColors.bg,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.14),
              borderRadius: AppRadius.rPill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.secondary, size: 16),
                const SizedBox(width: 5),
                Text('$totalStars', style: context.type.labelLarge),
                Text('/$maxStars', style: context.type.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Corps ────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_ctrl.isLoading || _ctrl.map == null) {
      if (_ctrl.error != null) {
        return ErrorState(
            message: AppLocalizations.of(context).loadJourneyFailed,
            onRetry: _ctrl.load);
      }
      return const Center(
          child: CircularProgressIndicator(color: AppColors.secondary));
    }

    final map = _ctrl.map!;
    if (map.levels.isEmpty) {
      return EmptyState(
        title: AppLocalizations.of(context).journeyUnavailable,
        subtitle: AppLocalizations.of(context).comeBackLater,
        icon: Icons.map_rounded,
      );
    }

    final bands = JourneyRegions.bandsFor(map.levels.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final canvasHeight = bands * _bandHeight;

        final centers = [
          for (var i = 0; i < map.levels.length; i++)
            _centerFor(i, bands, width),
        ];

        return SingleChildScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          // L'ascension part du bas : on ouvre la vue sur le niveau 1.
          reverse: true,
          child: SizedBox(
            width: width,
            height: canvasHeight,
            child: ClipRect(
              child: Stack(
                children: [
                  // Plan 1 — les bandes illustrées, décalées par la parallaxe.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -_parallax,
                    height: canvasHeight + canvasHeight * 0.14,
                    child: _bandStack(bands),
                  ),
                  // Plan 2 — le sentier, seul élément encore tracé par le code.
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TrailPainter(
                        centers: centers,
                        levels: map.levels,
                        lockedColor: context.appColors.textMuted.withValues(alpha: 0.38),
                      ),
                    ),
                  ),
                  // Plan 3 — les nœuds.
                  for (var i = 0; i < map.levels.length; i++)
                    _positionedNode(map.levels[i], centers[i]),
                  // Bannières de chapitre, à chaque changement de tour.
                  for (var band = JourneyRegions.count;
                      band < bands;
                      band += JourneyRegions.count)
                    _chapterBanner(band, bands),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// La pile de décors, du sommet vers le pied.
  Widget _bandStack(int bands) => Column(
        children: [
          for (var band = bands - 1; band >= 0; band--)
            SizedBox(
              height: _bandHeight,
              child: _RegionBand(band: band, isDark: _isDark),
            ),
          // La parallaxe décale la pile vers le haut : il faut de quoi combler
          // derrière elle, sinon le bas de la carte laisse voir le fond nu.
          SizedBox(height: _bandHeight * 0.14),
        ],
      );

  Offset _centerFor(int index, int bands, double width) {
    final band = index ~/ kAnchorsPerRegion;
    final anchor =
        JourneyRegions.regionForBand(band).anchors[index % kAnchorsPerRegion];
    // Le pied de la map est en bas du canevas : la bande 0 occupe la dernière
    // tranche, et l'ancre s'y place selon sa coordonnée normalisée.
    final bandTop = (bands - 1 - band) * _bandHeight;
    return Offset(width * anchor.dx, bandTop + anchor.dy * _bandHeight);
  }

  Widget _positionedNode(JourneyLevelModel level, Offset center) => Positioned(
        left: center.dx - _nodeBox / 2,
        top: center.dy - _nodeBox / 2,
        width: _nodeBox,
        height: _nodeBox,
        child: Center(
          child: _LevelNode(
            level: level,
            size: level.isBoss ? _bossSize : _nodeSize,
            onTap: () => _play(level),
          ),
        ),
      );

  Widget _chapterBanner(int band, int bands) {
    final tour = JourneyRegions.tourForBand(band);
    // Posée au pied de la première bande du tour, là où le décor change.
    final top = (bands - 1 - band) * _bandHeight + _bandHeight - 16;

    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rPill,
            border:
                Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
          ),
          child: Text(
            AppLocalizations.of(context).journeyChapter(tour + 1),
            style: context.type.labelSmall.copyWith(color: AppColors.secondary),
          ),
        ),
      ),
    );
  }
}

// ─── Bande de décor ─────────────────────────────────────────────────────────

class _RegionBand extends StatelessWidget {
  final int band;
  final bool isDark;

  const _RegionBand({required this.band, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final region = JourneyRegions.regionForBand(band);
    final ambience = JourneyAmbience.forTour(JourneyRegions.tourForBand(band));
    final art = isDark ? region.artDark : region.artLight;

    // Une illustration peinte prend la place du vectoriel dès qu'elle existe :
    // même bande, mêmes ancres, aucun autre code à toucher.
    if (art != null) {
      return Image.asset(art, fit: BoxFit.cover);
    }

    return CustomPaint(
      painter: RegionPainter(
        region: region,
        palette: ambience.palette(isDark),
        stars: ambience.hasStars,
        seed: band * 31 + 7,
      ),
      size: Size.infinite,
    );
  }
}

// ─── Nœud de niveau ─────────────────────────────────────────────────────────

class _LevelNode extends StatelessWidget {
  final JourneyLevelModel level;
  final double size;
  final VoidCallback onTap;

  const _LevelNode({
    required this.level,
    required this.size,
    required this.onTap,
  });

  static const double _box = 132;

  @override
  Widget build(BuildContext context) {
    final locked = !level.unlocked;
    final completed = level.completed;
    final isCurrent = level.unlocked && !completed;

    final base = level.isBoss
        ? AppColors.error
        : completed
            ? AppColors.success
            : AppColors.primary;

    return GestureDetector(
      onTap: locked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _box,
        height: _box,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Le niveau courant porte un anneau, pas un halo pulsant : il doit
            // se repérer d'un coup d'œil, pas attirer l'œil en permanence.
            if (isCurrent)
              Container(
                width: size + 14,
                height: size + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: base.withValues(alpha: 0.45), width: 3),
                ),
              ),
            _disc(context, base, locked),
            if (completed)
              Positioned(
                top: _box / 2 - size / 2 - 18,
                left: 0,
                right: 0,
                child: Center(child: _StarsRow(stars: level.stars)),
              ),
            if (level.isBoss && !completed)
              Positioned(
                top: _box / 2 - size / 2 - 20,
                left: 0,
                right: 0,
                child: const Center(
                  child: Icon(Icons.workspace_premium_rounded,
                      size: 20, color: AppColors.secondaryLight),
                ),
              ),
            if (!locked && level.title != null)
              Positioned(
                top: _box / 2 + size / 2 + 6,
                left: 2,
                right: 2,
                child: Text(
                  level.title!,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.labelSmall
                      .copyWith(color: context.appColors.textPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _disc(BuildContext context, Color color, bool locked) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Le verrouille prend la surface de carte, pas la teinte du sol :
          // en theme clair, un disque creme sur un terrain creme disparaissait.
          color: locked ? context.appColors.cardBg : color,
          border: Border.all(
            color: locked
                ? context.appColors.textMuted.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.25),
            width: 2,
          ),
          boxShadow: locked
              ? AppShadows.card(context)
              : AppShadows.tinted(context, color),
        ),
        child: locked
            ? Icon(Icons.lock_rounded,
                size: size * 0.34, color: context.appColors.textMuted)
            : Text(
                '${level.level}',
                style: context.type.headlineMedium
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
      );
}

class _StarsRow extends StatelessWidget {
  final int stars;
  const _StarsRow({required this.stars});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 15,
                color: i < stars
                    ? AppColors.secondaryLight
                    : context.appColors.textMuted,
              ),
            ),
        ],
      );
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.appColors.bg,
            borderRadius: AppRadius.rMd,
          ),
          child: Icon(icon, color: context.appColors.textSecondary, size: 15),
        ),
      );
}

// ─── Sentier ────────────────────────────────────────────────────────────────

/// Le sentier relie les ancres et s'arrête au dernier niveau débloqué : c'est
/// le seul élément de la carte encore tracé par le code, tout le reste vit
/// dans l'illustration de la bande.
class _TrailPainter extends CustomPainter {
  final List<Offset> centers;
  final List<JourneyLevelModel> levels;
  final Color lockedColor;

  _TrailPainter({
    required this.centers,
    required this.levels,
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

    // Sentier non parcouru : un trait sobre, sans ombre floutée ni glow.
    canvas.drawPath(
      _buildPath(0, centers.length - 1),
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

    canvas.drawPath(
      _buildPath(0, lastUnlocked),
      Paint()
        ..color = AppColors.secondary
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) =>
      old.centers != centers || old.levels != levels;
}
