import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../maze_engine/physics/maze_ball_component.dart';
import '../../maze_engine/physics/maze_wall_component.dart';
import '../../maze_engine/physics/tilt_gravity_behavior.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import 'package:flame/components.dart';


/// Proves the shared tilt engine (TiltController + TiltGravityBehavior +
/// MazeBallComponent/MazeWallComponent) actually works end to end.
///
/// This is NOT a real maze — no win condition, no levels, no layout. Same
/// scope as the existing `forge2d_test_screen.dart`, just tilt-driven
/// instead of constant gravity. Every future maze (cognitive, creative,
/// etc.) will build its real layout on top of these same shared pieces.
class MazeEngineTestScreen extends StatefulWidget {
  const MazeEngineTestScreen({super.key});

  @override
  State<MazeEngineTestScreen> createState() => _MazeEngineTestScreenState();
}

class _MazeEngineTestScreenState extends State<MazeEngineTestScreen> {
  late final TiltController _tiltController;
  late _MazeEngineTestGame _game;

  @override
  void initState() {
    super.initState();
    _tiltController = TiltController();
    _game = _MazeEngineTestGame(tiltController: _tiltController);
  }

  @override
  void dispose() {
    _tiltController.stop();
    super.dispose();
  }

  void _restart() {
    setState(() {
      _game = _MazeEngineTestGame(tiltController: _tiltController);
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
                      child: GameWidget(game: _game),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TiltCalibrationButton(tiltController: _tiltController),
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
          color: AppColors.textPrimary,
        ),
        const Expanded(
          child: Text(
            'محرك المتاهة — تجربة الميلان',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF123835),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: _restart,
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.textPrimary,
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
        'ميلي الجهاز يمين/شمال أو للأمام/الخلف لتحريك الكرة داخل الصندوق. إذا الكرة تتحرك لوحدها، اضغطي زر المعايرة بالأسفل.',
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
}

class _MazeEngineTestGame extends Forge2DGame {
  _MazeEngineTestGame({required this.tiltController})
      : super(gravity: Vector2.zero(), zoom: 1);

  final TiltController tiltController;

  bool _worldCreated = false;

  @override
  Color backgroundColor() => const Color(0xFF123835);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    tiltController.start();
    await add(TiltGravityBehavior(tiltController: tiltController));

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
  void onRemove() {
    tiltController.stop();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    if (_worldCreated || gameSize.x <= 0 || gameSize.y <= 0) return;
    _worldCreated = true;

    _addBoundaries(gameSize);

    add(
      MazeBallComponent(
        startPosition: Vector2(gameSize.x / 2, gameSize.y / 2),
        radius: 22,
        color: const Color(0xFFF9B919),
      ),
    );
  }

  void _addBoundaries(Vector2 gameSize) {
    const wallThickness = 18.0;

    addAll([
      // Floor
      MazeWallComponent(
        position: Vector2(gameSize.x / 2, gameSize.y - wallThickness / 2),
        size: Vector2(gameSize.x, wallThickness),
        color: const Color(0xFFFFE7A8),
      ),

      // Left wall
      MazeWallComponent(
        position: Vector2(wallThickness / 2, gameSize.y / 2),
        size: Vector2(wallThickness, gameSize.y),
        color: const Color(0xFFE9FAF6),
      ),

      // Right wall
      MazeWallComponent(
        position: Vector2(gameSize.x - wallThickness / 2, gameSize.y / 2),
        size: Vector2(wallThickness, gameSize.y),
        color: const Color(0xFFE9FAF6),
      ),

      // Top wall
      MazeWallComponent(
        position: Vector2(gameSize.x / 2, wallThickness / 2),
        size: Vector2(gameSize.x, wallThickness),
        color: const Color(0xFFE9FAF6),
      ),
    ]);
  }
}
