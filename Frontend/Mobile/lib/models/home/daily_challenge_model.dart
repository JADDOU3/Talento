class DailyChallengeModel {
  final int id;
  final String question;
  final List<String> choices;

  const DailyChallengeModel({
    required this.id,
    required this.question,
    required this.choices,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: _parseInt(
        json['id'] ??
            json['challengeId'] ??
            json['challenge_id'],
      ),
      question: (
          json['question'] ??
              json['title'] ??
              json['text'] ??
              ''
      ).toString(),
      choices: _parseChoices(
        json['choices'] ??
            json['options'] ??
            json['answers'],
      ),
    );
  }

  bool get isValid {
    return id != 0 && question.trim().isNotEmpty && choices.isNotEmpty;
  }

  static List<String> _parseChoices(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
        if (item is Map<String, dynamic>) {
          return item['text'] ??
              item['label'] ??
              item['choice'] ??
              item['answer'] ??
              '';
        }

        return item;
      })
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class DailyChallengeAnswerModel {
  final bool correct;
  final String? correctAnswer;

  const DailyChallengeAnswerModel({
    required this.correct,
    required this.correctAnswer,
  });

  factory DailyChallengeAnswerModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeAnswerModel(
      correct: _parseBool(
        json['correct'] ??
            json['isCorrect'] ??
            json['is_correct'],
      ),
      correctAnswer: (
          json['correctAnswer'] ??
              json['correct_answer'] ??
              json['answer']
      )?.toString(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value.toString().trim().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes' ||
        text == 'correct';
  }
}