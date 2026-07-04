import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment, HSLColor;

class MazeStarComponent extends PositionComponent {
  Color color;
  bool collected = false;

  MazeStarComponent({
    required Vector2 position,
    required double radius,
    required this.color,
  }) : super(
    position: position,
    size: Vector2.all(radius * 2),
    anchor: Anchor.center,
  ) {
    // Randomize each star's animation phase so a field of stars doesn't
    // pulse/twinkle in unison — reads far more lively and less mechanical.
    final rand = math.Random(position.x.toInt() ^ position.y.toInt());
    _phase = rand.nextDouble() * math.pi * 2;
    _sparklePhases = List.generate(3, (_) => rand.nextDouble() * math.pi * 2);
  }

  double _time = 0;
  late double _phase;
  late List<double> _sparklePhases;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  // Wide, warm, saturated glow — two layers for a soft bloom + a brighter core.
  final Paint _glowOuterPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
  final Paint _glowInnerPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  final Paint _shadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.black.withOpacity(0.18)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  // Single thick outline in a warm, deepened shade of the star's OWN
  // color (not white) — this is the sticker/emoji look: a golden star
  // gets a rich amber-orange border, matching rather than contrasting.
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  final Paint _shinePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white.withOpacity(0.85)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

  final Paint _shineSmallPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white.withOpacity(0.9)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

  final Paint _sparklePaint = Paint()..style = PaintingStyle.fill;

  static const double _baseTilt = 0.22;

  @override
  void render(Canvas canvas) {
    if (collected) return;

    // Gentle idle bounce (scale) and rock (rotation) — makes the star feel
    // alive/playful rather than a static sticker.
    final bounce = 1.0 + 0.05 * math.sin(_time * 2.6 + _phase);
    final wobble = _baseTilt + 0.09 * math.sin(_time * 1.4 + _phase);

    final outerR = (size.x / 2) * bounce;
    final innerR = outerR * 0.55;
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Boost saturation/lightness so the base color always reads as bright
    // and candy-like, even if a slightly muted color is passed in.
    final hsl = HSLColor.fromColor(color);
    final popColor = hsl
        .withSaturation((hsl.saturation * 1.25).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 1.05).clamp(0.35, 0.72))
        .toColor();

    _glowOuterPaint.color = popColor.withOpacity(0.35);
    canvas.drawCircle(Offset(cx, cy), outerR * 1.7, _glowOuterPaint);
    _glowInnerPaint.color = popColor.withOpacity(0.55);
    canvas.drawCircle(Offset(cx, cy), outerR * 1.15, _glowInnerPaint);

    _drawSparkles(canvas, cx, cy, outerR);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(wobble);
    canvas.translate(-cx, -cy);

    final points = _starPoints(cx, cy, outerR, innerR, 5);
    final path = _roundedStarPath(points, outerR, innerR);

    canvas.save();
    canvas.translate(outerR * 0.05, outerR * 0.09);
    canvas.drawPath(path, _shadowPaint);
    canvas.restore();

    // Simple, flat-leaning gradient like the reference: a bright warm
    // center fading to a slightly deeper/warmer tone toward the edges.
    // No white highlight mixed into the fill — just the color family.
    final lightShade = Color.lerp(popColor, Colors.white, 0.35)!;
    final edgeShade = hsl.withHue((hsl.hue + 8).clamp(0.0, 360.0))
        .withSaturation((hsl.saturation).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.85).clamp(0.0, 1.0))
        .toColor();

    _fillPaint.shader = RadialGradient(
      center: const Alignment(-0.15, -0.35),
      radius: 1.0,
      colors: [lightShade, popColor, edgeShade],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: outerR));

    canvas.drawPath(path, _fillPaint);

    // Single warm outline, deepened + slightly hue-shifted from the base
    // color (e.g. golden yellow star -> amber-orange border), drawn with
    // enough weight to read as bold and toylike.
    final outlineShade = hsl.withHue((hsl.hue + 15).clamp(0.0, 360.0))
        .withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0))
        .toColor();
    _outlinePaint
      ..color = outlineShade
      ..strokeWidth = outerR * 0.14;
    canvas.drawPath(path, _outlinePaint);

    // Big glossy shine plus a tiny secondary highlight for extra sparkle.
    canvas.save();
    canvas.translate(cx - outerR * 0.26, cy - outerR * 0.32);
    canvas.rotate(-0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: outerR * 0.6, height: outerR * 0.22),
      _shinePaint,
    );
    canvas.restore();

    canvas.drawCircle(
      Offset(cx + outerR * 0.22, cy - outerR * 0.08),
      outerR * 0.08,
      _shineSmallPaint,
    );

    canvas.restore();
  }

  /// Small 4-point twinkle sparkles that fade in and out around the star
  /// on independent timers — the classic "magic item" cue in kids' games.
  void _drawSparkles(Canvas canvas, double cx, double cy, double outerR) {
    final offsets = [
      Offset(cx + outerR * 1.35, cy - outerR * 0.6),
      Offset(cx - outerR * 1.3, cy - outerR * 0.9),
      Offset(cx - outerR * 0.9, cy + outerR * 1.2),
    ];
    final sizes = [outerR * 0.22, outerR * 0.15, outerR * 0.18];

    for (int i = 0; i < offsets.length; i++) {
      final twinkle = (math.sin(_time * 2.2 + _sparklePhases[i]) + 1) / 2;
      if (twinkle < 0.15) continue; // fully invisible most of the cycle
      _sparklePaint.color = Colors.white.withOpacity(0.85 * twinkle);
      _drawSparkle(canvas, offsets[i], sizes[i] * (0.6 + 0.4 * twinkle));
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double r) {
    final path = Path();
    // Pinched 4-point star ("plus with points") — the standard sparkle glyph.
    path.moveTo(center.dx, center.dy - r);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r);
    path.close();
    canvas.drawPath(path, _sparklePaint);
  }

  List<Offset> _starPoints(
      double cx,
      double cy,
      double outerR,
      double innerR,
      int points,
      ) {
    final pts = <Offset>[];
    final step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      pts.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
      angle += step;
    }
    return pts;
  }

  /// Generously rounded corners at every vertex for a plump, puffy,
  /// toy-like star shape rather than a sharp geometric one.
  Path _roundedStarPath(List<Offset> pts, double outerR, double innerR) {
    final n = pts.length;
    final tipRadius = outerR * 0.18;
    final valleyRadius = innerR * 0.45;

    Offset _dir(Offset a, Offset b) {
      final d = b - a;
      final len = d.distance;
      return len == 0 ? Offset.zero : Offset(d.dx / len, d.dy / len);
    }

    final starts = <Offset>[];
    final ends = <Offset>[];

    for (int i = 0; i < n; i++) {
      final prev = pts[(i - 1 + n) % n];
      final curr = pts[i];
      final next = pts[(i + 1) % n];
      final cornerR = i.isEven ? tipRadius : valleyRadius;

      final rIn = math.min(cornerR, (curr - prev).distance / 2);
      final rOut = math.min(cornerR, (next - curr).distance / 2);

      final dirFromPrev = _dir(prev, curr);
      final dirToNext = _dir(curr, next);

      starts.add(curr - dirFromPrev * rIn);
      ends.add(curr + dirToNext * rOut);
    }

    final path = Path()..moveTo(starts[0].dx, starts[0].dy);
    for (int i = 0; i < n; i++) {
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, ends[i].dx, ends[i].dy);
      final nextIdx = (i + 1) % n;
      path.lineTo(starts[nextIdx].dx, starts[nextIdx].dy);
    }
    path.close();
    return path;
  }
}