import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../../maze_engine/physics/maze_ball_component.dart';
import '../../../maze_engine/physics/maze_star_component.dart';
import '../../../maze_engine/physics/maze_wall_component.dart';
import '../../../maze_engine/physics/tilt_gravity_behavior.dart';
import '../../../maze_engine/tilt/tilt_controller.dart';
import '../config/adventure_maze_level_config.dart';

/// Called from the game when the ball touches a star.
typedef StarTouchedCallback = void Function(int challengeId);

/// Adventure Maze game — reuses the shared tilt engine directly. Adds:
///  - MazeStarComponents (same visual as Cognitive Maze) at configured
///    positions (collision → callback → cubit opens popup and pauses the
///    game).
///  - An EndBlockComponent that blocks the path to the end point until
///    every star is collected.
class AdventureMazeGame extends Forge2DGame {
  AdventureMazeGame({
    required this.config,
    required this.tiltController,
    required this.starChallengeIds,
    required this.onFellInHole,
    required this.onReachedEnd,
    required this.onStarTouched,
  }) : super(gravity: Vector2.zero(), zoom: 1);

  final AdventureMazeLevelConfig config;
  final TiltController tiltController;

  /// The IDs of stars the current level has, in the order they appear.
  final List<int> starChallengeIds;

  final VoidCallback onFellInHole;
  final VoidCallback onReachedEnd;
  final StarTouchedCallback onStarTouched;

  MazeBallComponent? _ball;
  TiltGravityBehavior? _tiltBehavior;
  Vector2 _startPixel = Vector2.zero();

  final Map<int, MazeStarComponent> _starComponents = {};
  static const double _starRadiusNormalized = 0.035;

  _EndBlockComponent? _endBlock;

  bool _worldBuilt = false;
  bool _finished = false;
  bool _paused = false; // popup open → freeze tilt gravity

  // ── Hold-to-fly state (نفس Bodily Maze بالضبط) ────────────────────────
  bool _isHolding = false;
  static const double _liftForcePerFrame = 45.0;
  static const double _maxUpwardSpeed = 180.0;
  static const double _fallGravity = 700.0;

  // Motion trail
  final Queue<Vector2> _trail = Queue();
  static const int _maxTrail = 15;
  static const double _trailInterval = 0.02;
  double _trailTimer = 0;
  static const double _movingThreshold = 20.0;

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
    // Walls
    for (final r in config.wallRects) {
      final rect = Rect.fromLTWH(
          r.left * s.x, r.top * s.y, r.width * s.x, r.height * s.y);
      add(MazeWallComponent(
        position: Vector2(rect.center.dx, rect.center.dy),
        size: Vector2(rect.width, rect.height),
        color: const Color(0x00000000),
      ));
    }

    // End block — behaves like a wall until stars are complete
    final ebRect = Rect.fromLTWH(
      config.endBlockRect.left * s.x,
      config.endBlockRect.top * s.y,
      config.endBlockRect.width * s.x,
      config.endBlockRect.height * s.y,
    );
    final endBlock = _EndBlockComponent(
      blockPosition: Vector2(ebRect.center.dx, ebRect.center.dy),
      blockSize: Vector2(ebRect.width, ebRect.height),
    );
    _endBlock = endBlock;
    add(endBlock);

    // Ball
    _startPixel = Vector2(config.startPoint.dx * s.x, config.startPoint.dy * s.y);
    final ball = MazeBallComponent(
      startPosition: _startPixel.clone(),
      radius: 5,
      color: const Color(0xFFF9B919),
    );
    _ball = ball;
    add(ball);

