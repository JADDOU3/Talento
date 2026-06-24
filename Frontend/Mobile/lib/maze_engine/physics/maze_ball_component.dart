import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Reusable physics ball for every future maze (cognitive, creative, etc.).
///
/// Pulled out of `test_screens/forge2d_test_screen.dart`'s private
/// `_PhysicsBall` so every maze reuses the same physics body instead of
/// reimplementing it. The fixture values (density, friction, restitution,
/// damping) are kept exactly as already tuned in the prototype — do not
/// change them speculatively.
class MazeBallComponent extends BodyComponent {
  MazeBallComponent({
    required this.startPosition,
    required this.radius,
    required Color color,
  }) : super(paint: Paint()..color = color);

  final Vector2 startPosition;
  final double radius;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      friction: 0.25,
      restitution: 0.72,
    );

    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: startPosition,
      linearDamping: 0.08,
      angularDamping: 0.08,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-radius * 0.28, -radius * 0.28),
      radius * 0.25,
      highlightPaint,
    );
  }
}
