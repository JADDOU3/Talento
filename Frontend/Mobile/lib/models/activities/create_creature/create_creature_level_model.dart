// import 'dart:convert';
//
// import 'create_creature_challenge_model.dart';
// import 'create_creature_choice_model.dart';
//
// class CreateCreatureLevelModel {
//   final int id;
//   final int levelNumber;
//   final String name;
//   final List<CreateCreatureChallengeModel> challenges;
//
//   const CreateCreatureLevelModel({
//     required this.id,
//     required this.levelNumber,
//     required this.name,
//     required this.challenges,
//   });
//
//   factory CreateCreatureLevelModel.fromJson(Map<String, dynamic> json) {
//     final images = _extractImages(json);
//     final challenges = _buildChallengesFromImages(images);
//
//     return CreateCreatureLevelModel(
//       id: _parseInt(json['id']),
//       levelNumber: _parseInt(json['levelNumber']),
//       name: (json['name'] ?? json['title'] ?? '').toString(),
//       challenges: challenges,
//     );
//   }
//
//   static List<CreateCreatureLevelModel> listFromPageResponse(
//       Map<String, dynamic> json,
//       ) {
//     final content = json['content'];
//
//     if (content is! List) return <CreateCreatureLevelModel>[];
//
//     return content
//         .whereType<Map>()
//         .map(
//           (item) => CreateCreatureLevelModel.fromJson(
//         Map<String, dynamic>.from(item),
//       ),
//     )
//         .toList();
//   }
//
//   static List<Map<String, dynamic>> _extractImages(Map<String, dynamic> json) {
//     final candidates = [
//       json['images'],
//       json['levelImages'],
//       json['media'],
//       json['items'],
//     ];
//
//     for (final candidate in candidates) {
//       if (candidate is List) {
//         final result = candidate
//             .whereType<Map>()
//             .map((item) => Map<String, dynamic>.from(item))
//             .toList();
//
//         if (result.isNotEmpty) return result;
//       }
//     }
//
//     return <Map<String, dynamic>>[];
//   }
//
//   static List<CreateCreatureChallengeModel> _buildChallengesFromImages(
//       List<Map<String, dynamic>> images,
//       ) {
//     final sortedImages = [...images];
//
//     sortedImages.sort((a, b) {
//       final aOrder = _parseInt(a['sortOrder']);
//       final bOrder = _parseInt(b['sortOrder']);
//       return aOrder.compareTo(bOrder);
//     });
//
//     final targetMeta = <int, Map<String, dynamic>>{};
//     final choicesMeta = <int, List<CreateCreatureChoiceModel>>{};
//
//     for (final image in sortedImages) {
//       final meta = _parseMeta(image['meta']);
//
//       if (meta.isEmpty) continue;
//
//       final challengeId = _parseInt(meta['challengeId']);
//
//       if (challengeId == 0) continue;
//
//       if (meta.containsKey('choices')) {
//         final choices = _parseChoices(meta['choices']);
//         choicesMeta[challengeId] = choices;
//       } else {
//         targetMeta.putIfAbsent(challengeId, () => <String, dynamic>{});
//         targetMeta[challengeId]!.addAll(meta);
//       }
//     }
//
//     final challengeIds = targetMeta.keys.toList()..sort();
//
//     return challengeIds
//         .map(
//           (challengeId) => CreateCreatureChallengeModel.fromMergedMeta(
//         challengeId,
//         targetMeta[challengeId]!,
//         choicesMeta[challengeId] ?? [],
//       ),
//     )
//         .where((c) => c.type != CreateCreatureChallengeType.unknown)
//         .toList();
//   }
//
//   static List<CreateCreatureChoiceModel> _parseChoices(dynamic value) {
//     if (value is! List) return <CreateCreatureChoiceModel>[];
//
//     return value
//         .whereType<Map>()
//         .map(
//           (item) => CreateCreatureChoiceModel.fromJson(
//         Map<String, dynamic>.from(item),
//       ),
//     )
//         .toList();
//   }
//
//   static Map<String, dynamic> _parseMeta(dynamic value) {
//     if (value == null) return <String, dynamic>{};
//
//     if (value is Map) {
//       return Map<String, dynamic>.from(value);
//     }
//
//     if (value is String && value.trim().isNotEmpty) {
//       try {
//         final decoded = jsonDecode(value);
//
//         if (decoded is Map) {
//           return Map<String, dynamic>.from(decoded);
//         }
//       } catch (_) {
//         return <String, dynamic>{};
//       }
//     }
//
//     return <String, dynamic>{};
//   }
//
//   static int _parseInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     return int.tryParse(value.toString()) ?? 0;
//   }
// }

import 'dart:convert';

import 'create_creature_challenge_model.dart';
import 'create_creature_choice_model.dart';

class CreateCreatureLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final List<CreateCreatureChallengeModel> challenges;

  const CreateCreatureLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.challenges,
  });

  factory CreateCreatureLevelModel.fromJson(Map<String, dynamic> json) {
    final images = _extractImages(json);
    final challenges = _buildChallengesFromImages(images);

    return CreateCreatureLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      challenges: challenges,
    );
  }

  static List<CreateCreatureLevelModel> listFromPageResponse(
      Map<String, dynamic> json,
      ) {
    final content = json['content'];

    if (content is! List) return <CreateCreatureLevelModel>[];

    return content
        .whereType<Map>()
        .map(
          (item) => CreateCreatureLevelModel.fromJson(
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

    return <Map<String, dynamic>>[];
  }

  static List<CreateCreatureChallengeModel> _buildChallengesFromImages(
      List<Map<String, dynamic>> images,
      ) {
    final sortedImages = [...images];

    sortedImages.sort((a, b) {
      final aOrder = _parseInt(a['sortOrder']);
      final bOrder = _parseInt(b['sortOrder']);
      return aOrder.compareTo(bOrder);
    });

    final targetImagesByChallenge = <int, List<Map<String, dynamic>>>{};
    final choicesMeta = <int, List<CreateCreatureChoiceModel>>{};

    for (final image in sortedImages) {
      final meta = _parseMeta(image['meta']);

      if (meta.isEmpty) continue;

      final challengeId = _parseInt(meta['challengeId']);

      if (challengeId == 0) continue;

      if (meta.containsKey('choices')) {
        final choices = _parseChoices(meta['choices']);
        choicesMeta[challengeId] = choices;
      } else {
        final enriched = Map<String, dynamic>.from(meta);
        // enriched['_imageUrl'] = image['url']?.toString();
        // enriched['_imageS3Key'] = image['s3Key']?.toString();

        targetImagesByChallenge.putIfAbsent(challengeId, () => []);
        targetImagesByChallenge[challengeId]!.add(enriched);
      }
    }

    final challengeIds = targetImagesByChallenge.keys.toList()..sort();

    return challengeIds
        .map(
          (challengeId) => CreateCreatureChallengeModel.fromMergedMeta(
        challengeId,
        targetImagesByChallenge[challengeId]!,
        choicesMeta[challengeId] ?? [],
      ),
    )
        .where((c) => c.type != CreateCreatureChallengeType.unknown)
        .toList();
  }

  static List<CreateCreatureChoiceModel> _parseChoices(dynamic value) {
    if (value is! List) return <CreateCreatureChoiceModel>[];

    return value
        .whereType<Map>()
        .map(
          (item) => CreateCreatureChoiceModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
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