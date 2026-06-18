class ConflictResolutionChallengeModel {
  final int challengeId;
  final String type;
  final String prompt;
  final String question;
  final String? videoUrl;
  final int? timerSeconds;
  final String? correctAnswerIcon;

  const ConflictResolutionChallengeModel({
    required this.challengeId,
    required this.type,
    required this.prompt,
    required this.question,
    required this.videoUrl,
    required this.timerSeconds,
    required this.correctAnswerIcon,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.trim().isNotEmpty;

  bool get hasTimer => timerSeconds != null && timerSeconds! > 0;

  bool get hasCorrectAnswer {
    return correctAnswerIcon != null && correctAnswerIcon!.trim().isNotEmpty;
  }

  bool get isValid {
    return challengeId != 0 &&
        (prompt.trim().isNotEmpty || question.trim().isNotEmpty || hasVideo);
  }

  factory ConflictResolutionChallengeModel.fromTargetMeta({
    required Map<String, dynamic> meta,
    required String? videoUrl,
    required String? correctAnswerIcon,
  }) {
    final timer = _parseNullableInt(meta['timer']);

    return ConflictResolutionChallengeModel(
      challengeId: _parseInt(meta['challengeId']),
      type: (meta['type'] ?? 'video').toString(),
      prompt: (meta['prompt'] ?? '').toString(),
      question: (meta['question'] ?? '').toString(),
      videoUrl: videoUrl?.trim(),
      timerSeconds: timer != null && timer > 0 ? timer : null,
      correctAnswerIcon: correctAnswerIcon?.trim(),
    );
  }

  bool isCorrectQrValue(String scannedValue) {
    final expected = correctAnswerIcon?.trim().toLowerCase();
    final actual = scannedValue.trim().toLowerCase();

    if (expected == null || expected.isEmpty) return false;

    return actual == expected;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}