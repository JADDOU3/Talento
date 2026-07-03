import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Colors, Curves;

import '../../activities/cognitive_maze/config/cognitive_maze_level_config.dart';

/// Draws the Palestine flag frame that lives at a fixed spot in the level 2
/// artwork (currently just outlined/blank there) and fills in each stripe +
/// the triangle as its matching star color is collected.
///
/// `collectedColors` is the SAME Set instance the game mutates on pickup
/// (added to on collect, cleared on wrong-color reset) — this component
/// never owns or copies it, it just reads it every frame.
class MazeFlagFillComponent extends PositionComponent {
  final Set<Color> collectedColors;

  /// Fraction of the flag's width the red triangle spans, measured from the
  /// artwork. Tune this per-level if a different maze reuses this component
  /// with a differently-proportioned flag.
  final double triangleWidthFraction;

  MazeFlagFillComponent({
    required Vector2 position,
    required Vector2 size,
    required this.collectedColors,
    this.triangleWidthFraction = 0.4,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  // Opaque backing drawn first so this component fully occludes the flag
  // baked into the level artwork underneath, rather than just outlining
  // over it.
  final Paint _backgroundPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  final Paint _stripePaint = Paint()..style = PaintingStyle.fill;
  final Paint _trianglePaint = Paint()..style = PaintingStyle.fill;
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.black87;

  // Tracks what was filled last frame so we only pulse on *new* fills,
  // not every frame while a color stays collected.
  final Set<Color> _lastRenderedColors = {};

  Color _stripe(Color target) =>
      collectedColors.contains(target) ? target : const Color(0x00000000);

  @override
  void update(double dt) {
    super.update(dt);

    // Detect newly-collected target colors since last frame and fire a
    // quick bounce so the fill is noticeable even though the flag sits
    // outside the maze corridors the player is watching.
    final newlyFilled = collectedColors.difference(_lastRenderedColors);
    if (newlyFilled.isNotEmpty) {
      _pulse();
    }

    // Sync tracking set. Also handles the reset-on-wrong-color case: if
    // collectedColors was cleared, this clears too and no pulse fires
    // until something genuinely new is collected again.
    _lastRenderedColors
      ..clear()
      ..addAll(collectedColors);
  }

  void _pulse() {
    // Remove any in-flight pulse so rapid consecutive pickups don't stack
    // and leave the component stuck at a scaled-up size.
    children.whereType<ScaleEffect>().forEach((e) => e.removeFromParent());

    add(
      ScaleEffect.by(
        Vector2.all(1.18),
        EffectController(
          duration: 0.12,
          reverseDuration: 0.18,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final stripeH = h / 3;

    // Solid white backing covers whatever flag artwork is baked into the
    // level image; everything below draws on top of this.
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _backgroundPaint);

    _outlinePaint.strokeWidth = w * 0.008;

    final triangleWidth = w * triangleWidthFraction;
    final trianglePath = Path()
      ..moveTo(0, 0)
      ..lineTo(triangleWidth, h / 2)
      ..lineTo(0, h)
      ..close();

    // Each stripe is clipped to exclude the triangle's area before being
    // drawn, so its fill/outline never bleeds under the triangle — that
    // bleed-through was what looked like lines cutting across the triangle
    // whenever red hadn't been collected yet (transparent triangle showing
    // the stripe seams underneath).
    void drawStripe(Rect rect, Color color) {
      final stripePath = Path()..addRect(rect);
      final clipped = Path.combine(
        PathOperation.difference,
        stripePath,
        trianglePath,
      );
      _stripePaint.color = _stripe(color);
      canvas.drawPath(clipped, _stripePaint);
      canvas.drawPath(clipped, _outlinePaint);
    }

    drawStripe(Rect.fromLTWH(0, 0, w, stripeH), PalestineFlagColors.black);
    drawStripe(
        Rect.fromLTWH(0, stripeH, w, stripeH), PalestineFlagColors.white);
    drawStripe(
        Rect.fromLTWH(0, stripeH * 2, w, stripeH), PalestineFlagColors.green);

    // Red triangle drawn last, on top of the clipped stripes, so it sits
    // cleanly with no stripe seams crossing it.
    _trianglePaint.color = _stripe(PalestineFlagColors.red);
    canvas.drawPath(trianglePath, _trianglePaint);
    canvas.drawPath(trianglePath, _outlinePaint);

    // Clean outer border around the whole flag.
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _outlinePaint);
  }
}