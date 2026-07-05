import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../../maze_engine/physics/maze_ball_component.dart';
import '../../../maze_engine/physics/maze_wall_component.dart';
import '../../../maze_engine/physics/tilt_gravity_behavior.dart';
import '../../../maze_engine/tilt/tilt_controller.dart';
import '../config/bodily_maze_level_config.dart';

class BodilyMazeGame extends Forge2DGame {
  BodilyMazeGame({
    required this.config,
    required this.tiltController,
    required this.onFellInHole,
    required this.onReachedEnd,
  }) : super(gravity: Vector2.zero(), zoom: 1);

  final MazeLevelConfig config;
  final TiltController tiltController;
  final VoidCallback onFellInHole;
  final VoidCallback onReachedEnd;

  MazeBallComponent? _ball;
  TiltGravityBehavior? _tiltBehavior;
  Vector2 _startPixel = Vector2.zero();

  bool _worldBuilt = false;
  bool _finished = false;

  // ── Jump state ─────────────────────────────────────────────────────────
  bool _isJumping = false;
  double _jumpTimer = 0;
  static const double _jumpDuration = 0.55;
  // أثناء النط، نثبّت الجاذبية للأسفل عشان نضمن الـ arch
  static const double _jumpGravity = 700.0;
  static const double _jumpImpulseStrength = 500.0;

  // ── Trail (ذيل الكرة أثناء النط) ───────────────────────────────────────
  final Queue<Vector2> _trail = Queue();
  static const int _maxTrail = 18;

  // ── Auto jump cooldown ──────────────────────────────────────────────────
  double _autoJumpCooldown = 0;
  static const double _autoJumpProximity = 0.07;

  double _airborneTimer = 0;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    tiltController.start();
    final behavior = TiltGravityBehavior(tiltController: tiltController);
    _tiltBehavior = behavior;
    await add(behavior);
  }

  @override
  void onRemove() {
    tiltController.stop();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (_worldBuilt || gameSize.x <= 0 || gameSize.y <= 0) return;
    _worldBuilt = true;
    _buildWorld(gameSize);
  }

  void _buildWorld(Vector2 s) {
    for (final r in config.wallRects) {
      final rect = Rect.fromLTWH(r.left*s.x, r.top*s.y, r.width*s.x, r.height*s.y);
      add(MazeWallComponent(
        position: Vector2(rect.center.dx, rect.center.dy),
        size: Vector2(rect.width, rect.height),
        color: const Color(0x00000000),
      ));
    }
    _startPixel = Vector2(config.startPoint.dx * s.x, config.startPoint.dy * s.y);
    final ball = MazeBallComponent(
      startPosition: _startPixel.clone(),
      radius: 5,
      color: const Color(0xFFF9B919),
    );
    _ball = ball;
    add(ball);
  }

  // ── Public: tap anywhere → jump ─────────────────────────────────────────
  void handleTap() {
    if (_ball == null || _finished) return;
    _doJump();
  }

  void _doJump() {
    if (_isJumping) return; // ما ننط وإحنا بالهوا
    _isJumping = true;
    _jumpTimer = _jumpDuration;
    _airborneTimer = _jumpDuration;
    _autoJumpCooldown = _jumpDuration + 0.3;
    _trail.clear();

    // ثبّت الجاذبية للأسفل أثناء النط
    world.gravity = Vector2(0, _jumpGravity);

    // طبّق impulse للأعلى
    _ball?.body.applyLinearImpulse(Vector2(0, -_jumpImpulseStrength));
  }

  void _endJump() {
    _isJumping = false;
    _trail.clear();
  }

  // ── Hole detection ──────────────────────────────────────────────────────
  bool _isNearHole() {
    final ball = _ball;
    if (ball == null) return false;
    final s = size;
    final pos = ball.body.position;
    final prox = _autoJumpProximity * s.x;
    for (final r in config.holeRects) {
      final rect = Rect.fromLTWH(
        r.left*s.x - prox, r.top*s.y - prox,
        r.width*s.x + prox*2, r.height*s.y + prox*2,
      );
      if (rect.contains(Offset(pos.x, pos.y))) return true;
    }
    return false;
  }

  bool _isOverHole() {
    final ball = _ball;
    if (ball == null) return false;
    final s = size;
    final pos = ball.body.position;
    for (final r in config.holeRects) {
      final rect = Rect.fromLTWH(r.left*s.x, r.top*s.y, r.width*s.x, r.height*s.y);
      if (rect.contains(Offset(pos.x, pos.y))) return true;
    }
    return false;
  }

  bool _isAtEnd() {
    final ball = _ball;
    if (ball == null) return false;
    final s = size;
    final pos = ball.body.position;
    final c = Offset(config.endPoint.dx*s.x, config.endPoint.dy*s.y);
    final rPx = config.endPointRadius * s.x;
    final dx = pos.x - c.dx, dy = pos.y - c.dy;
    return (dx*dx + dy*dy) <= (rPx*rPx);
  }

  // ── Update loop ─────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || _ball == null) return;

    if (_autoJumpCooldown > 0) _autoJumpCooldown -= dt;
    if (_airborneTimer > 0) _airborneTimer -= dt;

    // أثناء النط: تتبع الـ trail وعد الوقت
    if (_isJumping) {
      _jumpTimer -= dt;
      final pos = _ball!.body.position.clone();
      _trail.addLast(pos);
      if (_trail.length > _maxTrail) _trail.removeFirst();

      if (_jumpTimer <= 0) {
        _endJump();
        // أعد الـ tilt gravity بعد ما خلص النط
        _tiltBehavior?.resetGravity();
      }
    }

    // نط تلقائي لما تقترب من الحفرة
    if (!_isJumping && _autoJumpCooldown <= 0 && _isNearHole()) {
      _doJump();
      return;
    }

    if (_isAtEnd()) {
      _finished = true;
      onReachedEnd();
      return;
    }

    if (!_isJumping && _airborneTimer <= 0 && _isOverHole()) {
      onFellInHole();
      _resetBall();
    }
  }

  // ── Render: رسم الـ trail فوق الكرة ─────────────────────────────────────
  @override
  void render(Canvas canvas) {
    super.render(canvas); // يرسم الكرة والجدران

    if (_isJumping && _trail.length > 1) {
      final list = _trail.toList();
      for (int i = 1; i < list.length; i++) {
        final progress = i / list.length; // 0 → 1 (أقدم → أحدث)
        final alpha = (progress * 0.55).clamp(0.0, 1.0);
        final radius = (4 * progress).clamp(1.0, 4.0);
        final paint = Paint()
          ..color = const Color(0xFFF9B919).withValues(alpha: alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(list[i].x, list[i].y), radius, paint);
      }

      // حلقة توهج عند نقطة الانطلاق
      if (list.isNotEmpty) {
        final startPos = list.first;
        final glowProgress = (_jumpDuration - _jumpTimer) / _jumpDuration;
        final glowRadius = 8.0 + glowProgress * 20;
        final glowAlpha = (0.4 * (1 - glowProgress)).clamp(0.0, 0.4);
        final glowPaint = Paint()
          ..color = const Color(0xFFF9B919).withValues(alpha: glowAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(startPos.x, startPos.y), glowRadius, glowPaint);
      }
    }
  }

  void _resetBall() {
    _ball?.resetToStart(_startPixel.clone());
    _airborneTimer = 0;
    _autoJumpCooldown = 0;
    _isJumping = false;
    _trail.clear();
    _tiltBehavior?.resetGravity();
  }

  void calibrate() => tiltController.calibrate();
}