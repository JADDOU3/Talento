import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
/*
Talento Forge2D Prototype

Package chosen: flame_forge2d
Version used: 0.19.2+4

Purpose:
Test if Forge2D is suitable for Talento physics-based mini games,
especially the future tilt maze.

How it differs from Flame:
- Flame is the game engine: rendering, game loop, components, input, and overlays.
- Forge2D is the physics engine: bodies, gravity, collisions, and forces.
- For physics-heavy games, Forge2D works inside Flame through flame_forge2d.

Prototype behavior:
- Ball falls because of gravity.
- Ball bounces off the floor and walls.
- Tap spawns a new ball.
- FPS counter is shown.
- Runs inside a normal Flutter screen.

What works:
- Forge2D integrates with Flame.
- Gravity, bouncing, walls, and dynamic balls work.
- Multiple physics bodies can be created during runtime.


- This prototype does not use device tilt yet.
- Final maze needs sensors_plus to convert device tilt into movement/force.

Maintenance note:
flame_forge2d is published by the Flame team and has documentation,
GitHub issue tracking, and multiple published versions. Still, before production
use, compatibility and open issues should be checked again.

Verdict:
Use Forge2D only for physics-heavy Talento activities.

Final maze recommendation:
Flame + Forge2D + sensors_plus
*/

class Forge2DTestScreen extends StatefulWidget {
  const Forge2DTestScreen({super.key});

  @override
  State<Forge2DTestScreen> createState() => _Forge2DTestScreenState();
}

class _Forge2DTestScreenState extends State<Forge2DTestScreen> {
  late TalentoForge2DGame _game;

  @override
  void initState() {
    super.initState();
    _game = TalentoForge2DGame();
  }

  void _restartGame() {
    setState(() {
      _game = TalentoForge2DGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE9FAF6),
                Color(0xFFFFF9EA),
                Color(0xFFFFEEF3),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          GameWidget(game: _game),
                          _buildFlutterHint(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRestartButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF123835),
        ),
        const Expanded(
          child: Text(
            'تجربة Forge2D',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF123835),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: _restartGame,
          icon: const Icon(Icons.refresh_rounded),
          color: const Color(0xFF123835),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Text(
        'اضغطي داخل منطقة اللعبة لإضافة كرة جديدة. هذه التجربة تختبر الجاذبية، الارتداد، والتصادم مع الجدران.',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Color(0xFF123835),
          fontSize: 14,
          height: 1.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFlutterHint() {
    return Positioned(
      top: 14,
      right: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: Color(0xFF10A896),
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              'Tap = كرة جديدة',
              style: TextStyle(
                color: Color(0xFF123835),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestartButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _restartGame,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text(
          'إعادة تجربة الفيزياء',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10A896),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}

class TalentoForge2DGame extends Forge2DGame with TapCallbacks {
  TalentoForge2DGame()
      : super(
    gravity: Vector2(0, 900),
    zoom: 1,
  );

  final Random _random = Random();
  bool _worldCreated = false;

  @override
  Color backgroundColor() => const Color(0xFF123835);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      FpsTextComponent(
        position: Vector2(14, 14),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    if (_worldCreated || gameSize.x <= 0 || gameSize.y <= 0) return;

    _worldCreated = true;

    _addBoundaries(gameSize);

    add(
      _PhysicsBall(
        startPosition: Vector2(gameSize.x / 2, 70),
        radius: 22,
        color: const Color(0xFFF9B919),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (size.x <= 0 || size.y <= 0) return;

    final x = 60 + _random.nextDouble() * (size.x - 120);

    add(
      _PhysicsBall(
        startPosition: Vector2(x, 70),
        radius: 18 + _random.nextDouble() * 8,
        color: _randomBallColor(),
      ),
    );
  }

  Color _randomBallColor() {
    const colors = [
      Color(0xFFF9B919),
      Color(0xFF10A896),
      Color(0xFF48C5DC),
      Color(0xFFEC6886),
    ];

    return colors[_random.nextInt(colors.length)];
  }

  void _addBoundaries(Vector2 gameSize) {
    const wallThickness = 18.0;

    addAll([
      // Floor
      _PhysicsWall(
        position: Vector2(gameSize.x / 2, gameSize.y - wallThickness / 2),
        size: Vector2(gameSize.x, wallThickness),
        color: const Color(0xFFFFE7A8),
      ),

      // Left wall
      _PhysicsWall(
        position: Vector2(wallThickness / 2, gameSize.y / 2),
        size: Vector2(wallThickness, gameSize.y),
        color: const Color(0xFFE9FAF6),
      ),

      // Right wall
      _PhysicsWall(
        position: Vector2(gameSize.x - wallThickness / 2, gameSize.y / 2),
        size: Vector2(wallThickness, gameSize.y),
        color: const Color(0xFFE9FAF6),
      ),

      // Top wall
      _PhysicsWall(
        position: Vector2(gameSize.x / 2, wallThickness / 2),
        size: Vector2(gameSize.x, wallThickness),
        color: const Color(0xFFE9FAF6),
      ),
    ]);
  }
}

class _PhysicsBall extends BodyComponent {
  _PhysicsBall({
    required this.startPosition,
    required this.radius,
    required Color color,
  }) : super(
    paint: Paint()..color = color,
  );

  final Vector2 startPosition;
  final double radius;

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
      linearDamping: 0.08,
      angularDamping: 0.08,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-radius * 0.28, -radius * 0.28),
      radius * 0.25,
      highlightPaint,
    );
  }
}

class _PhysicsWall extends BodyComponent {
  _PhysicsWall({
    required this.position,
    required this.size,
    required Color color,
  }) : super(
    paint: Paint()..color = color,
  );

  @override
  final Vector2 position;
  final Vector2 size;

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        size.x / 2,
        size.y / 2,
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.45,
      restitution: 0.25,
    );

    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}