import 'package:flutter/material.dart';
import '../../../../util/theme/app_colors.dart';
import 'kit_network_image.dart';

/// Large product image with a corner quality badge; badge aligns to
/// [AlignmentDirectional.bottomEnd] so it mirrors correctly in RTL.
class QualityBadgeImage extends StatelessWidget {
  const QualityBadgeImage({
    super.key,
    this.imageAsset,
    this.imageUrl,
    required this.badgeTitle,
    required this.badgeSubtitle,
    this.borderRadius = 22,
  });

  final String? imageAsset;
  final String? imageUrl;
  final String badgeTitle;
  final String badgeSubtitle;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AspectRatio(
        aspectRatio: 1.02,
        child: Stack(
          fit: StackFit.expand,
          children: [
            KitNetworkImage(
              imageUrl: imageUrl,
              assetPath: imageAsset,
              fit: BoxFit.cover,
            ),
            PositionedDirectional(
              end: 16,
              bottom: 16,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xE6282C34),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          badgeTitle,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppColors.cartTeal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badgeSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
