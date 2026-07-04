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

  static const double _jumpImpulse = 350.0;

  void jump() {
    body.applyLinearImpulse(Vector2(0, -_jumpImpulse));
  }

  void resetToStart(Vector2 start) {
    body.setTransform(start, 0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
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
      linearDamping: 0.8,
      angularDamping: 0.8,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    // رسم الكرة الرئيسية
    final ballPaint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, radius, ballPaint);

    // حافة داكنة
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset.zero, radius, borderPaint);

    // بريق أبيض فوق الكرة
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-radius * 0.28, -radius * 0.28),
      radius * 0.3,
      highlightPaint,
    );
  }
}
