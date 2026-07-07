import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment, HSLColor;

/// Shared star-rendering logic used by both the Flame maze stars
/// (MazeStarComponent) and the lightweight Flutter progress-bar icons
/// (StarProgressBar), so they always look like the exact same star.
class StarPainter {
  StarPainter._();

  static final Paint _glowOuterPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
  static final Paint _glowInnerPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  static final Paint _shadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.black.withOpacity(0.18)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  static final Paint _shinePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white.withOpacity(0.85)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
  static final Paint _shineSmallPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white.withOpacity(0.9)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

  /// Draws the sticker-style star (glow + shadow + gradient fill + outline
  /// + shine), centered at [center] with base outer radius [outerR].
  ///
  /// [bounce] and [wobble] let a caller layer in idle animation (Flame
  /// stars pass a sin-wave value each frame); pass the defaults for a
  /// static, non-animated star, as used for small UI icons.
  /// [withGlow] can be turned off for muted/uncollected icon states.
  static void paintStar(
      Canvas canvas,
      Offset center,
      double outerR,
      Color color, {
        double bounce = 1.0,
        double wobble = 0.22,
        bool withGlow = true,
      }) {
    final r = outerR * bounce;
    final innerR = r * 0.55;
    final cx = center.dx;
    final cy = center.dy;

    final hsl = HSLColor.fromColor(color);
    final popColor = hsl
        .withSaturation((hsl.saturation * 1.25).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 1.05).clamp(0.35, 0.72))
        .toColor();

    if (withGlow) {
      _glowOuterPaint.color = popColor.withOpacity(0.35);
      canvas.drawCircle(center, r * 1.7, _glowOuterPaint);
      _glowInnerPaint.color = popColor.withOpacity(0.55);
      canvas.drawCircle(center, r * 1.15, _glowInnerPaint);
    }

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(wobble);
    canvas.translate(-cx, -cy);

    final points = _starPoints(cx, cy, r, innerR, 5);
    final path = _roundedStarPath(points, r, innerR);

    canvas.save();
    canvas.translate(r * 0.05, r * 0.09);
    canvas.drawPath(path, _shadowPaint);
    canvas.restore();

    final lightShade = Color.lerp(popColor, Colors.white, 0.35)!;
    final edgeShade = hsl
        .withHue((hsl.hue + 8).clamp(0.0, 360.0))
        .withSaturation((hsl.saturation).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.85).clamp(0.0, 1.0))
        .toColor();

    _fillPaint.shader = RadialGradient(
      center: const Alignment(-0.15, -0.35),
      radius: 1.0,
      colors: [lightShade, popColor, edgeShade],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawPath(path, _fillPaint);

    final outlineShade = hsl
        .withHue((hsl.hue + 15).clamp(0.0, 360.0))
        .withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0))
        .toColor();
    _outlinePaint
      ..color = outlineShade
      ..strokeWidth = r * 0.14;
    canvas.drawPath(path, _outlinePaint);

    canvas.save();
    canvas.translate(cx - r * 0.26, cy - r * 0.32);
    canvas.rotate(-0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 0.6, height: r * 0.22),
      _shinePaint,
    );
    canvas.restore();

    canvas.drawCircle(
      Offset(cx + r * 0.22, cy - r * 0.08),
      r * 0.08,
      _shineSmallPaint,
    );

    canvas.restore();
  }

  static List<Offset> _starPoints(
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
      final rr = i.isEven ? outerR : innerR;
      pts.add(Offset(cx + rr * math.cos(angle), cy + rr * math.sin(angle)));
      angle += step;
    }
    return pts;
  }

  static Path _roundedStarPath(List<Offset> pts, double outerR, double innerR) {
    final n = pts.length;
    final tipRadius = outerR * 0.18;
    final valleyRadius = innerR * 0.45;

    Offset dir(Offset a, Offset b) {
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

      final dirFromPrev = dir(prev, curr);
      final dirToNext = dir(curr, next);

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