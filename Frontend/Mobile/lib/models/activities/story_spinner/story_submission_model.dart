class StorySubmission {
  final int id;
  final String storyText;
  final List<String> keywords;
  final DateTime? createdAt;

  const StorySubmission({
    required this.id,
    required this.storyText,
    required this.keywords,
    required this.createdAt,
  });

  factory StorySubmission.fromJson(Map<String, dynamic> json) {
    return StorySubmission(
      id: _parseInt(json['id']),
      storyText: (json['storyText'] ??
          json['story_text'] ??
          json['text'] ??
          json['transcribedText'] ??
          '')
          .toString(),
      keywords: _parseKeywords(json['keywords']),
      createdAt: _parseDateTime(
        json['createdAt'] ?? json['created_at'] ?? json['submittedAt'],
      ),
    );
  }

  static List<String> _parseKeywords(dynamic value) {
    if (value is! List) return <String>[];

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }
}