import 'package:flutter/material.dart';

/// Renders a network [imageUrl] or local [assetPath] without changing layout.
class KitNetworkImage extends StatelessWidget {
  const KitNetworkImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final String? assetPath;
  final BoxFit fit;

  bool get _hasNetwork =>
      imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    if (_hasNetwork) {
      return Image.network(
        imageUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
    );
  }
}
