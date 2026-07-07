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

  // ── Hold-to-fly state ────────────────────────────────────────────────
  bool _isHolding = false;
  // القوة المستمرة للأعلى أثناء الضغط (تُطبَّق كل frame)
  static const double _liftForcePerFrame = 45.0;
  // الحد الأعلى للسرعة للأعلى — عشان الكرة ما تصعد بلا نهاية
  static const double _maxUpwardSpeed = 180.0;
  // جاذبية قوية لما ترفع إيدها — الكرة تنزل واضح
  static const double _fallGravity = 700.0;

  // نبطل نفشل من الحفرة أثناء الطيران (الكرة فوقها بالجو)
  double _airborneTimer = 0;

  // ── Motion trail (ذيل الحركة خلف الكرة) ──────────────────────────────
  final Queue<Vector2> _trail = Queue();
  static const int _maxTrail = 15;
  // نضيف نقطة كل هالفترة (بالثواني)
  static const double _trailInterval = 0.02;
  double _trailTimer = 0;
  // الكرة تعتبر متحركة لما سرعتها فوق هالحد
  static const double _movingThreshold = 20.0;

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
      final rect = Rect.fromLTWH(
          r.left * s.x, r.top * s.y, r.width * s.x, r.height * s.y);
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

  // ── Public: hold to fly ─────────────────────────────────────────────
  void startHold() {
    if (_ball == null || _finished) return;
    _isHolding = true;
    // فور الضغط: خفف الـ damping عشان الحركة تبقى واضحة
    _ball!.setJumpingPhysics(true);
    // جاذبية صفر أثناء الضغط — الكرة بتطير للأعلى بحرية
    world.gravity = Vector2.zero();
    _airborneTimer = 999; // ما نفشل من الحفر أثناء الطيران
  }

  void stopHold() {
    if (!_isHolding) return;
    _isHolding = false;
    // نطبّق جاذبية قوية للأسفل عشان تنزل واضح
    world.gravity = Vector2(0, _fallGravity);
    // بعد ثانية، نرجع للـ tilt الطبيعي
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isHolding && _ball != null) {
        _ball!.setJumpingPhysics(false);
        _tiltBehavior?.resetGravity();
        _airborneTimer = 0;
      }
    });
  }

  // ── Also keep tap-jump API to satisfy existing callers ──────────────
  void handleTap() {
    // No-op الآن — التحكم صار بالضغط والإفلات
  }

  // ── Detection ──────────────────────────────────────────────────────────
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

  // ── Update loop ─────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || _ball == null) return;

    if (_airborneTimer > 0 && _airborneTimer < 999) _airborneTimer -= dt;

    // أثناء الضغط: طبّق قوة مستمرة للأعلى مع حد أقصى للسرعة
    if (_isHolding) {
      final body = _ball!.body;
      if (body.linearVelocity.y > -_maxUpwardSpeed) {
        body.applyLinearImpulse(Vector2(0, -_liftForcePerFrame));
      }
    }

    // ── تحديث ذيل الحركة ────────────────────────────────────────────────
    _trailTimer -= dt;
    final speed = _ball!.body.linearVelocity.length;
    if (speed > _movingThreshold) {
      if (_trailTimer <= 0) {
        _trail.addLast(_ball!.body.position.clone());
        if (_trail.length > _maxTrail) _trail.removeFirst();
        _trailTimer = _trailInterval;
      }
    } else {
      // الكرة واقفة → تلاشي الذيل تدريجياً
      if (_trail.isNotEmpty && _trailTimer <= 0) {
        _trail.removeFirst();
        _trailTimer = 0.04;
      }
    }

    if (_isAtEnd()) {
      _finished = true;
      onReachedEnd();
      return;
    }

    // فشل: وقعت بحفرة (بس مش أثناء الطيران)
    if (_airborneTimer <= 0 && !_isHolding && _isOverHole()) {
      onFellInHole();
      _resetBall();
    }
  }

  // ── Render توهج أثناء الضغط ────────────────────────────────────────────
  @override
  void render(Canvas canvas) {
    // ── ارسمي الذيل قبل الكرة (تحتها) ──────────────────────────────────
    if (_trail.length > 1) {
      final list = _trail.toList();
      // نقاط متلاشية (الأقدم = شفافة أكتر)
      for (int i = 0; i < list.length; i++) {
        final progress = i / list.length; // 0..1 (أقدم → أحدث)
        final alpha = (progress * 0.55).clamp(0.0, 0.55);
        final radius = (1.5 + progress * 3.5).clamp(1.5, 5.0);
        final paint = Paint()
          ..color = const Color(0xFFF9B919).withValues(alpha: alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(list[i].x, list[i].y), radius, paint);
      }
    }

    // الكرة والجدران يرسموا فوق الذيل
    super.render(canvas);

    if (_isHolding && _ball != null) {
      final pos = _ball!.body.position;
      // هالة صفرا حول الكرة
      final glowPaint = Paint()
        ..color = const Color(0xFFF9B919).withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pos.x, pos.y), 12, glowPaint);

      final ringPaint = Paint()
        ..color = const Color(0xFFF9B919).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(pos.x, pos.y), 15, ringPaint);
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

  void calibrate() => tiltController.calibrate();
}