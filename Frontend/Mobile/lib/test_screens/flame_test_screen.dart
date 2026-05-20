import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/*
Talento Flame Prototype

Package chosen: flame
Version used: 1.35.1

Purpose:
Test whether Flame is suitable for Talento in-app mini games.

Why Flame:
- Works inside a normal Flutter screen using GameWidget.
- Allows Flutter UI to coexist with the game, such as score, timer, buttons, and overlays.
- Supports game loops, components, movement, collision detection, and touch/game input.
- Suitable for Talento mini games such as maze games, collecting games, sorting games, reaction games, and puzzle-like activities.

Prototype behavior:
- A simple character moves left and right using Flutter on-screen buttons.
- A collectible item appears randomly inside the game area.
- Collision detection is used between the character and the collectible.
- Score is displayed as a Flutter widget overlay, not as Flame UI.
- A 30-second timer is displayed as a Flutter overlay.
- When time reaches 0, the game stops and shows a Game Over overlay.
- The game can be restarted.

What works:
- Flame can live inside a Flutter widget tree.
- Flutter UI and Flame game content can coexist on the same screen.
- Basic movement, random spawning, collision detection, score updates, and timer logic work.

What does not work / limitations:
- This prototype uses simple shapes instead of real sprites or animations.
- Asset pipeline testing for sprites, audio, and tilemaps still needs a larger prototype.
- Performance should be tested on a real mid-range Android device.

Verdict:
Use Flame as the base engine for Talento app-only mini games.

Recommended use case:
Maze games, collecting games, sorting games, memory games, reaction games,
and interactive activity-kit mini games. Forge2D can be added when real physics is needed.
*/

class FlameTestScreen extends StatefulWidget {
  const FlameTestScreen({super.key});

  @override
  State<FlameTestScreen> createState() => _FlameTestScreenState();
}

class _FlameTestScreenState extends State<FlameTestScreen> {
  late final ValueNotifier<int> _scoreNotifier;
  late final ValueNotifier<int> _timeLeftNotifier;
  late final ValueNotifier<bool> _gameOverNotifier;
  late TalentoFlameGame _game;

  @override
  void initState() {
    super.initState();

    _scoreNotifier = ValueNotifier<int>(0);
    _timeLeftNotifier = ValueNotifier<int>(30);
    _gameOverNotifier = ValueNotifier<bool>(false);

    _game = TalentoFlameGame(
      scoreNotifier: _scoreNotifier,
      timeLeftNotifier: _timeLeftNotifier,
      gameOverNotifier: _gameOverNotifier,
    );
  }

  @override
  void dispose() {
    _scoreNotifier.dispose();
    _timeLeftNotifier.dispose();
    _gameOverNotifier.dispose();
    super.dispose();
  }

