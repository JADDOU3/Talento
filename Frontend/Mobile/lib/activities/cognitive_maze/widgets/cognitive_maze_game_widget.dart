import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../../../maze_engine/physics/maze_ball_component.dart';
import '../../../../maze_engine/physics/maze_wall_component.dart';
import '../../../../maze_engine/physics/tilt_gravity_behavior.dart';
import '../../../../maze_engine/tilt/tilt_controller.dart';
import '../config/cognitive_maze_level_config.dart';

class CognitiveMazeGame extends Forge2DGame {
  CognitiveMazeGame({
    required this.config,
    this.correctEndpointIndex,
    required this.tiltController,
    required this.onCorrectAnswer,
    this.onWrongAnswer,
    this.onStarCollected,
  }) : super(gravity: Vector2.zero(), zoom: 1);

  final CognitiveMazeLevelConfig config;
  final int? correctEndpointIndex;
  final TiltController tiltController;
  final VoidCallback onCorrectAnswer;
  final void Function(int endpointIndex)? onWrongAnswer;
  final void Function(Color color, bool isTarget)? onStarCollected;

  MazeBallComponent? _ball;
  TiltGravityBehavior? _tiltBehavior;
  Vector2 _startPixel = Vector2.zero();

  bool _worldBuilt = false;
  bool _finished = false;

  final Map<int, CircleComponent> _starComponents = {};
  final Set<int> _collectedStarIndices = {};
  final Set<Color> _collectedTargetColors = {};
  bool _touchedWrongColor = false;

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
      final rect = Rect.fromLTWH(r.left * s.x, r.top * s.y, r.width * s.x, r.height * s.y);
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

    if (config.isStarCollectLevel) {
      for (int i = 0; i < config.stars.length; i++) {
        final star = config.stars[i];
        final center = Vector2(star.position.dx * s.x, star.position.dy * s.y);
        final radiusPx = star.radius * s.x;
        final comp = CircleComponent(
          radius: radiusPx,
          position: center,
          anchor: Anchor.center,
          paint: Paint()..color = star.color,
        );
        _starComponents[i] = comp;
        add(comp);
      }
    }
  }

  int _endpointBallIsAt() {
    final ball = _ball;
    if (ball == null) return -1;
    final s = size;
    final pos = ball.body.position;
    final rPx = config.endPointRadius * s.x;

    for (int i = 0; i < config.endPoints.length; i++) {
      final c = Offset(config.endPoints[i].dx * s.x, config.endPoints[i].dy * s.y);
      final dx = pos.x - c.dx, dy = pos.y - c.dy;
      if ((dx * dx + dy * dy) <= (rPx * rPx)) return i;
    }
    return -1;
  }

  void _checkStarPickups() {
    final ball = _ball;
    if (ball == null) return;
    final s = size;
    final pos = ball.body.position;

    for (int i = 0; i < config.stars.length; i++) {
      if (_collectedStarIndices.contains(i)) continue;
      final star = config.stars[i];
      final c = Offset(star.position.dx * s.x, star.position.dy * s.y);
      final rPx = star.radius * s.x;
      final dx = pos.x - c.dx, dy = pos.y - c.dy;
      if ((dx * dx + dy * dy) > (rPx * rPx)) continue;

      _collectedStarIndices.add(i);
      // Hide visually without depending on a HasPaint.opacity API.
      _starComponents[i]?.paint = Paint()..color = const Color(0x00000000);

      final isTarget = config.targetColors.contains(star.color);
      if (isTarget) {
        _collectedTargetColors.add(star.color);
      } else {
        _touchedWrongColor = true;
      }
      onStarCollected?.call(star.color, isTarget);
      // Note: no completion check here anymore — completion only happens
      // when the ball reaches the endpoint (see _checkStarEndpoint).
    }
  }

  void _checkStarEndpoint() {
    if (config.endPoints.isEmpty) return;
    final ball = _ball;
    if (ball == null) return;
    final s = size;
    final pos = ball.body.position;
    final rPx = config.endPointRadius * s.x;
    final ep = config.endPoints.first;
    final c = Offset(ep.dx * s.x, ep.dy * s.y);
    final dx = pos.x - c.dx, dy = pos.y - c.dy;
    if ((dx * dx + dy * dy) > (rPx * rPx)) return; // not there yet

    final hasAllColors = _collectedTargetColors.length == config.targetColors.length;
    if (hasAllColors && !_touchedWrongColor) {
      _finished = true;
      onCorrectAnswer();
    } else {
      _resetStarLevel();
      onWrongAnswer?.call(0);
    }
  }

  void _resetStarLevel() {
    _collectedStarIndices.clear();
    _collectedTargetColors.clear();
    _touchedWrongColor = false;
    for (int i = 0; i < config.stars.length; i++) {
      _starComponents[i]?.paint = Paint()..color = config.stars[i].color;
    }
    _resetBall();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || _ball == null) return;

    if (config.isStarCollectLevel) {
      _checkStarPickups();
      _checkStarEndpoint();
      return;
    }

    final reachedIndex = _endpointBallIsAt();
    if (reachedIndex == -1) return;

    if (reachedIndex == correctEndpointIndex) {
      _finished = true;
      onCorrectAnswer();
    } else {
      _resetBall();
      onWrongAnswer?.call(reachedIndex);
    }
  }

  void _resetBall() {
    _ball?.resetToStart(_startPixel.clone());
  }

  void calibrate() => tiltController.calibrate();
}