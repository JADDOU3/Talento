import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../../../maze_engine/physics/maze_ball_component.dart';
import '../../../../maze_engine/physics/maze_wall_component.dart';
import '../../../../maze_engine/physics/tilt_gravity_behavior.dart';
import '../../../../maze_engine/tilt/tilt_controller.dart';
import '../config/emotional_maze_level_config.dart';

class EmotionalMazeGame extends Forge2DGame {
  EmotionalMazeGame({
    required this.config,
    required this.tiltController,
    required this.onFinished,
  }) : super(gravity: Vector2.zero(), zoom: 1);

  final MazeLevelConfig config;
  final TiltController tiltController;
  final VoidCallback onFinished;

  MazeBallComponent? _ball;
  TiltGravityBehavior? _tiltBehavior;
  Vector2 _startPixel = Vector2.zero();

  bool _worldBuilt = false;
  bool _finished = false;

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
  }

  bool _ballAtAnyEndpoint() {
    final ball = _ball;
    if (ball == null) return false;
    final s = size;
    final pos = ball.body.position;
    final rPx = config.endPointRadius * s.x;

    for (final ep in config.endPoints) {
      final c = Offset(ep.dx * s.x, ep.dy * s.y);
      final dx = pos.x - c.dx, dy = pos.y - c.dy;
      if ((dx * dx + dy * dy) <= (rPx * rPx)) return true;
    }
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || _ball == null) return;

    if (_ballAtAnyEndpoint()) {
      _finished = true;
      onFinished();
    }
  }

  void calibrate() => tiltController.calibrate();
}