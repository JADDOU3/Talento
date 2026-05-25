import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CameraViewfinder extends StatefulWidget {
  final MobileScannerController scannerController;
  final void Function(BarcodeCapture capture) onDetect;
  final bool isScannerStopped;
  final bool hasReachedMaxScans;

  const CameraViewfinder({
    super.key,
    required this.scannerController,
    required this.onDetect,
    required this.isScannerStopped,
    required this.hasReachedMaxScans,
  });

  @override
  State<CameraViewfinder> createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<CameraViewfinder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewfinderHeight = (screenWidth - 40) * 1.08;

    return Container(
      height: viewfinderHeight.clamp(330.0, 440.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: widget.scannerController,
                  onDetect: widget.onDetect,
                ),

                Container(
                  color: AppColors.black.withValues(alpha: 0.08),
                ),

                CustomPaint(
                  painter: _CameraGridPainter(
                    color: AppColors.white.withValues(alpha: 0.16),
                  ),
                ),

                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    final scanTop = 56 +
                        _scanController.value *
                            (constraints.maxHeight - 150);

                    return Positioned(
                      top: scanTop,
                      left: 38,
                      right: 38,
                      child: child!,
                    );
                  },
                  child: SizedBox(
                    height: 30,
                    child: CustomPaint(
                      painter: _ScanLinePainter(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                CustomPaint(
                  painter: _ScannerCornerPainter(
                    color: AppColors.primary,
                    strokeWidth: 7,
                    cornerLength: 64,
                    inset: 24,
                    radius: 22,
                  ),
                ),

                if (widget.isScannerStopped)
                  Container(
                    color: AppColors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Text(
                        widget.hasReachedMaxScans
                            ? 'تم إيقاف المسح\nوصلتِ إلى 5/5'
                            : 'تم إيقاف المسح مؤقتًا\nيمكنك تشغيله مرة ثانية',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.isScannerStopped
                          ? widget.hasReachedMaxScans
                          ? 'اضغط إعادة التجربة لبدء جلسة جديدة'
                          : 'اضغط تشغيل المسح للمتابعة'
                          : 'وجّه الكاميرا نحو بطاقة تالينتو!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  final Color color;

  const _CameraGridPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final verticalGap = size.width / 3;
    final horizontalGap = size.height / 3;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(verticalGap * i, 0),
        Offset(verticalGap * i, size.height),
        paint,
      );

      canvas.drawLine(
        Offset(0, horizontalGap * i),
        Offset(size.width, horizontalGap * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CameraGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ScanLinePainter extends CustomPainter {
  final Color color;

  const _ScanLinePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.30),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      glowPaint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ScannerCornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double inset;
  final double radius;

  const _ScannerCornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.inset,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    _drawTopLeft(canvas, paint, left, top);
    _drawTopRight(canvas, paint, right, top);
    _drawBottomLeft(canvas, paint, left, bottom);
    _drawBottomRight(canvas, paint, right, bottom);
  }

  void _drawTopLeft(Canvas canvas, Paint paint, double left, double top) {
    final path = Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + radius)
      ..quadraticBezierTo(left, top, left + radius, top)
      ..lineTo(left + cornerLength, top);

    canvas.drawPath(path, paint);
  }

  void _drawTopRight(Canvas canvas, Paint paint, double right, double top) {
    final path = Path()
      ..moveTo(right - cornerLength, top)
      ..lineTo(right - radius, top)
      ..quadraticBezierTo(right, top, right, top + radius)
      ..lineTo(right, top + cornerLength);

    canvas.drawPath(path, paint);
  }

  void _drawBottomLeft(Canvas canvas, Paint paint, double left, double bottom) {
    final path = Path()
      ..moveTo(left, bottom - cornerLength)
      ..lineTo(left, bottom - radius)
      ..quadraticBezierTo(left, bottom, left + radius, bottom)
      ..lineTo(left + cornerLength, bottom);

    canvas.drawPath(path, paint);
  }

  void _drawBottomRight(Canvas canvas, Paint paint, double right, double bottom) {
    final path = Path()
      ..moveTo(right - cornerLength, bottom)
      ..lineTo(right - radius, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - radius)
      ..lineTo(right, bottom - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.inset != inset ||
        oldDelegate.radius != radius;
  }
}