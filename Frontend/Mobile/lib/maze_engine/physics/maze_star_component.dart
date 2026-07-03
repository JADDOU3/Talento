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
  );

  // Two-layer glow: a wide soft bloom plus a tighter brighter core, which
  // reads as actual light rather than a single flat blurred blob.
  final Paint _glowOuterPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
  final Paint _glowInnerPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  // Soft shadow beneath the star for a touch of depth/lift off the maze.
  final Paint _shadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.black.withOpacity(0.22)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  // Thick solid outline in a darker shade of the star's own color — this
  // is the bold "plush toy" border look, not a thin subtle line.
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  final Paint _shinePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white.withOpacity(0.8)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

  // Fixed tilt applied to the whole star so it doesn't sit perfectly
  // upright — reads as more playful/hand-placed. ~14 degrees.
  static const double _tiltRadians = 0.25;

  @override
  void render(Canvas canvas) {
    if (collected) return; // simply hidden once picked up

    final outerR = size.x / 2;
    // Chunkier points: a higher inner/outer ratio than a classic thin
    // star makes each point plump rather than spindly.
    final innerR = outerR * 0.52;
    final cx = outerR;
    final cy = outerR;

    // Glow layers drawn before the tilt transform — they're circles, so
    // rotating them would be a no-op, and this keeps them centered
    // regardless of the star's tilt.
    _glowOuterPaint.color = color.withOpacity(0.3);
    canvas.drawCircle(Offset(cx, cy), outerR * 1.55, _glowOuterPaint);
    _glowInnerPaint.color = color.withOpacity(0.48);
    canvas.drawCircle(Offset(cx, cy), outerR * 1.1, _glowInnerPaint);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_tiltRadians);
    canvas.translate(-cx, -cy);

    final points = _starPoints(cx, cy, outerR, innerR, 5);
    final path = _roundedStarPath(points, outerR, innerR);

    // Drop shadow: same rounded star shape, offset down-right and blurred.
    canvas.save();
    canvas.translate(outerR * 0.05, outerR * 0.08);
    canvas.drawPath(path, _shadowPaint);
    canvas.restore();

    // Glossy gradient fill: bright near-white highlight top-left, through
    // the base color, to a rich deep shade bottom-right.
    final hsl = HSLColor.fromColor(color);
    final lightShade = Color.lerp(color, Colors.white, 0.55)!;
    final midShade = hsl.withLightness((hsl.lightness * 0.85).clamp(0.0, 1.0)).toColor();
    final deepShade =
    hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
    final darkestShade =
    hsl.withLightness((hsl.lightness * 0.32).clamp(0.0, 1.0)).toColor();

    _fillPaint.shader = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 1.05,
      colors: [lightShade, midShade, deepShade, darkestShade],
      stops: const [0.0, 0.4, 0.75, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: outerR));

    // Bold, fully-opaque outline — scaled to the star's size so it stays
    // proportional at any radius.
    _strokePaint
      ..color = darkestShade
      ..strokeWidth = outerR * 0.11;

    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _strokePaint);

    // Big soft shine near the upper-left for that glossy plush-toy look.
    canvas.save();
    canvas.translate(cx - outerR * 0.28, cy - outerR * 0.32);
    canvas.rotate(-0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: outerR * 0.62,
        height: outerR * 0.22,
      ),
      _shinePaint,
    );
    canvas.restore();

    canvas.restore(); // undo the tilt transform
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
    double angle = -math.pi / 2; // first point straight up

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      pts.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
      angle += step;
    }
    return pts;
  }

  /// Builds a star path with generously rounded corners at every vertex —
  /// more rounding than a subtle "soft edge" tweak, enough to read as a
  /// plump, puffy star shape rather than a geometric one.
  Path _roundedStarPath(List<Offset> pts, double outerR, double innerR) {
    final n = pts.length;
    final tipRadius = outerR * 0.16;
    final valleyRadius = innerR * 0.4;

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