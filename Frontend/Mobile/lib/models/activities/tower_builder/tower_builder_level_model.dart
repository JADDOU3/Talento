import 'dart:convert';

import 'tower_builder_checklist_item_model.dart';

class TowerBuilderLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final List<TowerBuilderChallengeModel> challenges;
  final int activeChallengeIndex;
  final List<TowerBuilderChecklistItemModel> checklist;

  const TowerBuilderLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.challenges,
    required this.activeChallengeIndex,
    required this.checklist,
  });

  String? get imageUrl {
    if (challenges.isEmpty) return null;

    final safeIndex = activeChallengeIndex.clamp(0, challenges.length - 1);
    return challenges[safeIndex].imageUrl;
  }

  String get prompt {
    if (challenges.isEmpty) return 'صورة البناء';

    final safeIndex = activeChallengeIndex.clamp(0, challenges.length - 1);
    return challenges[safeIndex].label.isNotEmpty
        ? challenges[safeIndex].label
        : 'صورة البناء';
  }

  TowerBuilderLevelModel withActiveChallenge(int index) {
    return TowerBuilderLevelModel(
      id: id,
      levelNumber: levelNumber,
      name: name,
      challenges: challenges,
      activeChallengeIndex: index,
      checklist: checklist,
    );
  }

  factory TowerBuilderLevelModel.fromJson(Map<String, dynamic> json) {
    final images = _extractImages(json);

    return TowerBuilderLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber']),
      name: (json['name'] ?? json['title'] ?? json['description'] ?? '')
          .toString(),
      challenges: _parseChallenges(images),
      activeChallengeIndex: 0,
      checklist: _parseChecklistFromChoiceImages(images),
    );
  }

  static List<TowerBuilderLevelModel> listFromPageResponse(
      Map<String, dynamic> json,
      ) {
    final content = json['content'];

    if (content is! List) return <TowerBuilderLevelModel>[];

    return content
        .whereType<Map>()
        .map(
          (item) => TowerBuilderLevelModel.fromJson(
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

  static List<TowerBuilderChallengeModel> _parseChallenges(
      List<Map<String, dynamic>> images,
      ) {
    final targetImages = images
        .where(
          (image) => image['role']?.toString().toUpperCase() == 'TARGET',
    )
        .toList();

    targetImages.sort((a, b) {
      final aMeta = _parseMeta(a['meta']);
      final bMeta = _parseMeta(b['meta']);

      final aChallengeId = _parseInt(aMeta['challengeId']);
      final bChallengeId = _parseInt(bMeta['challengeId']);

      if (aChallengeId != bChallengeId) {
        return aChallengeId.compareTo(bChallengeId);
      }

      return _parseInt(a['sortOrder']).compareTo(_parseInt(b['sortOrder']));
    });

    return targetImages
        .map((image) {
      final meta = _parseMeta(image['meta']);

      return TowerBuilderChallengeModel(
        id: _parseInt(image['id']),
        challengeId: _parseInt(meta['challengeId']),
        imageUrl: image['url']?.toString(),
        label: (image['label'] ?? 'صورة البناء').toString(),
        sortOrder: _parseInt(image['sortOrder']),
      );
    })
        .where((challenge) => challenge.id != 0)
        .toList();
  }

  static List<TowerBuilderChecklistItemModel> _parseChecklistFromChoiceImages(
      List<Map<String, dynamic>> images,
      ) {
    final choiceImages = images
        .where(
          (image) => image['role']?.toString().toUpperCase() == 'CHOICE',
    )
        .toList();

    choiceImages.sort(
          (a, b) => _parseInt(a['sortOrder']).compareTo(
        _parseInt(b['sortOrder']),
      ),
    );

    return choiceImages
        .map((image) {
      final meta = _parseMeta(image['meta']);
      final choiceIndex = _parseInt(meta['choiceIndex']);
      final label = image['label']?.toString() ?? '';

      final isHelpQuestion =
          choiceIndex == 4 || label.trim() == 'هل تمت مساعدته';

      return TowerBuilderChecklistItemModel.fromJson(
        {
          'id': image['id']?.toString() ?? '',
          'text': label,
          'requiredForCompletion': !isHelpQuestion,
        },
      );
    })
        .where((item) => item.id.isNotEmpty && item.text.isNotEmpty)
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

class TowerBuilderChallengeModel {
  final int id;
  final int challengeId;
  final String? imageUrl;
  final String label;
  final int sortOrder;

  const TowerBuilderChallengeModel({
    required this.id,
    required this.challengeId,
    required this.imageUrl,
    required this.label,
    required this.sortOrder,
  });
}