import 'dart:convert';

class EmotionalMazeLevel {
  final int id;
  final int levelNumber;
  final String imageUrl;
  final String question;

  const EmotionalMazeLevel({
    required this.id,
    required this.levelNumber,
    required this.imageUrl,
    required this.question,
  });

  factory EmotionalMazeLevel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    // The maze background + the level's question live on the TARGET image.
    final target = images.firstWhere(
          (img) => img['role'] == 'TARGET',
      orElse: () => <String, dynamic>{},
    );

    final imageUrl = target['url'] as String? ?? '';

    String question = '';
    final metaRaw = target['meta'];
    if (metaRaw is String && metaRaw.isNotEmpty) {
      try {
        final meta = jsonDecode(metaRaw) as Map<String, dynamic>;
        // Your sample has both "prompt" and "question" with slightly
        // different wording — "question" is used as the primary field,
        // falling back to "prompt" if it's ever missing.
        question = meta['question'] as String? ??
            meta['prompt'] as String? ??
            '';
      } catch (_) {
        question = '';
      }
    }

    return EmotionalMazeLevel(
      id: json['id'] as int,
      levelNumber: json['levelNumber'] as int,
      imageUrl: imageUrl,
      question: question,
    );
  }
}