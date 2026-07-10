import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OwnedKitHeader extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback onResume;

  const OwnedKitHeader({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: AppColors.white.withOpacity(0.95),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.055),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.035),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _KitCoverImage(imageUrl: imageUrl),
            _KitInfoArea(
              name: name,
              onResume: onResume,
            ),
          ],
        ),
      ),
    );
  }
}

class _KitCoverImage extends StatelessWidget {
  final String imageUrl;

  const _KitCoverImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 226,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      color: AppColors.white.withOpacity(0.96),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
            width: 2.6,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: imageUrl.trim().isEmpty
              ? const _ImagePlaceholder()
              : Image.network(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _KitInfoArea extends StatelessWidget {
  final String name;
  final VoidCallback onResume;

  const _KitInfoArea({
    required this.name,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.96),
              ),
            ),
          ),

          Positioned(
            left: -36,
            top: 18,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                color: AppColors.pink.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: -36,
            bottom: -32,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            left: 50,
            top: 50,
            child: CustomPaint(
              size: const Size(270, 92),
              painter: _KitTrailPainter(),
            ),
          ),

          Positioned(
            right: 30,
            top: 33,
            child: Transform.rotate(
              angle: 0.45,
              child: Icon(
                Icons.navigation_rounded,
                color: AppColors.primary.withOpacity(0.78),
                size: 40,
              ),
            ),
          ),

          Positioned(
            left: 46,
            top: 48,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.yellow.withOpacity(0.92),
              size: 18,
            ),
          ),

          Positioned(
            right: 84,
            top: 84,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.pink.withOpacity(0.72),
              size: 13,
            ),
          ),

          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/kit_details_mascot.png',
                width: 128,
                height: 128,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            left: 18,
            right: 18,
            top: 92,
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),

                const SizedBox(height: 20),

                _ResumeButton(onTap: onResume),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ResumeButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 205,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
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
              border: Border.all(
                color: AppColors.white.withOpacity(0.65),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.26),
                  blurRadius: 15,
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
                    Icons.auto_awesome_rounded,
                    color: AppColors.white.withOpacity(0.95),
                    size: 20,
                  ),
                ),
                Text(
                  'أكمل الرحلة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
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
      ),
    );
  }
}



class _KitTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.06, size.height * 0.78)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.48,
        size.width * 0.32,
        size.height * 0.92,
        size.width * 0.48,
        size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.42,
        size.width * 0.78,
        size.height * 0.52,
        size.width * 0.92,
        size.height * 0.26,
      )
      ..cubicTo(
        size.width * 0.96,
        size.height * 0.18,
        size.width * 0.99,
        size.height * 0.13,
        size.width * 1.02,
        size.height * 0.08,
      );

    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.28)
      ..strokeWidth = 2.1
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

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withOpacity(0.10),
            AppColors.secondary.withOpacity(0.10),
          ],
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/kit_placeholder.png',
          width: 78,
          height: 78,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.88),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            );
          },
        ),
      ),
    );
  }
}