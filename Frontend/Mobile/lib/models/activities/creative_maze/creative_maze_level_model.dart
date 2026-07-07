/// A single Creative Maze level as returned by
/// GET /api/levels/activity/{activityId}.
///
/// Only the fields the maze needs are parsed: id, levelNumber, and the maze
/// image url. Per the task, always use the `url` field for display — never
/// the s3Key.
class CreativeMazeLevelModel {
  final int id;
  final int levelNumber;
  final String imageUrl;

  const CreativeMazeLevelModel({
    required this.id,
    required this.levelNumber,
    required this.imageUrl,
  });

  factory CreativeMazeLevelModel.fromJson(Map<String, dynamic> json) {
    return CreativeMazeLevelModel(
      id: _asInt(json['id']),
      levelNumber: _asInt(json['levelNumber']),
      imageUrl: _firstImageUrl(json['images']),
    );
  }

  /// Parses the paged response body: { "content": [ {level}, ... ] }.
  static List<CreativeMazeLevelModel> listFromPageResponse(dynamic data) {
    final content = data is Map ? data['content'] : null;
    if (content is! List) return const [];
    return content
        .whereType<Map>()
        .map((e) => CreativeMazeLevelModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  static String _firstImageUrl(dynamic images) {
    if (images is List) {
      for (final img in images) {
        if (img is Map && img['url'] != null) {
          final url = img['url'].toString();
          if (url.isNotEmpty) return url;
        }
      }
    }
    return '';
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
