/// One TARGET step in an Emotion Chain level.
/// There are no CHOICE images in this activity — answers come from QR scans.
class EmotionChainChallengeModel {
  final int challengeId;

  /// 'video' (first step of a level — plays a video) or 'video_continue'.
  final String type;

  /// 'feeling' | 'action' | 'outcome'.
  final String chainStep;

  /// Optional — 1 or 2, only on feeling steps with multiple characters.
  final int? character;

  /// Optional — Level 1 only. Countdown seconds shown on the step screen.
  final int? timer;

  /// Situation text shown to the child.
  final String prompt;

  /// Question the child must answer.
  final String question;

  /// Video URL (ready-to-use, from the image `url` field — never s3Key).
  final String? url;

  /// Expected QR value for validation.
  /// NOTE: the QR encoding is a TODO to finalise with the team; we read it from
  /// meta if present, otherwise the cubit falls back to a documented rule.
  final String? expectedAnswer;

  const EmotionChainChallengeModel({
    required this.challengeId,
    required this.type,
    required this.chainStep,
    required this.character,
    required this.timer,
    required this.prompt,
    required this.question,
    required this.url,
    required this.expectedAnswer,
  });

  bool get isVideo => type == 'video';
  bool get hasTimer => timer != null && timer! > 0;
  bool get hasCharacter => character != null;

  factory EmotionChainChallengeModel.fromImage(Map<String, dynamic> image) {
    final meta = _parseMeta(image['meta']);

    return EmotionChainChallengeModel(
      challengeId: _parseInt(meta['challengeId']),
      type: (meta['type'] ?? 'video_continue').toString(),
      chainStep: (meta['chainStep'] ?? '').toString(),
      character: _parseIntOrNull(meta['character']),
      timer: _parseIntOrNull(meta['timer']),
      prompt: (meta['prompt'] ?? '').toString(),
      question: (meta['question'] ?? '').toString(),
      url: _parseUrl(image['url']),
      expectedAnswer: _parseExpected(meta),
    );
  }

  static String? _parseUrl(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String? _parseExpected(Map<String, dynamic> meta) {
    for (final key in ['expectedAnswer', 'answer', 'correctCard', 'correct']) {
      final v = meta[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return null;
  }

  static Map<String, dynamic> _parseMeta(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
