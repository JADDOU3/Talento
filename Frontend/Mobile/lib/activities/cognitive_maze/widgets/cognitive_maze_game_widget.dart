import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../../../maze_engine/physics/maze_ball_component.dart';
import '../../../../maze_engine/physics/maze_wall_component.dart';
import '../../../../maze_engine/physics/tilt_gravity_behavior.dart';
import '../../../../maze_engine/tilt/tilt_controller.dart';
import '../config/cognitive_maze_level_config.dart';

/// Same tilt-driven ball-in-a-maze engine as BodilyMazeGame, minus the two
/// things Cognitive Maze doesn't have:
/// - no tap-to-jump (there's nothing to jump over)
/// - no holes (a "wrong path" isn't a hazard, it's an answer)
///
/// Instead, there are multiple endpoints — one per answer choice — and the
/// game reports back which one the ball reached via [onCorrectAnswer] or
/// [onWrongAnswer]. On a wrong answer, the ball is reset to start
/// immediately, same mechanic Bodily Maze already uses for holes.
class CognitiveMazeGame extends Forge2DGame {
  CognitiveMazeGame({
    required this.config,
    required this.correctEndpointIndex,
    required this.tiltController,
    required this.onCorrectAnswer,
    required this.onWrongAnswer,
  }) : super(gravity: Vector2.zero(), zoom: 1);

  final CognitiveMazeLevelConfig config;

  /// Index into config.endPoints that is the correct answer for this level
  /// (i.e. CognitiveMazeLevel.correctChoiceIndex).
  final int correctEndpointIndex;

  final TiltController tiltController;
  final VoidCallback onCorrectAnswer;

  /// Called with the index of the wrong endpoint the ball reached.
  final void Function(int endpointIndex) onWrongAnswer;

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

  /// Returns the index of the endpoint the ball is currently inside, or -1
  /// if it isn't at any endpoint.
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

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || _ball == null) return;

    final reachedIndex = _endpointBallIsAt();
    if (reachedIndex == -1) return;

    if (reachedIndex == correctEndpointIndex) {
      _finished = true;
      onCorrectAnswer();
    } else {
      _resetBall();
      onWrongAnswer(reachedIndex);
    }
  }

  void _resetBall() {
    _ball?.resetToStart(_startPixel.clone());
  }

  void calibrate() => tiltController.calibrate();
}