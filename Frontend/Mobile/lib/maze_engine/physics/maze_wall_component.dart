import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Reusable static physics wall for every future maze.
///
/// Pulled out of `test_screens/forge2d_test_screen.dart`'s private
/// `_PhysicsWall`. Fixture values (friction, restitution) are kept exactly
/// as already tuned in the prototype — do not change them speculatively.
class MazeWallComponent extends BodyComponent {
  MazeWallComponent({
    required this.position,
    required this.size,
    required Color color,
  }) : super(paint: Paint()..color = color);

  final Vector2 position;
  final Vector2 size;

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        size.x / 2,
        size.y / 2,
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.45,
      restitution: 0.25,
    );

    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
