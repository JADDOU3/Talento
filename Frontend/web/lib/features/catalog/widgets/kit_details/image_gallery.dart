import 'package:flutter/material.dart';
import 'kit_network_image.dart';

/// Main product image with a row of thumbnails below.
class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    this.mainAsset,
    this.mainImageUrl,
    this.thumbnailAssets = const [],
    this.thumbnailUrls = const [],
    this.borderRadius = 20,
  });

  final String? mainAsset;
  final String? mainImageUrl;
  final List<String> thumbnailAssets;
  final List<String> thumbnailUrls;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final thumbs = thumbnailUrls.isNotEmpty
        ? thumbnailUrls
        : thumbnailAssets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: AspectRatio(
            aspectRatio: 1.05,
            child: KitNetworkImage(
              imageUrl: mainImageUrl,
              assetPath: mainAsset,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (thumbs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < thumbs.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius * 0.65),
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: _thumbAt(i, thumbs),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _thumbAt(int index, List<String> thumbs) {
    final value = thumbs[index];
    if (value.startsWith('http')) {
      return KitNetworkImage(imageUrl: value, fit: BoxFit.cover);
    }
    return KitNetworkImage(assetPath: value, fit: BoxFit.cover);
  }
}
