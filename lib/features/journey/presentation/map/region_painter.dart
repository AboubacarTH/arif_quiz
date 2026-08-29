import 'dart:math' as math;

import 'package:arif_quiz/features/journey/presentation/map/journey_region.dart';
import 'package:flutter/material.dart';

/// Décor vectoriel d'une bande de la map.
///
/// C'est le repli tant qu'aucune illustration peinte n'a été déposée : des
/// aplats simples, aucune donnée de chemin interminable, et surtout **aucun
/// dégradé** — la profondeur vient de l'empilement des valeurs, comme partout
/// ailleurs dans l'app.
///
/// La bande se lit en quatre registres, du fond vers l'avant :
///
///   0.00 → 0.30   ciel, et une ligne de toits lointains
///   0.30 → 0.62   le monument de la région
///   0.62 → 1.00   les terrasses que le sentier gravit
///   ~0.80, ~0.94  quelques objets de premier plan
///
/// Tout est dimensionné sur la LARGEUR : une bande est haute (cinq niveaux y
/// tiennent), et caler le monument sur sa hauteur le rendait démesuré.
class RegionPainter extends CustomPainter {
  final JourneyRegion region;
  final RegionPalette palette;
  final bool stars;

  /// Graine stable : le semis d'étoiles et les tranches de livres d'une bande
  /// ne doivent pas changer à chaque repeint, sinon le décor grouille au
  /// défilement.
  final int seed;

  const RegionPainter({
    required this.region,
    required this.palette,
    required this.stars,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = palette.sky);

    if (stars) _paintStars(canvas, size);
    _paintSkyline(canvas, w, h);
    _paintTerraces(canvas, w, h);

    // Le monument s'appuie sur la ligne de sol, à gauche : les ancres dérivent
    // vers la droite, c'est donc là que la place est libre.
    final baseY = h * 0.62;
    switch (region.scenery) {
      case RegionScenery.library:
        _library(canvas, w, baseY);
      case RegionScenery.temple:
        _temple(canvas, w, baseY);
      case RegionScenery.observatory:
        _observatory(canvas, w, baseY);
      case RegionScenery.scriptorium:
        _scriptorium(canvas, w, baseY);
      case RegionScenery.amphitheatre:
        _amphitheatre(canvas, w, baseY);
      case RegionScenery.garden:
        _garden(canvas, w, baseY);
    }

    _paintProps(canvas, w, h);
  }

  Paint get _mass => Paint()..color = palette.landmark;
  Paint get _far => Paint()
    ..color = Color.lerp(palette.sky, palette.landmark, 0.45)!;
  Paint get _accent => Paint()..color = palette.detail.withValues(alpha: 0.5);

