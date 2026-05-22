import 'package:flutter/material.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../util/theme/app_colors.dart';
import 'image_gallery.dart';
import 'star_rating.dart';

/// Hero: gallery + product summary, responsive two-column / stacked.
class KitHeroSection extends StatelessWidget {
  const KitHeroSection({
    super.key,
    required this.l10n,
    required this.mainImageAsset,
    required this.thumbnailAssets,
    required this.reviewCount,
    this.rating = 4.5,
    this.currentPriceLabel,
    this.originalPriceLabel,
    this.onAddToCart,
  });

  final AppLocalizations l10n;
  final String mainImageAsset;
  final List<String> thumbnailAssets;
  final int reviewCount;
  final double rating;
  /// When null, uses [l10n.kitDetailsPriceCurrent] / [l10n.kitDetailsPriceOriginal].
  final String? currentPriceLabel;
  final String? originalPriceLabel;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final twoCol = width >= 960;
    final current = currentPriceLabel ?? l10n.kitDetailsPriceCurrent;
    final original = originalPriceLabel ?? l10n.kitDetailsPriceOriginal;

    final gallery = ImageGallery(
      mainAsset: mainImageAsset,
      thumbnailAssets: thumbnailAssets,
    );

    final details = _DetailsColumn(
      l10n: l10n,
      reviewCount: reviewCount,
      rating: rating,
      currentPrice: current,
      originalPrice: original,
      onAddToCart: onAddToCart,
    );

    if (twoCol) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 52, child: gallery),
          const SizedBox(width: 40),
          Expanded(flex: 48, child: details),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gallery,
        const SizedBox(height: 28),
        details,
      ],
    );
  }
}

class _DetailsColumn extends StatelessWidget {
  const _DetailsColumn({
    required this.l10n,
    required this.reviewCount,
    required this.rating,
    required this.currentPrice,
    required this.originalPrice,
    this.onAddToCart,
  });

  final AppLocalizations l10n;
  final int reviewCount;
  final double rating;
  final String currentPrice;
  final String originalPrice;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final infoBg = AppColors.cartTeal.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.cartTeal,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              l10n.kitDetailsCategory,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.05,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.kitDetailsName,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.cartTeal,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            StarRating(rating: rating),
            Text(
              l10n.reviews(reviewCount),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.cartMutedGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: infoBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currentPrice,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cartTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    originalPrice,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.cartMutedGrey,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.cartMutedGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                l10n.kitDetailsDescription,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TagChip(
                    icon: Icons.schedule_rounded,
                    label: l10n.kitDetailsAgeTag,
                  ),
                  _TagChip(
                    icon: Icons.science_outlined,
                    label: l10n.kitDetailsExperimentsTag,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cartTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                  label: Text(
                    l10n.addToCart,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.cartTotalRose),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: Color(0xFF8B2940),
            ),
          ),
        ],
      ),
    );
  }
}
