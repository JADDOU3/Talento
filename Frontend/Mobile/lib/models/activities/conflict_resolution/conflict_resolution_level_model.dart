import 'dart:convert';

import 'conflict_resolution_challenge_model.dart';

class ConflictResolutionLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final List<ConflictResolutionChallengeModel> challenges;

  const ConflictResolutionLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.challenges,
  });

  factory ConflictResolutionLevelModel.fromJson(Map<String, dynamic> json) {
    final images = _extractImages(json);

    return ConflictResolutionLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      challenges: _buildChallengesFromImages(images),
    );
  }

  static List<ConflictResolutionLevelModel> listFromPageResponse(
      Map<String, dynamic> json,
      ) {
    final content = json['content'];

    if (content is! List) return <ConflictResolutionLevelModel>[];

    return content
        .whereType<Map>()
        .map(
          (item) => ConflictResolutionLevelModel.fromJson(
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
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  static List<ConflictResolutionChallengeModel> _buildChallengesFromImages(
      List<Map<String, dynamic>> images,
      ) {
    final sortedImages = [...images];

    sortedImages.sort((a, b) {
      final aOrder = _parseInt(a['sortOrder']);
      final bOrder = _parseInt(b['sortOrder']);
      return aOrder.compareTo(bOrder);
    });

    final targetByChallengeId = <int, Map<String, dynamic>>{};
    final videoUrlByChallengeId = <int, String?>{};
    final correctAnswerByChallengeId = <int, String>{};

    for (final image in sortedImages) {
      final role = (image['role'] ?? '').toString().toUpperCase();
      final meta = _parseMeta(image['meta']);

      if (meta.isEmpty) continue;

      final challengeId = _parseInt(meta['challengeId']);
      if (challengeId == 0) continue;

      if (role == 'TARGET') {
        targetByChallengeId[challengeId] = meta;
        videoUrlByChallengeId[challengeId] = _readUrl(image);
      }

      if (role == 'CHOICE') {
        final correctIcon = _readCorrectIconFromChoiceMeta(meta);

        if (correctIcon != null && correctIcon.trim().isNotEmpty) {
          correctAnswerByChallengeId[challengeId] = correctIcon.trim();
        }
      }
    }

    final challengeIds = targetByChallengeId.keys.toList()..sort();

    return challengeIds
        .map(
          (challengeId) => ConflictResolutionChallengeModel.fromTargetMeta(
        meta: targetByChallengeId[challengeId]!,
        videoUrl: videoUrlByChallengeId[challengeId],
        correctAnswerIcon: correctAnswerByChallengeId[challengeId],
      ),
    )
        .where((challenge) => challenge.isValid)
        .toList();
  }

  static String? _readUrl(Map<String, dynamic> image) {
    final candidates = [
      image['url'],
      image['imageUrl'],
      image['mediaUrl'],
      image['fileUrl'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();

      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  static String? _readCorrectIconFromChoiceMeta(Map<String, dynamic> meta) {
    final choices = meta['choices'];

    if (choices is! List) return null;

    for (final choice in choices) {
      if (choice is! Map) continue;

      final isCorrect = choice['isCorrect'] == true;

      if (isCorrect) {
        return choice['icon']?.toString();
      }
    }

    return null;
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