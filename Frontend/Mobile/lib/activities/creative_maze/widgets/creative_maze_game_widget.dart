import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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
    required this.onCoinPicked,
    this.showWalls = false,
  }) : super(gravity: Vector2.zero(), zoom: 1);

  final TiltController tiltController;
  final CreativeMazeLevelConfig config;
  final VoidCallback onReachedEnd;

  /// Called with the coin's index when the ball first touches it.
  final void Function(int coinIndex) onCoinPicked;

  final bool showWalls;

  bool _worldCreated = false;
  bool _reachedEnd = false;
  MazeBallComponent? _ball;
  late Vector2 _endPixel;
  late double _endRadiusPixel;

  // Coin state — pixel positions + which indexes were picked
  final List<Vector2> _coinPixels = [];
  final Set<int> _pickedCoinIndexes = <int>{};
  static const double _coinPickRadius = 16.0;
  static const double _coinDrawRadius = 12.0;

  // Load the company icon once and cache it as a ui.Image so we can draw
  // it on the canvas each frame from the Flutter asset path
  // assets/icons/icon.png (Flame's default images folder is
  // assets/images/, which doesn't work for us here).
  ui.Image? _coinImage;

  // ── Motion trail (نفس Bodily Maze) ──────────────────────────────────
  final Queue<Vector2> _trail = Queue();
  static const int _maxTrail = 15;
  static const double _trailInterval = 0.02;
  double _trailTimer = 0;
  static const double _movingThreshold = 20.0;

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

    // Load the company icon from assets/icons/icon.png (not the Flame
    // default assets/images/ folder). We load via rootBundle so we can
    // point at any asset path we like.
    try {
      final data = await rootBundle.load('assets/icons/icon.png');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      _coinImage = frame.image;
    } catch (_) {
      _coinImage = null;
    }
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
      radius: config.ballRadius,
      color: const Color(0xFFF9B919),
    );
    _ball = ball;
    add(ball);

    // Compute pixel positions of every coin from the normalized config.
    _coinPixels.clear();
    for (final p in config.coinPositions) {
      _coinPixels.add(Vector2(p.dx * w, p.dy * h));
    }
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

    // ── تحديث ذيل الحركة ──────────────────────────────────────────────
    _trailTimer -= dt;
    final speed = ball.body.linearVelocity.length;
    if (speed > _movingThreshold) {
      if (_trailTimer <= 0) {
        _trail.addLast(pos.clone());
        if (_trail.length > _maxTrail) _trail.removeFirst();
        _trailTimer = _trailInterval;
      }
    } else if (_trail.isNotEmpty && _trailTimer <= 0) {
      _trail.removeFirst();
      _trailTimer = 0.04;
    }

    // Coin pickup: any coin within radius is collected (once).
    for (int i = 0; i < _coinPixels.length; i++) {
      if (_pickedCoinIndexes.contains(i)) continue;
      final d = pos.distanceTo(_coinPixels[i]);
      if (d <= _coinPickRadius) {
        _pickedCoinIndexes.add(i);
        onCoinPicked(i);
      }
    }

    final dist = pos.distanceTo(_endPixel);
    if (dist <= _endRadiusPixel) {
      _reachedEnd = true;
      onReachedEnd();
    }
  }

  @override
  void render(Canvas canvas) {
    // ── ذيل الحركة (نفس Bodily Maze) — تحت كل شي ──────────────────────
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
    // Draw coins on top of the maze image but below the ball halo.
    for (int i = 0; i < _coinPixels.length; i++) {
      if (_pickedCoinIndexes.contains(i)) continue;
      final p = _coinPixels[i];

      // Soft gold halo behind the icon so it stands out on the maze.
      canvas.drawCircle(
        Offset(p.x, p.y),
        _coinDrawRadius + 4,
        Paint()..color = const Color(0xFFF9B919).withValues(alpha: 0.35),
      );

      final image = _coinImage;
      if (image != null) {
        // ارسم الأيقونة بمركز موقع الكوين
        final srcRect = Rect.fromLTWH(
          0, 0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
        final dstRect = Rect.fromCenter(
          center: Offset(p.x, p.y),
          width: _coinDrawRadius * 2,
          height: _coinDrawRadius * 2,
        );
        canvas.drawImageRect(image, srcRect, dstRect, Paint());
      } else {
        // Fallback if icon.png wasn't loaded: a filled gold coin.
        canvas.drawCircle(
          Offset(p.x, p.y),
          _coinDrawRadius,
          Paint()..color = const Color(0xFFF9B919),
        );
        canvas.drawCircle(
          Offset(p.x, p.y),
          _coinDrawRadius,
          Paint()
            ..color = const Color(0xFF8B5A00)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }
}