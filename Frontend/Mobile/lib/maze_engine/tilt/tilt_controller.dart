import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Wraps the device accelerometer into a smoothed, calibrated tilt vector
/// that any future maze (cognitive, creative, etc.) can read every frame.
///
/// Reuses the exact constants already proven in
/// `test_screens/sensors_test_screen.dart`:
/// - smoothing: oldValue * 0.78 + newValue * 0.22
/// - sensitivity: 12.0
/// - tilt threshold: 1.2
/// - calibration: store the current smoothed reading as an offset and
///   subtract it from future readings, so "current phone position" becomes
///   the new neutral position.
///
/// Usage:
/// ```dart
/// final tilt = TiltController();
/// tilt.start();
/// // every frame / on demand:
/// final v = tilt.tiltVector; // Vector-ish (x, y) calibrated tilt
/// // when the player taps "calibrate":
/// tilt.calibrate();
/// // when leaving the screen:
/// tilt.stop();
/// ```
class TiltController {
  // ───────────────────────── Proven constants (do not change speculatively) ─
  static const double smoothingFactor = 0.78;
  static const double sensitivity = 12.0;
  static const double tiltThreshold = 1.2;

  StreamSubscription<AccelerometerEvent>? _subscription;

  double _rawX = 0;
  double _rawY = 0;
  double _rawZ = 0;

  double _smoothX = 0;
  double _smoothY = 0;
  double _smoothZ = 0;

  // Calibration offsets — the "neutral" phone position.
  double _calibrationX = 0;
  double _calibrationY = 0;

  bool _isRunning = false;

  /// Whether the controller is currently listening to the accelerometer.
  bool get isRunning => _isRunning;

  /// Calibrated, smoothed tilt on the X axis (left/right).
  double get tiltX => _smoothX - _calibrationX;

  /// Calibrated, smoothed tilt on the Y axis (forward/backward).
  double get tiltY => _smoothY - _calibrationY;

  /// Raw (unsmoothed, uncalibrated) accelerometer reading — exposed for
  /// debug screens that want to show it, same as the original prototype.
  double get rawX => _rawX;
  double get rawY => _rawY;
  double get rawZ => _rawZ;

  /// True once the tilt magnitude crosses [tiltThreshold] on either axis.
  bool get isTilting => tiltX.abs() > tiltThreshold || tiltY.abs() > tiltThreshold;

  /// Starts listening to the accelerometer stream.
  void start({VoidCallback? onError}) {
    if (_isRunning) return;
    _isRunning = true;

    _subscription = accelerometerEventStream().listen(
      (event) {
        _rawX = event.x;
        _rawY = event.y;
        _rawZ = event.z;

        _smoothX = (_smoothX * smoothingFactor) +
            (_rawX * (1 - smoothingFactor));
        _smoothY = (_smoothY * smoothingFactor) +
            (_rawY * (1 - smoothingFactor));
        _smoothZ = (_smoothZ * smoothingFactor) +
            (_rawZ * (1 - smoothingFactor));
      },
      onError: (_) {
        _isRunning = false;
        onError?.call();
      },
    );
  }

  /// Stops listening to the accelerometer. Always call this from
  /// dispose()/onRemove() to avoid leaking the sensor stream.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _isRunning = false;
  }

  /// Treats the current smoothed reading as the new neutral position —
  /// "hold the phone flat, tap to calibrate".
  void calibrate() {
    _calibrationX = _smoothX;
    _calibrationY = _smoothY;
  }
}
