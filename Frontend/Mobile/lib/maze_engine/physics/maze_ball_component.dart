import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class MazeBallComponent extends BodyComponent {
  MazeBallComponent({
    required this.startPosition,
    required this.radius,
    required this.color,
  }) : super(paint: Paint()..color = color);

  final Vector2 startPosition;
  final double radius;
  final Color color;

  // Normal damping while rolling.
  static const double _normalDamping = 0.8;
  // Very low damping during a jump so horizontal momentum carries the ball.
  static const double _jumpDamping = 0.02;

  void jumpWithDirection(Vector2 impulse) {
    // Kill any tiny leftover velocity so the arch is clean.
    body.linearVelocity = Vector2.zero();
    body.applyLinearImpulse(impulse);
  }

  /// Old API — vertical only (kept for backwards compat).
  void jump() {
    jumpWithDirection(Vector2(0, -350));
  }

  void setJumpingPhysics(bool jumping) {
    body.linearDamping = jumping ? _jumpDamping : _normalDamping;
    body.angularDamping = jumping ? _jumpDamping : _normalDamping;
  }

  void resetToStart(Vector2 start) {
    body.setTransform(start, 0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
    body.linearDamping = _normalDamping;
    body.angularDamping = _normalDamping;
  }

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
      linearDamping: _normalDamping,
      angularDamping: _normalDamping,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final ballPaint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, radius, ballPaint);

    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset.zero, radius, borderPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-radius * 0.28, -radius * 0.28),
      radius * 0.32,
      highlightPaint,
    );
  }
}