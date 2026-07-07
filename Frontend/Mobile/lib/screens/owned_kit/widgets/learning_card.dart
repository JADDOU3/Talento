import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LearningCard extends StatelessWidget {
  final String badge;
  final String title;
  final String levelText;
  final double progress;
  final String buttonText;
  final String mascotAssetPath;
  final VoidCallback onPressed;

  const LearningCard({
    super.key,
    required this.badge,
    required this.title,
    required this.levelText,
    required this.progress,
    required this.buttonText,
    required this.onPressed,
    this.mascotAssetPath = 'assets/images/curriculum_path_mascot.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 228,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.pink.withOpacity(0.18),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.035),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              left: -42,
              top: 20,
              child: Container(
                width: 178,
                height: 178,
                decoration: BoxDecoration(
                  color: AppColors.pink.withOpacity(0.11),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              right: -42,
              bottom: -40,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              left: 14,
              bottom: 18,
              child: Container(
                width: 132,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.pink.withOpacity(0.055),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 30,
              top: 24,
              child: Icon(
                Icons.star_rounded,
                color: AppColors.yellow.withOpacity(0.92),
                size: 17,
              ),
            ),

            Positioned(
              left: 122,
              top: 38,
              child: Icon(
                Icons.star_rounded,
                color: AppColors.secondary.withOpacity(0.92),
                size: 15,
              ),
            ),

            Positioned(
              left: 148,
              top: 58,
              child: Icon(
                Icons.star_rounded,
                color: AppColors.pink.withOpacity(0.78),
                size: 12,
              ),
            ),

            Positioned(
              left: 10,
              bottom: 18,
              child: CustomPaint(
                size: const Size(138, 120),
                painter: _MascotTrailPainter(),
              ),
            ),

            Positioned(
              left: 4,
              bottom: 14,
              child: Image.asset(
                mascotAssetPath,
                width: 150,
                height: 182,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.primary,
                      size: 58,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(132, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pink.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: TextDirection.rtl,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            color: AppColors.pink,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badge,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.pink,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      levelText,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: AppColors.inputFill,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  _LearningActionButton(
                    text: buttonText,
                    onPressed: onPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _LearningActionButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.24),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 22,
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.white,
                  size: 21,
                ),
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MascotTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.14)
      ..cubicTo(
        size.width * 0.02,
        size.height * 0.34,
        size.width * 0.10,
        size.height * 0.58,
        size.width * 0.34,
        size.height * 0.58,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.58,
        size.width * 0.72,
        size.height * 0.80,
        size.width * 0.92,
        size.height * 0.84,
      );

    final paint = Paint()
      ..color = AppColors.pink.withOpacity(0.34)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _drawDashedPath(
      canvas: canvas,
      path: path,
      paint: paint,
      dashWidth: 7,
      dashSpace: 7,
    );
  }

  void _drawDashedPath({
    required Canvas canvas,
    required Path path,
    required Paint paint,
    required double dashWidth,
    required double dashSpace,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;

        final extractPath = metric.extractPath(
          distance,
          nextDistance.clamp(0, metric.length),
        );

        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}