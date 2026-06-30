import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kit/kit_enums.dart';

class ChildModeOwnedKitCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String type;
  final double rating;
  final VoidCallback onTap;

  const ChildModeOwnedKitCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = kitTypeArabicLabel(type);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.95),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.055),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChildKitCoverImage(
                  imageUrl: imageUrl,
                  rating: rating,
                  typeLabel: typeLabel,
                ),
                _ChildKitInfoArea(
                  name: name,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildKitCoverImage extends StatelessWidget {
  final String imageUrl;
  final double rating;
  final String typeLabel;

  const _ChildKitCoverImage({
    required this.imageUrl,
    required this.rating,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 226,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(5, 8, 5, 0),
      color: AppColors.white.withValues(alpha: 0.96),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.22),
            width: 2.4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.trim().isEmpty
                  ? const _ChildCardImagePlaceholder()
                  : Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return Container(
                          color: AppColors.inputFill,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) {
                        return const _ChildCardImagePlaceholder();
                      },
                    ),
              Positioned(
                top: 12,
                left: 12,
                child: _ChildRatingBadge(rating: rating),
              ),
              if (typeLabel.isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _ChildTypeBadge(label: typeLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildRatingBadge extends StatelessWidget {
  final double rating;

  const _ChildRatingBadge({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.yellow.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.yellow,
            size: 17,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildTypeBadge extends StatelessWidget {
  final String label;

  const _ChildTypeBadge({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.primary,
            AppColors.secondary.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ChildKitInfoArea extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _ChildKitInfoArea({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.white.withValues(alpha: 0.96),
            ),
          ),
          Positioned(
            left: -36,
            top: 16,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                color: AppColors.pink.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -36,
            bottom: -34,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 46,
            top: 42,
            child: CustomPaint(
              size: const Size(260, 86),
              painter: _ChildKitTrailPainter(),
            ),
          ),
          Positioned(
            right: 28,
            top: 26,
            child: Transform.rotate(
              angle: 0.45,
              child: Icon(
                Icons.navigation_rounded,
                color: AppColors.primary.withValues(alpha: 0.72),
                size: 38,
              ),
            ),
          ),
          Positioned(
            left: 46,
            top: 42,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.yellow.withValues(alpha: 0.92),
              size: 18,
            ),
          ),
          Positioned(
            right: 86,
            top: 78,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.pink.withValues(alpha: 0.72),
              size: 13,
            ),
          ),
          Positioned(
            top: -18,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/kit_details_mascot.png',
                width: 124,
                height: 124,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
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
            top: 88,
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 18),
                _ChildStartButton(onTap: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildStartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ChildStartButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 215,
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
                color: AppColors.white.withValues(alpha: 0.65),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  blurRadius: 15,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'ابدأ الاستكشاف',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildKitTrailPainter extends CustomPainter {
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
      ..color = AppColors.primary.withValues(alpha: 0.25)
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

class _ChildCardImagePlaceholder extends StatelessWidget {
  const _ChildCardImagePlaceholder();

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
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.secondary.withValues(alpha: 0.10),
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
                color: AppColors.white.withValues(alpha: 0.88),
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
