import 'dart:convert';

/// One choice inside a star's question.
class StarChoice {
  final String icon;
  final String label;
  final bool isCorrect;

  const StarChoice({
    required this.icon,
    required this.label,
    required this.isCorrect,
  });

  factory StarChoice.fromJson(Map<String, dynamic> j) => StarChoice(
        icon: (j['icon'] ?? '').toString(),
        label: (j['label'] ?? '').toString(),
        isCorrect: _boolOf(j['isCorrect']),
      );

  static bool _boolOf(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
}

/// One star = one question, tied to a challengeId that maps to a star
/// position in adventure_maze_level_config.dart.
class StarChallenge {
  final int challengeId;
  final String type; // "cognitive" | "emotional"
  final String prompt;
  final List<StarChoice> choices;

  const StarChallenge({
    required this.challengeId,
    required this.type,
    required this.prompt,
    required this.choices,
  });

  /// A challenge is "cognitive" if exactly one choice is correct,
  /// "emotional" if all choices are correct — regardless of the `type`
  /// string, which the backend may or may not set.
  bool get isCognitive => type.toLowerCase() == 'cognitive';
  bool get isEmotional => type.toLowerCase() == 'emotional';
}

/// A parsed Adventure Maze level as it comes off the API.
///
/// Splits the backend `images` array by role/label:
///  - `label == "map"`  → mapImageUrl (background)
///  - `label == "star-N-target"`  → question prompt
///  - `label == "star-N-choices"` → choice list
///
/// Never uses s3Key for display — only the `url` field.
class AdventureMazeLevel {
  final int id;
  final int levelNumber;
  final String description;
  final String mapImageUrl;
  final List<StarChallenge> challenges;

  const AdventureMazeLevel({
    required this.id,
    required this.levelNumber,
    required this.description,
    required this.mapImageUrl,
    required this.challenges,
  });

  factory AdventureMazeLevel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List? ?? []).whereType<Map>().toList();

    String mapUrl = '';
    // challengeId -> parsed pieces
    final targets = <int, Map<String, dynamic>>{};
    final choicesByChallenge = <int, List<StarChoice>>{};
    final sortOrders = <int, int>{};

    for (final img in images) {
      final label = (img['label'] ?? '').toString().toLowerCase();
      final role = (img['role'] ?? '').toString().toUpperCase();
      final meta = _parseMeta(img['meta']);
      final url = (img['url'] ?? '').toString();
      final sort = _toInt(img['sortOrder']);

      if (label == 'map' || meta['type'] == 'map') {
        if (url.isNotEmpty) mapUrl = url;
        continue;
      }

      final challengeId = _toInt(meta['challengeId']);
      if (challengeId == 0) continue;
      sortOrders.putIfAbsent(challengeId, () => sort);

      if (role == 'TARGET' || label.contains('target')) {
        targets[challengeId] = meta;
      } else if (role == 'CHOICE' || label.contains('choice')) {
        final rawChoices = (meta['choices'] as List? ?? []);
        choicesByChallenge[challengeId] = rawChoices
            .whereType<Map>()
            .map((m) => StarChoice.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
    }

    final challenges = <StarChallenge>[];
    for (final entry in targets.entries) {
      final cid = entry.key;
      final meta = entry.value;
      final choices = choicesByChallenge[cid] ?? const <StarChoice>[];
      challenges.add(StarChallenge(
        challengeId: cid,
        type: (meta['type'] ?? meta['challengeType'] ?? 'cognitive').toString(),
        prompt: (meta['prompt'] ?? meta['question'] ?? '').toString(),
        choices: choices,
      ));
    }

    // Sort challenges by sortOrder (fall back to challengeId).
    challenges.sort((a, b) {
      final sa = sortOrders[a.challengeId] ?? a.challengeId;
      final sb = sortOrders[b.challengeId] ?? b.challengeId;
      return sa.compareTo(sb);
    });

    return AdventureMazeLevel(
      id: _toInt(json['id']),
      levelNumber: _toInt(json['levelNumber']),
      description: (json['description'] ?? '').toString(),
      mapImageUrl: mapUrl,
      challenges: challenges,
    );
  }

  static Map<String, dynamic> _parseMeta(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
