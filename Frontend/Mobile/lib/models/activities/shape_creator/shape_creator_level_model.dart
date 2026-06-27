import 'dart:convert';

import 'shape_creator_checklist_item_model.dart';

class ShapeCreatorLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final String? imageUrl;
  final String prompt;
  final List<ShapeCreatorChecklistItemModel> checklist;

  const ShapeCreatorLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.imageUrl,
    required this.prompt,
    required this.checklist,
  });

  factory ShapeCreatorLevelModel.fromJson(Map<String, dynamic> json) {
    final targetImage = _extractTargetImage(json);
    final meta = _parseMeta(targetImage['meta'] ?? json['meta']);

    return ShapeCreatorLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      imageUrl: targetImage['url']?.toString(),
      prompt: (meta['prompt'] ??
          'Build this object using the pieces in your kit.')
          .toString(),
      checklist: _parseChecklist(
  json['images']
      ?.where(
        (item) =>
            item['role']?.toString().toUpperCase() == 'CHOICE',
      )
      .toList(),
),
    );
  }

  static List<ShapeCreatorChecklistItemModel> _parseChecklist(dynamic value) {
  if (value is! List) {
    return <ShapeCreatorChecklistItemModel>[];
  }

  return value
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);

        final text =
    (map['label'] ?? map['description'] ?? '').toString();

return ShapeCreatorChecklistItemModel(
  id: map['id'].toString(),
  text: text == 'هل استعمل نفس الالوان الموضحه بالصورة'
      ? 'هل استخدم نفس الألوان الموجودة في الصورة؟'
      : text == 'هل صنع نفس الشكل في الصورة'
          ? 'هل صنع نفس الشكل الموجود في الصورة؟'
          : text,
);
      })
      .where((item) => item.text.isNotEmpty)
      .toList();
}
static List<ShapeCreatorLevelModel> listFromPageResponse(
    Map<String, dynamic> json,
) {
  final content = json['content'];

  if (content is! List) return <ShapeCreatorLevelModel>[];

  return content
      .whereType<Map>()
      .map(
        (item) => ShapeCreatorLevelModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList();
}

  static Map<String, dynamic> _extractTargetImage(Map<String, dynamic> json) {
    final candidates = [
      json['images'],
      json['levelImages'],
      json['media'],
      json['items'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final images = candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        final targetImages = images.where(
              (image) => image['role']?.toString().toUpperCase() == 'TARGET',
        );

        if (targetImages.isNotEmpty) {
          return targetImages.first;
        }
      }
    }

    if (json['role']?.toString().toUpperCase() == 'TARGET') {
      return json;
    }

    return json;
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