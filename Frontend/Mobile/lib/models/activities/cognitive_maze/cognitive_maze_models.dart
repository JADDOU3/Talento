import 'dart:convert';

/// One answer choice for a Cognitive Maze level.
///
/// Order matters: choice[i] corresponds to
/// CognitiveMazeLevelConfig.endPoints[i] for the same level — the developer
/// must lay out endPoints in the coordinate picker in the SAME order the
/// backend returns choices, exactly like start/end points are manually
/// measured per level in the Bodily Maze config.
class MazeChoice {
  final String icon;
  final bool isCorrect;

  const MazeChoice({required this.icon, required this.isCorrect});

  factory MazeChoice.fromJson(Map<String, dynamic> json) {
    return MazeChoice(
      icon: (json['icon'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
    );
  }
}

/// One Cognitive Maze level. Unlike Bodily Maze, a level has:
/// - one TARGET image (the maze artwork + a question/prompt in its meta)
/// - one CHOICE image (no url — just meta describing the answer choices)
class CognitiveMazeLevel {
  final int id;
  final int levelNumber;
  final String description;
  final String imageUrl;
  final String question;
  final List<MazeChoice> choices;

  const CognitiveMazeLevel({
    required this.id,
    required this.levelNumber,
    required this.description,
    required this.imageUrl,
    required this.question,
    required this.choices,
  });

  /// Index of the single correct choice, matching the order endpoints are
  /// configured in CognitiveMazeLevelConfig.endPoints. -1 if none/misconfigured.
  int get correctChoiceIndex => choices.indexWhere((c) => c.isCorrect);

  factory CognitiveMazeLevel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List? ?? [];

    String imageUrl = '';
    String question = '';
    List<MazeChoice> choices = [];

    for (final img in images) {
      if (img is! Map) continue;
      final role = (img['role'] ?? '').toString();
      final meta = _decodeMeta(img['meta']);

      if (role == 'TARGET') {
        final url = img['url'];
        if (url != null && url.toString().trim().isNotEmpty) {
          imageUrl = url.toString();
        }
        question = (meta['question'] ?? meta['prompt'] ?? '').toString();
      } else if (role == 'CHOICE') {
        final rawChoices = meta['choices'];
        if (rawChoices is List) {
          choices = rawChoices
              .whereType<Map>()
              .map((c) => MazeChoice.fromJson(Map<String, dynamic>.from(c)))
              .toList();
        }
      }
    }

    return CognitiveMazeLevel(
      id: _toInt(json['id']),
      levelNumber: _toInt(json['levelNumber']),
      description: (json['description'] ?? '').toString(),
      imageUrl: imageUrl,
      question: question,
      choices: choices,
    );
  }

  /// `meta` comes back as a JSON-encoded STRING (not a nested object), so it
  /// needs its own decode pass.
  static Map<String, dynamic> _decodeMeta(dynamic meta) {
    if (meta is String && meta.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(meta);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // malformed meta — treat as empty rather than crash the level load
      }
    }
    return const {};
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}