    // Stars — same visual component as Cognitive Maze, draw only, no
    // physics body (collision detected via distance). Color comes straight
    // from config.starColors, same as Cognitive Maze's MazeStar.color.
    for (final cid in starChallengeIds) {
      final pos = config.starPositions[cid];
      if (pos == null) continue;
      final starPos = Vector2(pos.dx * s.x, pos.dy * s.y);
      final radiusPx = _starRadiusNormalized * s.x;
      final comp = MazeStarComponent(
        position: starPos,
        radius: radiusPx,
        color: config.starColors[cid] ?? const Color(0xFFFFD600),
      );
      _starComponents[cid] = comp;
      add(comp);
    }
  }

  // ─── Public control ─────────────────────────────────────────────────────

  /// hold to fly — نفس Bodily Maze بالضبط
  void startHold() {
    if (_ball == null || _finished || _paused) return;
    _isHolding = true;
    _ball!.setJumpingPhysics(true);
    world.gravity = Vector2.zero();
    _airborneTimer = 999; // ما نفشل من الحفر أثناء الطيران
  }

  void stopHold() {
    if (!_isHolding) return;
    _isHolding = false;
    world.gravity = Vector2(0, _fallGravity);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isHolding && _ball != null) {
        _ball!.setJumpingPhysics(false);
        _tiltBehavior?.resetGravity();
        _airborneTimer = 0;
      }
    });
  }

  /// kept for backwards compat — no-op now, controlled via hold.
  void handleTap() {}

  void pauseForPopup() {
    _paused = true;
    // أوقف الفيزياء وأوقف الجيروسكوب من تحديث الجاذبية
    _tiltBehavior?.paused = true;
    _ball?.body.linearVelocity = Vector2.zero();
    _ball?.body.angularVelocity = 0;
    world.gravity = Vector2.zero();
  }

  void resumeFromPopup() {
    _paused = false;
    _tiltBehavior?.paused = false;
    _tiltBehavior?.resetGravity();
  }

  /// Called by the screen when the cubit says a star was collected.
  void markStarCollected(int challengeId) {
    _starComponents[challengeId]?.collected = true;
  }

  /// Called when all stars are collected → the end block dissolves.
  void removeEndBlock() {
    _endBlock?.dissolve();
  }

  void calibrate() => tiltController.calibrate();

  // ─── Update loop ─────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || _ball == null) return;

    if (_paused) return; // popup open, no game logic

    if (_airborneTimer > 0 && _airborneTimer < 999) _airborneTimer -= dt;

    // أثناء الضغط: قوة مستمرة للأعلى مع حد أقصى للسرعة (نفس Bodily)
    if (_isHolding) {
      final body = _ball!.body;
      if (body.linearVelocity.y > -_maxUpwardSpeed) {
        body.applyLinearImpulse(Vector2(0, -_liftForcePerFrame));
      }
    }

    // Motion trail
    _trailTimer -= dt;
    final speed = _ball!.body.linearVelocity.length;
    if (speed > _movingThreshold) {
      if (_trailTimer <= 0) {
        _trail.addLast(_ball!.body.position.clone());
        if (_trail.length > _maxTrail) _trail.removeFirst();
        _trailTimer = _trailInterval;
      }
    } else if (_trail.isNotEmpty && _trailTimer <= 0) {
      _trail.removeFirst();
      _trailTimer = 0.04;
    }

    // Star pickup detection — distance-based (simpler than physics contacts).
    final ballPos = _ball!.body.position;
    for (final entry in _starComponents.entries) {
      final comp = entry.value;
      if (comp.collected) continue;
      final d = (comp.position - ballPos).length;
      if (d <= (comp.size.x / 2) + 5) {
        onStarTouched(entry.key);
        break;
      }
    }

    if (_isAtEnd()) {
      _finished = true;
      onReachedEnd();
      return;
    }

    // وقعت بحفرة → سجّل FAILED وارجع الكرة للبداية (بدون خروج من اللعبة)
    if (_airborneTimer <= 0 && !_isHolding && _isOverHole()) {
      onFellInHole();
      _resetBall();
    }
  }

  bool _isOverHole() {
    final ball = _ball;
    if (ball == null) return false;
    final s = size;
    final pos = ball.body.position;
    for (final r in config.holeRects) {
      final rect = Rect.fromLTWH(
          r.left * s.x, r.top * s.y, r.width * s.x, r.height * s.y);
      if (rect.contains(Offset(pos.x, pos.y))) return true;
    }
    return false;
  }

  bool _isAtEnd() {
    final ball = _ball;
    if (ball == null) return false;
    final s = size;
    final pos = ball.body.position;
    final c = Offset(config.endPoint.dx * s.x, config.endPoint.dy * s.y);
    final rPx = config.endPointRadius * s.x;
    final dx = pos.x - c.dx, dy = pos.y - c.dy;
    return (dx * dx + dy * dy) <= (rPx * rPx);
  }

  @override
  void render(Canvas canvas) {
    // Motion trail underneath everything else.
    if (_trail.length > 1) {
      final list = _trail.toList();
      for (int i = 0; i < list.length; i++) {
        final progress = i / list.length;
        final alpha = (progress * 0.55).clamp(0.0, 0.55);
        final radius = (1.5 + progress * 3.5).clamp(1.5, 5.0);
        final paint = Paint()
          ..color = const Color(0xFFF9B919).withValues(alpha: alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(list[i].x, list[i].y), radius, paint);
      }
    }
    super.render(canvas);

    // ── توهج حول الكرة أثناء الضغط (نطة مرئية) ─────────────────────────
    if (_isHolding && _ball != null) {
      final pos = _ball!.body.position;

      // هالة صفرا كبيرة خارجية
      final outerGlow = Paint()
        ..color = const Color(0xFFF9B919).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pos.x, pos.y), 18, outerGlow);

      // هالة داخلية أكثف
      final innerGlow = Paint()
        ..color = const Color(0xFFF9B919).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pos.x, pos.y), 12, innerGlow);

      // خاتم أبيض حول الكرة
      final ringPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(pos.x, pos.y), 14, ringPaint);
    }
  }

  void _resetBall() {
    _ball?.resetToStart(_startPixel.clone());
    _airborneTimer = 0;
    _isHolding = false;
    _trail.clear();
    _trailTimer = 0;
    _tiltBehavior?.resetGravity();
  }
}

// ─────────────────────────── EndBlockComponent ──────────────────────────
// Reuses MazeWallComponent's collision logic — same static body shape,
// just tagged so we can remove it once all stars are collected.

class _EndBlockComponent extends BodyComponent {
  _EndBlockComponent({
    required this.blockPosition,
    required this.blockSize,
  }) : super(paint: Paint()..color = const Color(0xFFB55A2C));

  final Vector2 blockPosition;
  final Vector2 blockSize;

  bool _dissolving = false;
  double _dissolveAnim = 1.0;

  void dissolve() {
    _dissolving = true;
  }

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(blockSize.x / 2, blockSize.y / 2, Vector2.zero(), 0);
    final fixture = FixtureDef(shape, friction: 0.45, restitution: 0.25);
    final def = BodyDef(type: BodyType.static, position: blockPosition);
    return world.createBody(def)..createFixture(fixture);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dissolving) {
      _dissolveAnim -= dt * 1.5;
      if (_dissolveAnim <= 0) {
        _dissolveAnim = 0;
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_dissolveAnim <= 0) return;
    final r = Rect.fromCenter(
      center: Offset.zero,
      width: blockSize.x,
      height: blockSize.y,
    );
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(4));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = const Color(0xFF8B5A2B).withValues(alpha: _dissolveAnim),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = const Color(0xFF5C3A18).withValues(alpha: _dissolveAnim)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}