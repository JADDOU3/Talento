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

    final expectedPoints = _sampleExpectedPath(
      points: shapePoints,
      closed: widget.closed,
    );

    final userPoints = _userPoints.whereType<Offset>().toList();

    final coverageScore = _calculateCoverageScore(
      expectedPoints: expectedPoints,
      userPoints: userPoints,
      tolerance: 34,
    );

    final dotScore = _calculateDotHitScore(
      dots: shapePoints,
      userPoints: userPoints,
      tolerance: 38,
    );

    final score = (coverageScore * 0.65) + (dotScore * 0.35);

    return SymmetryDrawingResult(
      hasDrawing: true,
      score: score,
      isCorrect: score >= 0.62,
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

    // فقط أول خط كبداية: 1 -> 2
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

      // نرقّم فقط أول نقطتين حتى يعرف البداية
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

  if (shape == 'flower') {
    return _flowerPoints(size);
  }

  if (shape == 'butterfly') {
    return _butterflyPoints(size);
  }

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

    points.add(
      Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      ),
    );
  }

  return points;
}

List<Offset> _flowerPoints(Size size) {
  final center = Offset(size.width / 2, size.height / 2);

  // وردة أوضح: النقاط ماشية على حدود بتلات بسيطة حول المركز.
  return [
    Offset(center.dx, center.dy - 92), // top petal
    Offset(center.dx - 34, center.dy - 54),
    Offset(center.dx - 88, center.dy - 48), // upper left petal
    Offset(center.dx - 56, center.dy - 10),
    Offset(center.dx - 72, center.dy + 48), // lower left petal
    Offset(center.dx - 24, center.dy + 38),
    Offset(center.dx, center.dy + 92), // bottom petal
    Offset(center.dx + 24, center.dy + 38),
    Offset(center.dx + 72, center.dy + 48), // lower right petal
    Offset(center.dx + 56, center.dy - 10),
    Offset(center.dx + 88, center.dy - 48), // upper right petal
    Offset(center.dx + 34, center.dy - 54),
  ];
}

List<Offset> _butterflyPoints(Size size) {
  final centerX = size.width / 2;
  final centerY = size.height / 2 + 5;

  // فراشة أوضح: نبدأ من الرأس، نمر على الجناح اليسار، الجسم، الجناح اليمين.
  return [
    Offset(centerX, centerY - 100), // head / start
    Offset(centerX - 18, centerY - 62), // left body top
    Offset(centerX - 92, centerY - 82), // left upper wing top
    Offset(centerX - 118, centerY - 25), // left upper wing outer
    Offset(centerX - 72, centerY + 12), // left upper wing inner bottom
    Offset(centerX - 92, centerY + 78), // left lower wing outer
    Offset(centerX - 38, centerY + 92), // left lower wing bottom
    Offset(centerX - 14, centerY + 28), // left body middle
    Offset(centerX, centerY + 104), // body bottom
    Offset(centerX + 14, centerY + 28), // right body middle
    Offset(centerX + 38, centerY + 92), // right lower wing bottom
    Offset(centerX + 92, centerY + 78), // right lower wing outer
    Offset(centerX + 72, centerY + 12), // right upper wing inner bottom
    Offset(centerX + 118, centerY - 25), // right upper wing outer
    Offset(centerX + 92, centerY - 82), // right upper wing top
    Offset(centerX + 18, centerY - 62), // right body top
  ];
}

List<Offset> _sampleExpectedPath({
  required List<Offset> points,
  required bool closed,
}) {
  if (points.length < 2) return points;

  final samples = <Offset>[];

  for (var i = 0; i < points.length - 1; i++) {
    samples.addAll(
      _sampleLine(
        start: points[i],
        end: points[i + 1],
        count: 18,
      ),
    );
  }

  if (closed) {
    samples.addAll(
      _sampleLine(
        start: points.last,
        end: points.first,
        count: 18,
      ),
    );
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

    points.add(
      Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      ),
    );
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
    final covered = userPoints.any(
          (user) => (user - expected).distance <= tolerance,
    );

    if (covered) matched++;
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
    final touched = userPoints.any(
          (user) => (user - dot).distance <= tolerance,
    );

    if (touched) hit++;
  }

  return hit / dots.length;
}