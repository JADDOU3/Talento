import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SymmetryDrawingResult {
  final bool hasDrawing;
  final double score;
  final bool isCorrect;

  const SymmetryDrawingResult({
    required this.hasDrawing,
    required this.score,
    required this.isCorrect,
  });
}

class SymmetryDrawingWidget extends StatefulWidget {
  final String shape;
  final String missingSide;
  final ValueChanged<SymmetryDrawingResult> onResultChanged;

  const SymmetryDrawingWidget({
    super.key,
    required this.shape,
    required this.missingSide,
    required this.onResultChanged,
  });

  @override
  State<SymmetryDrawingWidget> createState() => SymmetryDrawingWidgetState();
}

class SymmetryDrawingWidgetState extends State<SymmetryDrawingWidget> {
  final List<Offset?> _userPoints = [];
  Size? _lastCanvasSize;

  bool get hasDrawing => _userPoints.whereType<Offset>().length >= 8;

  SymmetryDrawingResult evaluateDrawing() {
    final size = _lastCanvasSize ?? Size.zero;

    if (size == Size.zero || !hasDrawing) {
      return const SymmetryDrawingResult(
        hasDrawing: false,
        score: 0,
        isCorrect: false,
      );
    }

    final expectedPoints = _expectedHiddenPoints(
      shape: widget.shape,
      missingSide: widget.missingSide,
      size: size,
    );

    final userPoints = _userPoints.whereType<Offset>().toList();

    final score = _calculateCoverageScore(
      expectedPoints: expectedPoints,
      userPoints: userPoints,
      tolerance: 36,
    );

    return SymmetryDrawingResult(
      hasDrawing: true,
      score: score,
      isCorrect: score >= 0.70,
    );
  }

