/// One Bodily Maze level. Each level has exactly one maze image.
/// The image `url` is a presigned S3 URL — use it directly with
/// Image.network(). Never use `s3Key` for display.
class BodilyMazeLevel {
  final int id;
  final int levelNumber;
  final String description;
  final String imageUrl;

  const BodilyMazeLevel({
    required this.id,
    required this.levelNumber,
    required this.description,
    required this.imageUrl,
  });

  factory BodilyMazeLevel.fromJson(Map<String, dynamic> json) {
    return BodilyMazeLevel(
      id: _toInt(json['id']),
      levelNumber: _toInt(json['levelNumber']),
      description: (json['description'] ?? '').toString(),
      imageUrl: _firstImageUrl(json['images']),
    );
  }

  /// Picks the url of the first image in the level (each level has one image).
  static String _firstImageUrl(dynamic images) {
    if (images is List) {
      for (final img in images) {
        if (img is Map) {
          final url = img['url'];
          if (url != null && url.toString().trim().isNotEmpty) {
            return url.toString();
          }
        }
      }
    }
    return '';
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
