import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class RoadmapConnector extends StatelessWidget {
  final bool isActive;
  final bool curveToRight;

  const RoadmapConnector({
    super.key,
    required this.isActive,
    required this.curveToRight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: CustomPaint(
        painter: _RoadmapConnectorPainter(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.58)
              : AppColors.hint.withValues(alpha: 0.28),
          curveToRight: curveToRight,
        ),
      ),
    );
  }
}

class _RoadmapConnectorPainter extends CustomPainter {
  final Color color;
  final bool curveToRight;

  const _RoadmapConnectorPainter({
    required this.color,
    required this.curveToRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    final startX = curveToRight ? size.width * 0.66 : size.width * 0.34;
    final endX = curveToRight ? size.width * 0.34 : size.width * 0.66;

    path.moveTo(startX, 0);
    path.cubicTo(
      curveToRight ? size.width * 0.92 : size.width * 0.08,
      size.height * 0.16,
      curveToRight ? size.width * 0.08 : size.width * 0.92,
      size.height * 0.84,
      endX,
      size.height,
    );

    final metric = path.computeMetrics().first;
    const dotSpacing = 13.0;
    const dotRadius = 3.2;

    for (double distance = 0; distance < metric.length; distance += dotSpacing) {
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) continue;

      canvas.drawCircle(
        tangent.position,
        dotRadius,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    final sparklePaint = Paint()
      ..color = AppColors.yellow.withValues(alpha: 0.9)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final sparkleX = curveToRight ? size.width * 0.53 : size.width * 0.47;
    final sparkleY = size.height * 0.50;

    canvas.drawLine(
      Offset(sparkleX - 5, sparkleY),
      Offset(sparkleX + 5, sparkleY),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(sparkleX, sparkleY - 5),
      Offset(sparkleX, sparkleY + 5),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoadmapConnectorPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.curveToRight != curveToRight;
  }
}