  void clearDrawing() {
    setState(_userPoints.clear);

    widget.onResultChanged(
      const SymmetryDrawingResult(
        hasDrawing: false,
        score: 0,
        isCorrect: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        const canvasHeight = 330.0;
        final canvasSize = Size(canvasWidth, canvasHeight);
        _lastCanvasSize = canvasSize;

        return Column(
          children: [
            Container(
              width: double.infinity,
              height: canvasHeight,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.28),
                  width: 1.4,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    _addPoint(details.localPosition, canvasSize);
                  },
                  onPanUpdate: (details) {
                    _addPoint(details.localPosition, canvasSize);
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _userPoints.add(null);
                    });

                    widget.onResultChanged(evaluateDrawing());
                  },
                  child: CustomPaint(
                    painter: _SymmetryDrawingPainter(
                      shape: widget.shape,
                      missingSide: widget.missingSide,
                      userPoints: _userPoints,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _userPoints.isEmpty ? null : clearDrawing,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text(
                'امسح الرسم',
                style: TextStyle(
                  fontFamily: 'ArialRounded',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addPoint(Offset point, Size size) {
    final isMissingLeft = widget.missingSide.toLowerCase() == 'left';
    final centerX = size.width / 2;

    final isInMissingSide =
    isMissingLeft ? point.dx <= centerX : point.dx >= centerX;

    if (!isInMissingSide) return;

    setState(() {
      _userPoints.add(point);
    });

    widget.onResultChanged(evaluateDrawing());
  }
}

class _SymmetryDrawingPainter extends CustomPainter {
  final String shape;
  final String missingSide;
  final List<Offset?> userPoints;

  const _SymmetryDrawingPainter({
    required this.shape,
    required this.missingSide,
    required this.userPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawMirrorLine(canvas, size);
    _drawVisibleHalfByClipping(canvas, size);
    _drawUserStroke(canvas);
  }

  void _drawMirrorLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withOpacity(0.85)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 8.0;
    const dashGap = 7.0;
    final x = size.width / 2;
    var y = 18.0;

    while (y < size.height - 18) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dashHeight, size.height - 18)),
        paint,
      );
      y += dashHeight + dashGap;
    }
  }

  void _drawVisibleHalfByClipping(Canvas canvas, Size size) {
    final visiblePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final visibleSide = missingSide.toLowerCase() == 'left' ? 'right' : 'left';
    final fullPaths = _fullPathsForShape(shape, size);

    canvas.save();

    if (visibleSide == 'left') {
      canvas.clipRect(Rect.fromLTWH(0, 0, centerX, size.height));
    } else {
      canvas.clipRect(
        Rect.fromLTWH(centerX, 0, size.width - centerX, size.height),
      );
    }

    for (final path in fullPaths) {
      canvas.drawPath(path, visiblePaint);
    }

    canvas.restore();
  }

  void _drawUserStroke(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < userPoints.length - 1; i++) {
      final current = userPoints[i];
      final next = userPoints[i + 1];

      if (current == null || next == null) continue;

      canvas.drawLine(current, next, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SymmetryDrawingPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.missingSide != missingSide ||
        oldDelegate.userPoints != userPoints;
  }
}

List<Path> _pathsForShape(
    String rawShape,
    Size size, {
      required String side,
    }) {
  final fullPaths = _fullPathsForShape(rawShape, size);
  final centerX = size.width / 2;
  final isLeft = side.toLowerCase() == 'left';

  final clipRect = isLeft
      ? Rect.fromLTWH(0, 0, centerX, size.height)
      : Rect.fromLTWH(centerX, 0, size.width - centerX, size.height);

  final clipPath = Path()..addRect(clipRect);
  final clippedPaths = <Path>[];

  for (final originalPath in fullPaths) {
    final clipped = Path.combine(
      PathOperation.intersect,
      originalPath,
      clipPath,
    );

    if (!clipped.getBounds().isEmpty) {
      clippedPaths.add(clipped);
    }
  }

  return clippedPaths;
}

List<Path> _fullPathsForShape(String rawShape, Size size) {
  final shape = rawShape.toLowerCase();

  if (shape == 'flower') {
    return _flowerFullPaths(size);
  }

  if (shape == 'butterfly') {
    return _butterflyFullPaths(size);
  }

  if (shape == 'cat' || shape == 'cat_face') {
    return _catFaceFullPaths(size);
  }

  return _starFullPaths(size);
}


List<Path> _flowerFullPaths(Size size) {
  final center = Offset(size.width / 2, size.height / 2);

  final paths = <Path>[];

  // cleaner 6-petal flower with less overlap
  final petalAngles = <double>[
    -math.pi / 2,       // top
    -math.pi / 6,       // upper right
    math.pi / 6,        // lower right
    math.pi / 2,        // bottom
    5 * math.pi / 6,    // lower left
    7 * math.pi / 6,    // upper left
  ];

  for (final angle in petalAngles) {
    paths.add(
      _buildFlowerPetalPath(
        center: center,
        angle: angle,
        length: 108,
        width: 62,
        centerRadius: 36,
      ),
    );
  }

  // center circle - clear but not too large
  paths.add(
    Path()
      ..addOval(
        Rect.fromCenter(
          center: center,
          width: 56,
          height: 56,
        ),
      ),
  );

  return paths;
}

Path _buildFlowerPetalPath({
  required Offset center,
  required double angle,
  required double length,
  required double width,
  required double centerRadius,
}) {
  final dir = Offset(
    math.cos(angle),
    math.sin(angle),
  );

  final perp = Offset(
    -math.sin(angle),
    math.cos(angle),
  );

  // Start petals farther from center to reduce overlap.
  final baseCenter = center + dir * centerRadius;

  final baseLeft = baseCenter + perp * (width * 0.22);
  final baseRight = baseCenter - perp * (width * 0.22);

  final tip = center + dir * length;

  // Softer petal curve.
  final c1 = center + dir * (length * 0.40) + perp * (width * 0.66);
  final c2 = center + dir * (length * 0.84) + perp * (width * 0.34);

  final c3 = center + dir * (length * 0.84) - perp * (width * 0.34);
  final c4 = center + dir * (length * 0.40) - perp * (width * 0.66);

  return Path()
    ..moveTo(baseLeft.dx, baseLeft.dy)
    ..cubicTo(
      c1.dx,
      c1.dy,
      c2.dx,
      c2.dy,
      tip.dx,
      tip.dy,
    )
    ..cubicTo(
      c3.dx,
      c3.dy,
      c4.dx,
      c4.dy,
      baseRight.dx,
      baseRight.dy,
    );
}






List<Path> _butterflyFullPaths(Size size) {
  final centerX = size.width / 2;
  final centerY = size.height / 2 + 6;

  final paths = <Path>[];

  const bodyWidth = 24.0;
  const bodyHeight = 132.0;
  final bodyTop = centerY - 46;
  final bodyLeft = centerX - (bodyWidth / 2);
  final bodyRight = centerX + (bodyWidth / 2);

  // head - slightly bigger
  paths.add(
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(centerX, bodyTop - 15),
          width: 34,
          height: 34,
        ),
      ),
  );

  // body
  paths.add(
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bodyLeft,
            bodyTop,
            bodyWidth,
            bodyHeight,
          ),
          const Radius.circular(18),
        ),
      ),
  );

  // left upper wing - slightly farther from body
  final leftUpper = Path()
    ..moveTo(bodyLeft - 3, centerY - 16)
    ..cubicTo(
      centerX - 24,
      centerY - 82,
      centerX - 80,
      centerY - 88,
      centerX - 96,
      centerY - 28,
    )
    ..cubicTo(
      centerX - 98,
      centerY + 6,
      centerX - 72,
      centerY + 18,
      centerX - 28,
      centerY + 8,
    )
    ..quadraticBezierTo(
      centerX - 14,
      centerY + 4,
      bodyLeft - 3,
      centerY - 16,
    )
    ..close();

  // right upper wing - slightly farther from body
  final rightUpper = Path()
    ..moveTo(bodyRight + 3, centerY - 16)
    ..cubicTo(
      centerX + 24,
      centerY - 82,
      centerX + 80,
      centerY - 88,
      centerX + 96,
      centerY - 28,
    )
    ..cubicTo(
      centerX + 98,
      centerY + 6,
      centerX + 72,
      centerY + 18,
      centerX + 28,
      centerY + 8,
    )
    ..quadraticBezierTo(
      centerX + 14,
      centerY + 4,
      bodyRight + 3,
      centerY - 16,
    )
    ..close();

  // left lower wing - slightly farther from body
  final leftLower = Path()
    ..moveTo(bodyLeft - 3, centerY + 18)
    ..cubicTo(
      centerX - 20,
      centerY + 34,
      centerX - 60,
      centerY + 48,
      centerX - 66,
      centerY + 94,
    )
    ..cubicTo(
      centerX - 66,
      centerY + 128,
      centerX - 40,
      centerY + 132,
      centerX - 18,
      centerY + 94,
    )
    ..quadraticBezierTo(
      centerX - 8,
      centerY + 56,
      bodyLeft - 3,
      centerY + 18,
    )
    ..close();

  // right lower wing - slightly farther from body
  final rightLower = Path()
    ..moveTo(bodyRight + 3, centerY + 18)
    ..cubicTo(
      centerX + 20,
      centerY + 34,
      centerX + 60,
      centerY + 48,
      centerX + 66,
      centerY + 94,
    )
    ..cubicTo(
      centerX + 66,
      centerY + 128,
      centerX + 40,
      centerY + 132,
      centerX + 18,
      centerY + 94,
    )
    ..quadraticBezierTo(
      centerX + 8,
      centerY + 56,
      bodyRight + 3,
      centerY + 18,
    )
    ..close();

  // antennas - slightly bigger
  final antennas = Path()
    ..moveTo(centerX - 7, bodyTop - 21)
    ..quadraticBezierTo(
      centerX - 21,
      bodyTop - 48,
      centerX - 39,
      bodyTop - 42,
    )
    ..moveTo(centerX + 7, bodyTop - 21)
    ..quadraticBezierTo(
      centerX + 21,
      bodyTop - 48,
      centerX + 39,
      bodyTop - 42,
    );

  paths.addAll([
    leftUpper,
    rightUpper,
    leftLower,
    rightLower,
    antennas,
  ]);

  return paths;
}

