import 'package:flutter/material.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../shared/models/kit_model.dart';
import '../../../../util/theme/app_colors.dart';
import 'image_gallery.dart';
import 'star_rating.dart';

/// Hero: gallery + product summary, responsive two-column / stacked.
class KitHeroSection extends StatelessWidget {
  const KitHeroSection({
    super.key,
    required this.l10n,
    required this.kit,
    required this.reviewCount,
    this.rating,
    this.fallbackMainAsset,
    this.fallbackThumbAssets = const [],
    this.onAddToCart,
    this.isAddingToCart = false,
  });

  final AppLocalizations l10n;
  final KitModel kit;
  final int reviewCount;
  final double? rating;
  final String? fallbackMainAsset;
  final List<String> fallbackThumbAssets;
  final VoidCallback? onAddToCart;
  final bool isAddingToCart;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final twoCol = width >= 960;
    final displayRating = rating ?? kit.rating;

    final gallery = ImageGallery(
      mainImageUrl: kit.imageURL,
      mainAsset: fallbackMainAsset,
      thumbnailUrls: kit.imageURL.isNotEmpty
          ? [kit.imageURL, kit.imageURL]
          : const [],
      thumbnailAssets: fallbackThumbAssets,
    );

    final details = _DetailsColumn(
      l10n: l10n,
      kit: kit,
      reviewCount: reviewCount,
      rating: displayRating,
      onAddToCart: onAddToCart,
      isAddingToCart: isAddingToCart,
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
    required this.kit,
    required this.reviewCount,
    required this.rating,
    this.onAddToCart,
    this.isAddingToCart = false,
  });

  final AppLocalizations l10n;
  final KitModel kit;
  final int reviewCount;
  final double rating;
  final VoidCallback? onAddToCart;
  final bool isAddingToCart;

  String get _typeLabel {
    final t = kit.type.trim();
    if (t.isEmpty) return l10n.kitDetailsCategory;
    return t.replaceAll('_', ' ').toUpperCase();
  }

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
              _typeLabel,
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
          kit.name,
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
              Text(
                '\$${kit.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cartTeal,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                kit.description,
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
                    label: l10n.kitDetailsAgePlus(kit.age),
                  ),
                  _TagChip(
                    icon: Icons.inventory_2_outlined,
                    label: l10n.kitDetailsItemsCount(kit.kitItems.length),
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
                  onPressed: isAddingToCart ? null : onAddToCart,
                  icon: isAddingToCart
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_cart_outlined, size: 22),
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
