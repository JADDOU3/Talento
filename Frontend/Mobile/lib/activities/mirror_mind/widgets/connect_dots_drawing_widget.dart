import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'symmetry_drawing_widget.dart';

class ConnectDotsDrawingWidget extends StatefulWidget {
  final String shape;
  final bool closed;
  final ValueChanged<SymmetryDrawingResult> onResultChanged;

  const ConnectDotsDrawingWidget({
    super.key,
    required this.shape,
    required this.closed,
    required this.onResultChanged,
  });

  @override
  State<ConnectDotsDrawingWidget> createState() =>
      ConnectDotsDrawingWidgetState();
}

class ConnectDotsDrawingWidgetState extends State<ConnectDotsDrawingWidget> {
  final List<Offset?> _userPoints = [];
  Size? _lastCanvasSize;

  bool get hasDrawing => _userPoints.whereType<Offset>().length >= 10;

  SymmetryDrawingResult evaluateDrawing() {
    final size = _lastCanvasSize ?? Size.zero;

    if (size == Size.zero || !hasDrawing) {
      return const SymmetryDrawingResult(
        hasDrawing: false,
        score: 0,
        isCorrect: false,
      );
    }

    final shapePoints = _pointsForShape(widget.shape, size);
    final userPoints = _userPoints.whereType<Offset>().toList();

    final expectedPoints = _sampleExpectedPath(
      points: shapePoints,
      closed: widget.closed,
    );

    final coverageScore = _calculateCoverageScore(
      expectedPoints: expectedPoints,
      userPoints: userPoints,
      tolerance: 22,
    );

    final orderedDotScore = _calculateOrderedDotScore(
      dots: shapePoints,
      userPoints: userPoints,
      tolerance: 28,
    );

    final dotHitScore = _calculateDotHitScore(
      dots: shapePoints,
      userPoints: userPoints,
      tolerance: 28,
    );

    final score = (coverageScore * 0.55) +
        (orderedDotScore * 0.10) +
        (dotHitScore * 0.35);

    print('coverage: $coverageScore');
    print('ordered: $orderedDotScore');
    print('dotHit: $dotHitScore');
    print('total score: $score');

    final isCorrect = score >= 0.80;

    return SymmetryDrawingResult(
      hasDrawing: true,
      score: score,
      isCorrect: isCorrect,
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
        const canvasHeight = 285.0;
        final canvasSize = Size(canvasWidth, canvasHeight);
        _lastCanvasSize = canvasSize;

        return Column(
          children: [
            Container(
              width: double.infinity,
              height: canvasHeight,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.12),
                  width: 1.3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    _addPoint(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _addPoint(details.localPosition);
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _userPoints.add(null);
                    });
                    widget.onResultChanged(evaluateDrawing());
                  },
                  child: CustomPaint(
                    painter: _ConnectDotsDrawingPainter(
                      shape: widget.shape,
                      closed: widget.closed,
                      userPoints: _userPoints,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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

  void _addPoint(Offset point) {
    setState(() {
      _userPoints.add(point);
    });
    widget.onResultChanged(evaluateDrawing());
  }
}

class _ConnectDotsDrawingPainter extends CustomPainter {
  final String shape;
  final bool closed;
  final List<Offset?> userPoints;

  const _ConnectDotsDrawingPainter({
    required this.shape,
    required this.closed,
    required this.userPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = _pointsForShape(shape, size);
    _drawGuideStep(canvas, points);
    _drawDots(canvas, points);
    _drawUserStroke(canvas);
  }

  void _drawGuideStep(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;

    final guidePaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.75)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(points[0], points[1], guidePaint);
  }

  void _drawDots(Canvas canvas, List<Offset> points) {
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];

      canvas.drawCircle(point, 8.2, whitePaint);
      canvas.drawCircle(point, 8.2, borderPaint);
      canvas.drawCircle(point, 5.1, dotPaint);

      if (i > 1) continue;

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(point.dx + 9, point.dy - 18),
      );
    }
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
  bool shouldRepaint(covariant _ConnectDotsDrawingPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.closed != closed ||
        oldDelegate.userPoints != userPoints;
  }
}

List<Offset> _pointsForShape(String rawShape, Size size) {
  final shape = rawShape.toLowerCase().trim();

  if (shape == 'flower') return _flowerPoints(size);
  if (shape == 'butterfly') return _butterflyPoints(size);

  return _starPoints(size);
}

List<Offset> _starPoints(Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final outerRadius = math.min(size.width, size.height) * 0.36;
  final innerRadius = outerRadius * 0.43;

  final points = <Offset>[];

  for (var i = 0; i < 10; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = -math.pi / 2 + i * math.pi / 5;

    points.add(Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    ));
  }

  return points;
}

List<Offset> _flowerPoints(Size size) {
  final cx = size.width / 2;
  final cy = size.height / 2 + 6;

  final outerR = math.min(size.width, size.height) * 0.40;
  final innerR = outerR * 0.28;

  double toRad(double deg) => deg * math.pi / 180;

  final points = <Offset>[];

  for (int i = 0; i < 5; i++) {
    final tipAngle = -90.0 + i * 72.0;
    final leftAngle = tipAngle - 36.0;
    final rightAngle = tipAngle + 36.0;

    points.add(Offset(
      cx + innerR * math.cos(toRad(leftAngle)),
      cy + innerR * math.sin(toRad(leftAngle)),
    ));
    points.add(Offset(
      cx + outerR * math.cos(toRad(tipAngle)),
      cy + outerR * math.sin(toRad(tipAngle)),
    ));
    points.add(Offset(
      cx + innerR * math.cos(toRad(rightAngle)),
      cy + innerR * math.sin(toRad(rightAngle)),
    ));
  }

  return points;
}

List<Offset> _butterflyPoints(Size size) {
  final cx = size.width / 2;
  final cy = size.height / 2;

  final w = size.width * 0.42;
  final h = size.height * 0.38;

  return [

    Offset(cx, cy - h * 0.85),
    Offset(cx - w * 0.20, cy - h * 0.45),
    Offset(cx - w * 0.80, cy - h * 0.72),
    Offset(cx - w * 0.98, cy - h * 0.18),
    Offset(cx - w * 0.60, cy + h * 0.10),
    Offset(cx - w * 0.75, cy + h * 0.65),
    Offset(cx - w * 0.32, cy + h * 0.82),
    Offset(cx - w * 0.12, cy + h * 0.25),
    Offset(cx, cy + h * 0.88),
    Offset(cx + w * 0.12, cy + h * 0.25),
    Offset(cx + w * 0.32, cy + h * 0.82),
    Offset(cx + w * 0.75, cy + h * 0.65),
    Offset(cx + w * 0.60, cy + h * 0.10),
    Offset(cx + w * 0.98, cy - h * 0.18),
    Offset(cx + w * 0.80, cy - h * 0.72),
    Offset(cx + w * 0.20, cy - h * 0.45),
  ];
}
List<Offset> _sampleExpectedPath({
  required List<Offset> points,
  required bool closed,
}) {
  if (points.length < 2) return points;

  final samples = <Offset>[];

  for (var i = 0; i < points.length - 1; i++) {
    samples.addAll(_sampleLine(start: points[i], end: points[i + 1], count: 22));
  }

  if (closed) {
    samples.addAll(_sampleLine(start: points.last, end: points.first, count: 22));
  }

  return samples;
}

List<Offset> _sampleLine({
  required Offset start,
  required Offset end,
  required int count,
}) {
  final points = <Offset>[];

  for (var i = 0; i <= count; i++) {
    final t = i / count;
    points.add(Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    ));
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
    if (userPoints.any((user) => (user - expected).distance <= tolerance)) {
      matched++;
    }
  }

  return matched / expectedPoints.length;
}

double _calculateDotHitScore({
  required List<Offset> dots,
  required List<Offset> userPoints,
  required double tolerance,
}) {
  if (dots.isEmpty || userPoints.isEmpty) return 0;

  var hit = 0;

  for (final dot in dots) {
    if (userPoints.any((user) => (user - dot).distance <= tolerance)) {
      hit++;
    }
  }

  return hit / dots.length;

}

double _calculateOrderedDotScore({
  required List<Offset> dots,
  required List<Offset> userPoints,
  required double tolerance,
}) {
  if (dots.isEmpty || userPoints.isEmpty) return 0;

  var nextDotIndex = 0;

  for (final userPoint in userPoints) {
    if (nextDotIndex >= dots.length) break;

    if ((userPoint - dots[nextDotIndex]).distance <= tolerance) {
      nextDotIndex++;
    }
  }

  return nextDotIndex / dots.length;


}