List<Path> _starFullPaths(Size size) {
  final center = Offset(size.width / 2, size.height / 2 - 8);
  final outerRadius = math.min(size.width, size.height) * 0.34;
  final innerRadius = outerRadius * 0.42;

  final points = <Offset>[];

  for (var i = 0; i < 10; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = -math.pi / 2 + i * math.pi / 5;

    points.add(
      Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      ),
    );
  }

  final path = Path()..moveTo(points.first.dx, points.first.dy);

  for (var i = 1; i < points.length; i++) {
    path.lineTo(points[i].dx, points[i].dy);
  }

  path.close();

  return [path];
}


List<Path> _catFaceFullPaths(Size size) {
  final centerX = size.width / 2;
  final centerY = size.height / 2 + 10;

  final paths = <Path>[];

  // Base face
  final rawFace = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 138,
        height: 128,
      ),
    );

  // Left ear - open path (no base line)
  final leftEar = Path()
    ..moveTo(centerX - 46, centerY - 34)
    ..quadraticBezierTo(
      centerX - 60,
      centerY - 68,
      centerX - 68,
      centerY - 90,
    )
    ..quadraticBezierTo(
      centerX - 42,
      centerY - 78,
      centerX - 12,
      centerY - 62,
    );

  // Right ear - open path
  final rightEar = Path()
    ..moveTo(centerX + 46, centerY - 34)
    ..quadraticBezierTo(
      centerX + 60,
      centerY - 68,
      centerX + 68,
      centerY - 90,
    )
    ..quadraticBezierTo(
      centerX + 42,
      centerY - 78,
      centerX + 12,
      centerY - 62,
    );

  // Cut areas to remove face line under ears
  final leftEarCut = Path()
    ..moveTo(centerX - 48, centerY - 36)
    ..quadraticBezierTo(
      centerX - 62,
      centerY - 70,
      centerX - 70,
      centerY - 92,
    )
    ..quadraticBezierTo(
      centerX - 42,
      centerY - 78,
      centerX - 10,
      centerY - 60,
    )
    ..quadraticBezierTo(
      centerX - 26,
      centerY - 52,
      centerX - 48,
      centerY - 36,
    )
    ..close();

  final rightEarCut = Path()
    ..moveTo(centerX + 48, centerY - 36)
    ..quadraticBezierTo(
      centerX + 62,
      centerY - 70,
      centerX + 70,
      centerY - 92,
    )
    ..quadraticBezierTo(
      centerX + 42,
      centerY - 78,
      centerX + 10,
      centerY - 60,
    )
    ..quadraticBezierTo(
      centerX + 26,
      centerY - 52,
      centerX + 48,
      centerY - 36,
    )
    ..close();

  // Remove the overlapping face arc under the ears
  final faceWithoutEarOverlap = Path.combine(
    PathOperation.difference,
    Path.combine(
      PathOperation.difference,
      rawFace,
      leftEarCut,
    ),
    rightEarCut,
  );

  // Eyes
  final leftEye = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(centerX - 27, centerY - 10),
        width: 12,
        height: 19,
      ),
    );

  final rightEye = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(centerX + 27, centerY - 10),
        width: 12,
        height: 19,
      ),
    );

  // Nose
  final nose = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 11),
        width: 10,
        height: 7,
      ),
    );

  // Mouth
  final mouth = Path()
    ..moveTo(centerX, centerY + 15)
    ..quadraticBezierTo(
      centerX - 10,
      centerY + 27,
      centerX - 18,
      centerY + 24,
    )
    ..moveTo(centerX, centerY + 15)
    ..quadraticBezierTo(
      centerX + 10,
      centerY + 27,
      centerX + 18,
      centerY + 24,
    );

  // Whiskers
  final whiskers = Path()
    ..moveTo(centerX - 13, centerY + 8)
    ..lineTo(centerX - 56, centerY + 2)
    ..moveTo(centerX - 13, centerY + 20)
    ..lineTo(centerX - 56, centerY + 22)
    ..moveTo(centerX + 13, centerY + 8)
    ..lineTo(centerX + 56, centerY + 2)
    ..moveTo(centerX + 13, centerY + 20)
    ..lineTo(centerX + 56, centerY + 22);

  paths.addAll([
    faceWithoutEarOverlap,
    leftEar,
    rightEar,
    leftEye,
    rightEye,
    nose,
    mouth,
    whiskers,
  ]);

  return paths;
}

List<Offset> _expectedHiddenPoints({
  required String shape,
  required String missingSide,
  required Size size,
}) {
  final paths = _pathsForShape(
    shape,
    size,
    side: missingSide,
  );

  final points = <Offset>[];

  for (final path in paths) {
    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      const samples = 42;

      for (var i = 0; i <= samples; i++) {
        final tangent = metric.getTangentForOffset(length * i / samples);
        if (tangent != null) points.add(tangent.position);
      }
    }
  }

  return points;
}

double _calculateCoverageScore({
  required List<Offset> expectedPoints,
  required List<Offset> userPoints,
  required double tolerance,
}) {
  if (expectedPoints.isEmpty || userPoints.isEmpty) return 0;

  var matched = 0;

  for (final expected in expectedPoints) {
    final isCovered = userPoints.any(
          (user) => (user - expected).distance <= tolerance,
    );

    if (isCovered) matched++;
  }

  return matched / expectedPoints.length;
}

class _PetalSpec {
  final double dx;
  final double dy;
  final double width;
  final double height;

  const _PetalSpec({
    required this.dx,
    required this.dy,
    required this.width,
    required this.height,
  });
}