  void _paintStars(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final paint = Paint()..color = palette.detail.withValues(alpha: 0.45);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width,
            rnd.nextDouble() * size.height * 0.30),
        0.7 + rnd.nextDouble() * 1.2,
        paint,
      );
    }
  }

  /// Toits lointains : ils ferment l'horizon et empêchent le haut de la bande
  /// de rester un aplat vide.
  void _paintSkyline(Canvas canvas, double w, double h) {
    final rnd = math.Random(seed + 5);
    final horizon = h * 0.30;
    var x = -w * 0.05;
    while (x < w * 1.05) {
      final bw = w * (0.06 + rnd.nextDouble() * 0.09);
      final bh = w * (0.03 + rnd.nextDouble() * 0.07);
      canvas.drawRect(Rect.fromLTWH(x, horizon - bh, bw, bh + h * 0.02), _far);
      // Une toiture sur deux se termine en pointe.
      if (rnd.nextBool()) {
        canvas.drawPath(
          Path()
            ..moveTo(x, horizon - bh)
            ..lineTo(x + bw / 2, horizon - bh - w * 0.025)
            ..lineTo(x + bw, horizon - bh)
            ..close(),
          _far,
        );
      }
      x += bw + w * 0.02;
    }
  }

  /// Trois terrasses qui montent. Elles donnent le relief sur lequel le sentier
  /// s'appuie, sans jamais le dessiner elles-mêmes.
  void _paintTerraces(Canvas canvas, double w, double h) {
    for (var i = 0; i < 3; i++) {
      final top = h * (0.62 + i * 0.13);
      final inset = w * 0.06 * i;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(-inset, top, w + inset, h * 1.2),
          Radius.circular(w * 0.06),
        ),
        Paint()..color = palette.ground.withValues(alpha: 0.45 + i * 0.25),
      );
    }
  }

  /// Objets de premier plan, semés entre les nœuds pour meubler le bas de la
  /// bande sans jamais passer sous une ancre.
  void _paintProps(Canvas canvas, double w, double h) {
    final rnd = math.Random(seed + 11);

    // Trois piles de livres, calées à gauche et au centre-gauche.
    for (final spot in [0.10, 0.26, 0.16]) {
      final x = w * spot;
      final y = h * (0.78 + rnd.nextDouble() * 0.14);
      final levels = 2 + rnd.nextInt(2);
      for (var i = 0; i < levels; i++) {
        final bw = w * (0.045 + rnd.nextDouble() * 0.02);
        canvas.drawRect(
          Rect.fromLTWH(x - bw / 2, y - (i + 1) * w * 0.014, bw, w * 0.012),
          i.isEven ? _accent : _mass,
        );
      }
    }

    // Deux bornes de pierre, plus bas.
    for (final spot in [0.42, 0.06]) {
      final x = w * spot;
      final y = h * 0.95;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w * 0.03, w * 0.045),
            Radius.circular(w * 0.012)),
        _mass,
      );
    }
  }

  // ─── Monuments ────────────────────────────────────────────────────────────

  /// Bibliothèque : un mur d'étagères et ses tranches de livres.
  void _library(Canvas canvas, double w, double baseY) {
    final width = w * 0.34;
    final height = w * 0.24;
    final left = w * 0.05;
    final top = baseY - height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(left, top, left + width, baseY),
          Radius.circular(w * 0.012)),
      _mass,
    );

    final rnd = math.Random(seed);
    const rows = 4;
    final rowH = height / rows;
    for (var row = 0; row < rows; row++) {
      final shelfY = top + rowH * (row + 1) - w * 0.006;
      canvas.drawRect(
          Rect.fromLTWH(left + w * 0.015, shelfY, width - w * 0.03, w * 0.005),
          _far);

      var x = left + w * 0.022;
      while (x < left + width - w * 0.03) {
        final bw = w * (0.010 + rnd.nextDouble() * 0.013);
        final bh = rowH * (0.5 + rnd.nextDouble() * 0.3);
        canvas.drawRect(Rect.fromLTWH(x, shelfY - bh, bw, bh), _accent);
        x += bw + w * 0.005;
      }
    }
  }

  /// Temple : socle à degrés, colonnes, fronton.
  void _temple(Canvas canvas, double w, double baseY) {
    final cx = w * 0.22;
    final width = w * 0.30;
    final height = w * 0.24;
    final top = baseY - height;

    for (var i = 0; i < 2; i++) {
      final grow = width * (0.07 * (i + 1));
      canvas.drawRect(
        Rect.fromLTRB(cx - width / 2 - grow, baseY - w * 0.022 * (2 - i),
            cx + width / 2 + grow, baseY - w * 0.022 * (1 - i)),
        _mass,
      );
    }

    const columns = 5;
    final colW = width / (columns * 2 + 1);
    for (var i = 0; i < columns; i++) {
      final x = cx - width / 2 + colW * (i * 2 + 1);
      canvas.drawRect(
          Rect.fromLTWH(x, top + height * 0.34, colW, height * 0.48), _mass);
    }

    canvas.drawRect(
        Rect.fromLTRB(cx - width / 2, top + height * 0.24, cx + width / 2,
            top + height * 0.34),
        _mass);
    canvas.drawPath(
      Path()
        ..moveTo(cx - width / 2, top + height * 0.24)
        ..lineTo(cx, top)
        ..lineTo(cx + width / 2, top + height * 0.24)
        ..close(),
      _mass,
    );
  }

  /// Observatoire : une tour et sa coupole ouverte.
  void _observatory(Canvas canvas, double w, double baseY) {
    final cx = w * 0.19;
    final towerW = w * 0.12;
    final top = baseY - w * 0.24;

    canvas.drawRect(
        Rect.fromLTRB(cx - towerW / 2, top, cx + towerW / 2, baseY), _mass);

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, top), width: towerW * 1.6, height: towerW * 1.6),
      math.pi,
      math.pi,
      true,
      _mass,
    );

    canvas.drawRect(
        Rect.fromLTWH(
            cx - towerW * 0.07, top - towerW * 0.74, towerW * 0.14, towerW * 0.74),
        _accent);
    canvas.drawLine(
      Offset(cx, top - towerW * 0.25),
      Offset(cx + towerW * 1.0, top - towerW * 1.0),
      Paint()
        ..color = palette.detail.withValues(alpha: 0.7)
        ..strokeWidth = w * 0.010
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
          Rect.fromLTWH(cx - towerW * 0.09, top + w * (0.05 + i * 0.055),
              towerW * 0.18, w * 0.032),
          _accent);
    }
  }

  /// Scriptorium : une galerie d'arcades et son pupitre.
  void _scriptorium(Canvas canvas, double w, double baseY) {
    final left = w * 0.05;
    final width = w * 0.32;
    final height = w * 0.20;
    final top = baseY - height;

    canvas.drawRect(Rect.fromLTRB(left, top, left + width, baseY), _mass);
    canvas.drawRect(
        Rect.fromLTRB(left - w * 0.012, top, left + width + w * 0.012,
            top + w * 0.022),
        _far);

    const arches = 3;
    final archW = width / (arches + 0.6);
    for (var i = 0; i < arches; i++) {
      final x = left + archW * 0.35 + i * archW;
      final rect =
          Rect.fromLTWH(x, top + height * 0.30, archW * 0.68, height * 0.62);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(archW * 0.34),
          topRight: Radius.circular(archW * 0.34),
        ),
        _accent,
      );
    }

    // Pupitre incliné, devant la galerie.
    final deskX = left + width + w * 0.035;
    canvas.drawPath(
      Path()
        ..moveTo(deskX, baseY)
        ..lineTo(deskX + w * 0.075, baseY)
        ..lineTo(deskX + w * 0.075, baseY - w * 0.05)
        ..close(),
      _accent,
    );
  }

  /// Amphithéâtre : des gradins concentriques.
  void _amphitheatre(Canvas canvas, double w, double baseY) {
    final cx = w * 0.22;
    for (var i = 4; i >= 0; i--) {
      final radius = w * (0.06 + i * 0.032);
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(cx, baseY), width: radius * 2, height: radius * 1.5),
        math.pi,
        math.pi,
        true,
        Paint()
          ..color = i.isEven
              ? palette.landmark
              : Color.lerp(palette.landmark, palette.sky, 0.25)!,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, baseY), width: w * 0.07, height: w * 0.05),
      math.pi,
      math.pi,
      true,
      _accent,
    );
  }

  /// Jardin de pierre : lanternes et cyprès.
  void _garden(Canvas canvas, double w, double baseY) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.03, baseY - w * 0.035, w * 0.36, baseY),
          Radius.circular(w * 0.012)),
      _mass,
    );

    const heights = [0.22, 0.15, 0.19];
    for (var i = 0; i < heights.length; i++) {
      final x = w * (0.08 + i * 0.085);
      final top = baseY - w * heights[i];
      canvas.drawPath(
        Path()
          ..moveTo(x, top)
          ..lineTo(x + w * 0.030, baseY - w * 0.03)
          ..lineTo(x - w * 0.030, baseY - w * 0.03)
          ..close(),
        _mass,
      );
    }

    final lx = w * 0.33;
    canvas.drawRect(
        Rect.fromLTWH(lx, baseY - w * 0.10, w * 0.016, w * 0.10), _mass);
    canvas.drawRect(
        Rect.fromLTWH(lx - w * 0.012, baseY - w * 0.135, w * 0.040, w * 0.035),
        _accent);
    canvas.drawRect(
        Rect.fromLTWH(lx - w * 0.020, baseY - w * 0.152, w * 0.056, w * 0.017),
        _mass);
  }

  @override
  bool shouldRepaint(covariant RegionPainter old) =>
      old.region.id != region.id ||
      old.palette.sky != palette.sky ||
      old.stars != stars ||
      old.seed != seed;
}
