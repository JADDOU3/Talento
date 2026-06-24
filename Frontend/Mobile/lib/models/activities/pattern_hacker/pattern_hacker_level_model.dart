import 'dart:convert';

import 'pattern_hacker_challenge_model.dart';

class PatternHackerLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final List<PatternHackerChallengeModel> challenges;

  const PatternHackerLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.challenges,
  });

  factory PatternHackerLevelModel.fromJson(Map<String, dynamic> json) {
    final images = _extractImages(json);
    final challenges = _buildChallengesFromImages(images);

    return PatternHackerLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      challenges: challenges,
    );
  }

  static List<PatternHackerLevelModel> listFromPageResponse(
    Map<String, dynamic> json,
  ) {
    final content = json['content'];

    if (content is! List) return <PatternHackerLevelModel>[];

    return content
        .whereType<Map>()
        .map(
          (item) => PatternHackerLevelModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static List<Map<String, dynamic>> _extractImages(Map<String, dynamic> json) {
    final candidates = [
      json['images'],
      json['levelImages'],
      json['media'],
      json['items'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final result = candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        if (result.isNotEmpty) return result;
      }
    }

    final directMeta = _parseMeta(json['meta']);
    if (directMeta.isNotEmpty) {
      return [
        {
          'meta': directMeta,
          'sortOrder': json['sortOrder'] ?? 0,
        }
      ];
    }

    return <Map<String, dynamic>>[];
  }

  /// Groups all images by `challengeId` and merges their meta together so the
  /// TARGET (sequence + expectedNext) and the CHOICE (choices) become a single
  /// challenge. Images are processed in `sortOrder` order.
  static List<PatternHackerChallengeModel> _buildChallengesFromImages(
    List<Map<String, dynamic>> images,
  ) {
    final sortedImages = [...images];

    sortedImages.sort((a, b) {
      final aOrder = _parseInt(a['sortOrder']);
      final bOrder = _parseInt(b['sortOrder']);
      return aOrder.compareTo(bOrder);
    });

    final groupedMeta = <int, Map<String, dynamic>>{};

    for (final image in sortedImages) {
      final meta = _parseMeta(image['meta']);

      if (meta.isEmpty) continue;

      final challengeId = _parseInt(meta['challengeId']);

      if (challengeId == 0) continue;

      groupedMeta.putIfAbsent(challengeId, () => <String, dynamic>{});
      groupedMeta[challengeId]!.addAll(meta);
    }

    final challengeIds = groupedMeta.keys.toList()..sort();

    return challengeIds
        .map(
          (challengeId) => PatternHackerChallengeModel.fromMergedMeta(
            challengeId,
            groupedMeta[challengeId]!,
          ),
        )
        .where((challenge) => challenge.isValid)
        .toList();
  }

  static Map<String, dynamic> _parseMeta(dynamic value) {
    if (value == null) return <String, dynamic>{};

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    return <String, dynamic>{};
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
