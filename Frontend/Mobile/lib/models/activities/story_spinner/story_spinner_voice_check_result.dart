class StorySpinnerVoiceCheckResult {
  final String text;
  final bool success;
  final List<String> missingKeywords;
  final String message;

  const StorySpinnerVoiceCheckResult({
    required this.text,
    required this.success,
    required this.missingKeywords,
    required this.message,
  });

  factory StorySpinnerVoiceCheckResult.fromJson(Map<String, dynamic> json) {
    return StorySpinnerVoiceCheckResult(
      text: (json['text'] ?? '').toString(),
      success: json['success'] == true,
      missingKeywords: _parseStringList(json['missingKeywords']),
      message: (json['message'] ?? '').toString(),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return <String>[];

    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
}