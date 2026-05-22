import 'package:flutter/material.dart';

/// Main product image with a row of thumbnails below.
class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    required this.mainAsset,
    required this.thumbnailAssets,
    this.borderRadius = 20,
  });

  final String mainAsset;
  final List<String> thumbnailAssets;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: AspectRatio(
            aspectRatio: 1.05,
            child: Image.asset(
              mainAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _placeholder(context),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < thumbnailAssets.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius * 0.65),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.asset(
                      thumbnailAssets[i],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholder(context),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
    );
  }
}
