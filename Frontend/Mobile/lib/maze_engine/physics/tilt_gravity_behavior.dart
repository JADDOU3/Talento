import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../tilt/tilt_controller.dart';

/// The missing link between the sensor layer and the physics layer.
///
/// Every frame, reads [TiltController]'s calibrated tilt and sets the
/// Forge2D world's gravity accordingly — replacing the prototype's constant
/// `Vector2(0, 900)` from `forge2d_test_screen.dart`.
///
/// Add this once to any maze's [Forge2DGame]:
/// ```dart
/// await add(TiltGravityBehavior(tiltController: myTiltController));
/// ```
class TiltGravityBehavior extends Component with HasGameReference<Forge2DGame> {
  TiltGravityBehavior({
    required this.tiltController,
    this.gravityScale = _defaultGravityScale,
    this.maxGravityMagnitude = _defaultMaxGravityMagnitude,
  });

  final TiltController tiltController;

  /// Converts a raw calibrated accelerometer reading (roughly -10..10,
  /// since it's measured in m/s²) into a Box2D gravity magnitude.
  ///
  /// 90.0 keeps a full tilt (~9.8 m/s²) in the same ballpark as the
  /// prototype's constant downward gravity of 900 — this is a reasoned
  /// starting point (not a previously-proven constant like the sensor
  /// values), and is expected to be tuned by feel once a real maze exists,
  /// the same way `_movementSensitivity` was tuned from 7.5 to 12.0 in the
  /// sensors prototype.
  /// Tuned down from 90.0 → 45.0 so the ball is slower and easier for a
  /// child to control (the maze manager reported it moved too fast).
  static const double _defaultGravityScale = 45.0;

  /// Safety clamp so an extreme/noisy sensor reading can't make the world
  /// gravity unstable.
  static const double _defaultMaxGravityMagnitude = 1500.0;

  final double gravityScale;
  final double maxGravityMagnitude;

  /// Resets gravity back to tilt-driven mode after a jump.
  void resetGravity() {
    game.world.gravity = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!tiltController.isRunning) return;

    // Same sign convention as the sensors prototype: X is inverted so
    // tilting right moves the ball right, Y stays as-is (down is positive
    // in both the accelerometer reading and Flame's screen space).
    final gx = (-tiltController.tiltX * gravityScale)
        .clamp(-maxGravityMagnitude, maxGravityMagnitude);
    final gy = (tiltController.tiltY * gravityScale)
        .clamp(-maxGravityMagnitude, maxGravityMagnitude);

    game.world.gravity = Vector2(gx, gy);
  }
}
