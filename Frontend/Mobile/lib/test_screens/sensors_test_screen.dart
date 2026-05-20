import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/*
Talento Gyroscope / Sensors Prototype

Package chosen: sensors_plus
Version used: 7.0.0

Purpose:
Test device tilt/orientation input for Talento interactive activities,
especially tilt-based maze and balance games.

Why sensors_plus:
- Supports Android and iOS.
- Provides accelerometer, gyroscope, user accelerometer, and magnetometer streams.
- Easy to integrate inside a normal Flutter screen.
- Suitable for testing tilt, rotation speed, and shake-like movement.

Important finding:
- For tilt-based games, accelerometer data is more useful than raw gyroscope data.
- Accelerometer helps detect tilt left/right and forward/backward.
- Gyroscope is useful for rotation speed, not direct tilt position.
- Magnetometer is mainly for compass direction and is not needed for the maze use case.

Prototype behavior:
- A ball moves on screen based on device tilt.
- Tilt left/right moves the ball horizontally.
- Tilt forward/backward moves the ball vertically.
- Raw x, y, z accelerometer values are shown for debugging.
- A visual text indicator shows the detected tilt direction.
- A simple low-pass smoothing filter is used to reduce jitter.
- Calibration is supported: the current phone position can be treated as neutral.

Smoothing approach:
smoothedValue = oldValue * 0.78 + newValue * 0.22

Calibration approach:
The reset button returns the ball to the center and stores the current smoothed
accelerometer values as the neutral phone position. This is needed because sensor
values are usually not zero even when the phone looks still.

Verdict:
Use sensors_plus for Talento tilt-based activities, with accelerometer-based movement,
calibration, and smoothing. Gyroscope can be used later for rotation-speed features.

Recommended use case:
Tilt maze, balance activities, motion-based puzzles, and physical interaction games.
*/

class SensorsTestScreen extends StatefulWidget {
  const SensorsTestScreen({super.key});

  @override
  State<SensorsTestScreen> createState() => _SensorsTestScreenState();
}

class _SensorsTestScreenState extends State<SensorsTestScreen> {
  static const double _ballSize = 44;

  // Increased from 7.5 to 12.0 because the first test felt too slow.
  static const double _movementSensitivity = 12.0;

  // Lower value = faster response. 0.85 was smoother but felt slow.
  static const double _smoothingFactor = 0.78;

  static const double _tiltThreshold = 1.2;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  double _rawX = 0;
  double _rawY = 0;
  double _rawZ = 0;

  double _smoothX = 0;
  double _smoothY = 0;
  double _smoothZ = 0;

  // Calibration values. These represent the "neutral" phone position.
  double _calibrationX = 0;
  double _calibrationY = 0;

  double _ballX = 0;
  double _ballY = 0;

  String _tiltDirection = 'ثابت';

  @override
  void initState() {
    super.initState();
    _listenToAccelerometer();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _listenToAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen(
          (event) {
        _rawX = event.x;
        _rawY = event.y;
        _rawZ = event.z;

        _smoothX =
            (_smoothX * _smoothingFactor) + (_rawX * (1 - _smoothingFactor));
        _smoothY =
            (_smoothY * _smoothingFactor) + (_rawY * (1 - _smoothingFactor));
        _smoothZ =
            (_smoothZ * _smoothingFactor) + (_rawZ * (1 - _smoothingFactor));

        final calibratedX = _smoothX - _calibrationX;
        final calibratedY = _smoothY - _calibrationY;

        _tiltDirection = _detectTiltDirection(calibratedX, calibratedY);

        if (!mounted) return;

        setState(() {
          _ballX += -calibratedX * _movementSensitivity;
          _ballY += calibratedY * _movementSensitivity;
        });
      },
      onError: (_) {
        if (!mounted) return;

        setState(() {
          _tiltDirection = 'تعذر قراءة الحساسات';
        });
      },
    );
  }

  String _detectTiltDirection(double x, double y) {
    final absX = x.abs();
    final absY = y.abs();

    if (absX < _tiltThreshold && absY < _tiltThreshold) {
      return 'ثابت';
    }

    if (absX > absY) {
      return x > 0 ? 'ميلان لليسار' : 'ميلان لليمين';
    }

    return y > 0 ? 'ميلان للخلف' : 'ميلان للأمام';
  }

  void _resetAndCalibrateBall() {
    setState(() {
      _ballX = 0;
      _ballY = 0;

      // Treat the current phone position as the neutral position.
      _calibrationX = _smoothX;
      _calibrationY = _smoothY;
      _tiltDirection = 'تمت المعايرة';
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
                  _buildInfoCard(),
                  const SizedBox(height: 18),
                  _buildTiltPlayground(),
                  const SizedBox(height: 18),
                  _buildDirectionCard(),
                  const SizedBox(height: 18),
                  _buildSensorValuesCard(),
                  const SizedBox(height: 18),
                  _buildResetButton(),
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
            'تجربة حساسات الحركة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF123835),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Text(
        'حرّكي الجهاز يمين/شمال أو للأمام/الخلف. الكرة ستتحرك حسب الميلان. إذا كانت الكرة تتحرك لوحدها، اضغطي زر المعايرة بالأسفل.',
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

  Widget _buildTiltPlayground() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.sizeOf(context).width - 40;
        const height = 360.0;

        final maxX = (width / 2) - (_ballSize / 2) - 12;
        const maxY = (height / 2) - (_ballSize / 2) - 12;

        final clampedX = _ballX.clamp(-maxX, maxX).toDouble();
        final clampedY = _ballY.clamp(-maxY, maxY).toDouble();

        if (clampedX != _ballX || clampedY != _ballY) {
          _ballX = clampedX;
          _ballY = clampedY;
        }

        return Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF123835),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: const _PlaygroundGridPainter(),
              ),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(clampedX, clampedY),
                  child: Container(
                    width: _ballSize,
                    height: _ballSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFE7A8),
                          Color(0xFFF9B919),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(0xFFF9B919).withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDirectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.screen_rotation_alt_rounded,
            color: Color(0xFF10A896),
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _tiltDirection,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF123835),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorValuesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Raw accelerometer values',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Color(0xFF123835),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _SensorValueRow(label: 'x', value: _rawX),
          _SensorValueRow(label: 'y', value: _rawY),
          _SensorValueRow(label: 'z', value: _rawZ),
          const Divider(height: 28),
          const Text(
            'Smoothed values',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Color(0xFF123835),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _SensorValueRow(label: 'x', value: _smoothX),
          _SensorValueRow(label: 'y', value: _smoothY),
          _SensorValueRow(label: 'z', value: _smoothZ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _resetAndCalibrateBall,
        icon: const Icon(Icons.tune_rounded),
        label: const Text(
          'معايرة وإرجاع الكرة للمنتصف',
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

class _SensorValueRow extends StatelessWidget {
  const _SensorValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF60706D),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: min(value.abs() / 10, 1),
              minHeight: 9,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: const Color(0xFFE9FAF6),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF123835),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaygroundGridPainter extends CustomPainter {
  const _PlaygroundGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const gap = 36.0;

    for (double x = gap; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = gap; y < size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(26),
    );

    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PlaygroundGridPainter oldDelegate) {
    return false;
  }
}