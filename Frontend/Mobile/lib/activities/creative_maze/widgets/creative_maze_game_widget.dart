import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../../maze_engine/physics/maze_ball_component.dart';
import '../../../maze_engine/physics/maze_wall_component.dart';
import '../../../maze_engine/physics/tilt_gravity_behavior.dart';
import '../../../maze_engine/tilt/tilt_controller.dart';
import '../config/creative_maze_level_config.dart';

/// Creative Maze game — uses the hand-drawn WALLS from the level config
/// (wallRects on the white gaps). The ball collides with them and stays on
/// the orange path.
class CreativeMazeGame extends Forge2DGame {
  CreativeMazeGame({
    required this.tiltController,
    required this.config,
    required this.onReachedEnd,
    this.showWalls = false,
  }) : super(gravity: Vector2.zero(), zoom: 1);

  final TiltController tiltController;
  final CreativeMazeLevelConfig config;
  final VoidCallback onReachedEnd;
  final bool showWalls;

  bool _worldCreated = false;
  bool _reachedEnd = false;
  MazeBallComponent? _ball;
  late Vector2 _endPixel;
  late double _endRadiusPixel;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    tiltController.start();
    await add(TiltGravityBehavior(
      tiltController: tiltController,
      gravityScale: 120.0,
    ));
  }

  @override
  void onRemove() {
    tiltController.stop();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (_worldCreated || gameSize.x <= 0 || gameSize.y <= 0) return;
    _worldCreated = true;

    final w = gameSize.x;
    final h = gameSize.y;

    _endPixel = Vector2(config.endPoint.dx * w, config.endPoint.dy * h);
    _endRadiusPixel = config.endPointRadius * ((w + h) / 2);

    _addBoundaries(gameSize);

    final wallColor =
        showWalls ? const Color(0x553F51B5) : const Color(0x00000000);
    for (final r in config.wallRects) {
      final cx = (r.left + r.width / 2) * w;
      final cy = (r.top + r.height / 2) * h;
      final sw = r.width * w;
      final sh = r.height * h;
      if (sw <= 0 || sh <= 0) continue;
      add(
        MazeWallComponent(
          position: Vector2(cx, cy),
          size: Vector2(sw, sh),
          color: wallColor,
        ),
      );
    }

    final ball = MazeBallComponent(
      startPosition: Vector2(config.startPoint.dx * w, config.startPoint.dy * h),
      radius: 5,
      color: const Color(0xFF2E7D32),
    );
    _ball = ball;
    add(ball);
  }

  void _addBoundaries(Vector2 gameSize) {
    const t = 12.0;
    const edge = Color(0x00000000);
    addAll([
      MazeWallComponent(
        position: Vector2(gameSize.x / 2, gameSize.y - t / 2),
        size: Vector2(gameSize.x, t),
        color: edge,
      ),
      MazeWallComponent(
        position: Vector2(gameSize.x / 2, t / 2),
        size: Vector2(gameSize.x, t),
        color: edge,
      ),
      MazeWallComponent(
        position: Vector2(t / 2, gameSize.y / 2),
        size: Vector2(t, gameSize.y),
        color: edge,
      ),
      MazeWallComponent(
        position: Vector2(gameSize.x - t / 2, gameSize.y / 2),
        size: Vector2(t, gameSize.y),
        color: edge,
      ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_reachedEnd) return;
    final ball = _ball;
    if (ball == null || !ball.isMounted) return;

    final pos = ball.body.position;
    final dist = pos.distanceTo(_endPixel);
    if (dist <= _endRadiusPixel) {
      _reachedEnd = true;
      onReachedEnd();
    }
  }
}