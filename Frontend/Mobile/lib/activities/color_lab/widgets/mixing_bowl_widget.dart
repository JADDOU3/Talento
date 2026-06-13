import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/color_lab/color_lab_models.dart';

/// A soft, smooth blob ("bubble") that fills with the mixed color.
/// Uses cubic Bézier curves for gentle, rounded edges (no jagged points).
class MixingBowlWidget extends StatelessWidget {
  final List<ColorLabPaletteColor> selectedColors;

  const MixingBowlWidget({
    super.key,
    required this.selectedColors,
  });

  Color get _mixedColor {
    if (selectedColors.isEmpty) return AppColors.white;
    return ColorMixer.mixColor(selectedColors);
  }

  @override
  Widget build(BuildContext context) {
    final hasColors = selectedColors.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: AppColors.white,
                end: _mixedColor,
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, color, _) {
                return CustomPaint(
                  painter: _BlobPainter(
                    fillColor: color ?? AppColors.white,
                    borderColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 26),
            child: hasColors
                ? Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: selectedColors.map((c) {
                return Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
                : Text(
              'اختر لونًا لتبدأ الخلط',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a smooth rounded blob using Catmull-Rom → Bézier conversion so the
/// outline is soft and continuous (no sharp corners).
class _BlobPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _BlobPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width * 0.46;
    final ry = size.height * 0.44;

    // Gentle radius variation per anchor — small differences = soft, organic.
    const points = 8;
    final radii = <double>[
      1.00, 0.95, 1.02, 0.96, 1.00, 0.94, 1.01, 0.97,
    ];

    final anchors = <Offset>[];
    for (int i = 0; i < points; i++) {
      final angle = (i / points) * 2 * math.pi - math.pi / 2;
      final rr = radii[i % radii.length];
      anchors.add(Offset(
        cx + rx * rr * math.cos(angle),
        cy + ry * rr * math.sin(angle),
      ));
    }

    final path = _smoothClosedPath(anchors);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, borderPaint);
  }

  /// Catmull-Rom spline through all points → smooth closed path.
  Path _smoothClosedPath(List<Offset> pts) {
    final path = Path();
    final n = pts.length;
    if (n < 3) return path;

    path.moveTo(
      (pts[n - 1].dx + pts[0].dx) / 2,
      (pts[n - 1].dy + pts[0].dy) / 2,
    );

    for (int i = 0; i < n; i++) {
      final p0 = pts[i];
      final p1 = pts[(i + 1) % n];
      // midpoint target with quadratic control at the anchor → smooth curve
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}