  void _restartGame() {
    _scoreNotifier.value = 0;
    _timeLeftNotifier.value = 30;
    _gameOverNotifier.value = false;

    setState(() {
      _game = TalentoFlameGame(
        scoreNotifier: _scoreNotifier,
        timeLeftNotifier: _timeLeftNotifier,
        gameOverNotifier: _gameOverNotifier,
      );
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
                          _buildFlutterOverlay(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildControlButtons(),
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
            'تجربة Flame',
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
          color: Color(0xFF123835),
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
        'حرّكي الشخصية يمين وشمال واجمعي النجمة. العداد والوقت هنا Flutter UI فوق لعبة Flame.',
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

  Widget _buildFlutterOverlay() {
    return Stack(
      children: [
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _scoreNotifier,
                  builder: (context, score, _) {
                    return _OverlayBadge(
                      icon: Icons.star_rounded,
                      label: 'Score: $score',
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _timeLeftNotifier,
                  builder: (context, timeLeft, _) {
                    return _OverlayBadge(
                      icon: Icons.timer_rounded,
                      label: 'Time: $timeLeft',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _gameOverNotifier,
          builder: (context, isGameOver, _) {
            if (!isGameOver) return const SizedBox.shrink();

            return Container(
              color: Colors.black.withValues(alpha: 0.58),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sports_esports_rounded,
                        size: 48,
                        color: Color(0xFF10A896),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'انتهى الوقت!',
                        style: TextStyle(
                          color: Color(0xFF123835),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: _scoreNotifier,
                        builder: (context, score, _) {
                          return Text(
                            'النتيجة: $score',
                            style: const TextStyle(
                              color: Color(0xFF60706D),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: _restartGame,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة التجربة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10A896),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: _GameControlButton(
            icon: Icons.keyboard_arrow_right_rounded,
            label: 'يمين',
            onTapDown: () => _game.moveRight(),
            onTapUp: () => _game.stopMoving(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _GameControlButton(
            icon: Icons.keyboard_arrow_left_rounded,
            label: 'شمال',
            onTapDown: () => _game.moveLeft(),
            onTapUp: () => _game.stopMoving(),
          ),
        ),
      ],
    );
  }
}

class TalentoFlameGame extends FlameGame with HasCollisionDetection {
  TalentoFlameGame({
    required this.scoreNotifier,
    required this.timeLeftNotifier,
    required this.gameOverNotifier,
  });

  final ValueNotifier<int> scoreNotifier;
  final ValueNotifier<int> timeLeftNotifier;
  final ValueNotifier<bool> gameOverNotifier;

  final Random _random = Random();

  late _PlayerComponent _player;
  late _CollectibleComponent _collectible;

  double _horizontalDirection = 0;
  double _timeLeft = 30;

  @override
  Color backgroundColor() => const Color(0xFF123835);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _player = _PlayerComponent(
      onCollectibleHit: _handleCollectibleHit,
    )
      ..position = Vector2(size.x / 2, size.y - 70)
      ..anchor = Anchor.center;

    _collectible = _CollectibleComponent()
      ..anchor = Anchor.center;

    add(_player);
    add(_collectible);

    _spawnCollectible();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOverNotifier.value) return;

    _timeLeft -= dt;

    final roundedTime = max(0, _timeLeft.ceil());
    if (timeLeftNotifier.value != roundedTime) {
      timeLeftNotifier.value = roundedTime;
    }

    if (_timeLeft <= 0) {
      gameOverNotifier.value = true;
      _horizontalDirection = 0;
      return;
    }

    _player.position.x += _horizontalDirection * _player.speed * dt;

    final minX = _player.size.x / 2;
    final maxX = size.x - (_player.size.x / 2);
    _player.position.x = _player.position.x.clamp(minX, maxX).toDouble();
  }

  void moveLeft() {
    if (gameOverNotifier.value) return;
    _horizontalDirection = -1;
  }

  void moveRight() {
    if (gameOverNotifier.value) return;
    _horizontalDirection = 1;
  }

  void stopMoving() {
    _horizontalDirection = 0;
  }

  void _handleCollectibleHit() {
    if (gameOverNotifier.value) return;

    scoreNotifier.value += 1;
    _spawnCollectible();
  }

  void _spawnCollectible() {
    final safeTop = 90.0;
    final safeBottom = max(safeTop + 20, size.y - 130);
    final safeLeft = 40.0;
    final safeRight = max(safeLeft + 20, size.x - 40);

    _collectible.position = Vector2(
      safeLeft + _random.nextDouble() * (safeRight - safeLeft),
      safeTop + _random.nextDouble() * (safeBottom - safeTop),
    );
  }
}

class _PlayerComponent extends RectangleComponent with CollisionCallbacks {
  _PlayerComponent({
    required this.onCollectibleHit,
  }) : super(
    size: Vector2(58, 58),
    paint: Paint()..color = const Color(0xFF10A896),
  );

  final VoidCallback onCollectibleHit;
  final double speed = 270;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final eyePaint = Paint()..color = Colors.white;

    canvas.drawCircle(
      Offset(size.x * 0.35, size.y * 0.38),
      5,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(size.x * 0.65, size.y * 0.38),
      5,
      eyePaint,
    );

    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(size.x * 0.32, size.y * 0.48, size.x * 0.36, 16),
      0,
      pi,
      false,
      smilePaint,
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is _CollectibleComponent) {
      onCollectibleHit();
    }
  }
}

class _CollectibleComponent extends CircleComponent with CollisionCallbacks {
  _CollectibleComponent()
      : super(
    radius: 18,
    paint: Paint()..color = const Color(0xFFF9B919),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(radius, radius);
    const points = 5;
    final outerRadius = radius * 0.72;
    final innerRadius = radius * 0.35;

    for (int i = 0; i < points * 2; i++) {
      final angle = (-pi / 2) + (i * pi / points);
      final currentRadius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + cos(angle) * currentRadius,
        center.dy + sin(angle) * currentRadius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, starPaint);
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.ltr,
        children: [
          Icon(
            icon,
            color: const Color(0xFF10A896),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: Color(0xFF123835),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameControlButton extends StatelessWidget {
  const _GameControlButton({
    required this.icon,
    required this.label,
    required this.onTapDown,
    required this.onTapUp,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE7A8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF123835),
              size: 32,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF123835),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}