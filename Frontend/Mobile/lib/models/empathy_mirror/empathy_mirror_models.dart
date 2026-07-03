import 'dart:convert';

/// ===================== LEVEL =====================
class EmpathyMirrorLevel {
  final int id;
  final int levelNumber;
  final String description;
  final List<EmpathyMirrorImage> images;

  const EmpathyMirrorLevel({
    required this.id,
    required this.levelNumber,
    required this.description,
    required this.images,
  });

  factory EmpathyMirrorLevel.fromJson(Map<String, dynamic> json) {
    return EmpathyMirrorLevel(
      id: _int(json['id']),
      levelNumber: _int(json['levelNumber']),
      description: (json['description'] ?? '').toString(),
      images: _parseImages(json['images']),
    );
  }

  /// TARGET images sorted by sortOrder = the challenges in play order.
  List<EmpathyMirrorImage> get challenges {
    final t = images.where((i) => i.isTarget).toList();
    t.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return t;
  }

  /// CHOICE images sorted by challengeId (from meta).
  List<EmpathyMirrorImage> get choiceImages =>
      images.where((i) => i.isChoice).toList();

  /// Build correct-answer map: challengeId → icon string.
  Map<int, String> get correctAnswers {
    final map = <int, String>{};
    for (final img in choiceImages) {
      final challengeId = img.meta['challengeId'];
      if (challengeId == null) continue;
      final choices = img.meta['choices'];
      if (choices is! List) continue;
      for (final c in choices) {
        if (c is Map && c['isCorrect'] == true) {
          map[_int(challengeId)] = c['icon']?.toString() ?? '';
          break;
        }
      }
    }
    return map;
  }

  /// Whether this level uses on-screen choices (Level 2).
  bool get isChoiceLevel => choiceImages.isNotEmpty;

  /// Level 3 split-screen: the shared intro video/scene (no "character" tag).
  /// Falls back to the first challenge if none is explicitly untagged.
  EmpathyMirrorImage? get introChallenge {
    final untagged = challenges.where((c) => c.character == null).toList();
    if (untagged.isNotEmpty) return untagged.first;
    return challenges.isNotEmpty ? challenges.first : null;
  }

  /// Level 3 split-screen: the question challenge for character 1 or 2.
  EmpathyMirrorImage? challengeForCharacter(int character) {
    for (final c in challenges) {
      if (c.character == character) return c;
    }
    return null;
  }

  static List<EmpathyMirrorImage> _parseImages(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) =>
          EmpathyMirrorImage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// ===================== IMAGE =====================
class EmpathyMirrorImage {
  final int id;
  final String url;
  final String role; // TARGET | CHOICE
  final String label;
  final int sortOrder;
  final Map<String, dynamic> meta;

  const EmpathyMirrorImage({
    required this.id,
    required this.url,
    required this.role,
    required this.label,
    required this.sortOrder,
    required this.meta,
  });

  factory EmpathyMirrorImage.fromJson(Map<String, dynamic> json) {
    return EmpathyMirrorImage(
      id: _int(json['id']),
      url: (json['url'] ?? '').toString(),
      role: (json['role'] ?? '').toString().toUpperCase(),
      label: (json['label'] ?? '').toString(),
      sortOrder: _int(json['sortOrder']),
      meta: _parseMeta(json['meta']),
    );
  }

  bool get isTarget => role == 'TARGET';
  bool get isChoice => role == 'CHOICE';
  bool get hasVideo => url.trim().isNotEmpty;

  /// Type from meta: video | followup | video_continue
  String get type => (meta['type'] ?? 'video').toString();
  bool get isFollowup => type == 'followup';
  bool get isVideoContinue => type == 'video_continue';

  String get prompt => (meta['prompt'] ?? '').toString();
  String get question => (meta['question'] ?? '').toString();
  int get challengeId => _int(meta['challengeId']);

  /// Level 3 split-screen: which character this challenge belongs to (1 or 2).
  /// Null for the shared intro video (no "character" field in meta).
  int? get character {
    final v = meta['character'];
    if (v == null) return null;
    return _int(v);
  }

  /// CHOICE image: list of choices.
  List<ChoiceModel> get choices {
    final raw = meta['choices'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => ChoiceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Map<String, dynamic> _parseMeta(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    if (v is String && v.trim().isNotEmpty) {
      try {
        final d = jsonDecode(v);
        if (d is Map) return Map<String, dynamic>.from(d);
      } catch (_) {}
    }
    return {};
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// ===================== CHOICE =====================
class ChoiceModel {
  final String icon;
  final bool isCorrect;

  const ChoiceModel({required this.icon, required this.isCorrect});

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      icon: (json['icon'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
    );
  }
}
