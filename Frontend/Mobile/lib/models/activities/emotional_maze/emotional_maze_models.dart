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
    return EmotionalMazeLevel(
      id: json['id'] as int,
      levelNumber: json['levelNumber'] as int,
      imageUrl: json['imageUrl'] as String,
      question: json['question'] as String,
    );
  }
}