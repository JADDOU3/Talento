import 'dart:convert';

class DailyChallengeModel {
  final int id;
  final String question;
  final List<String> choices;

  final bool alreadyAnswered;
  final bool correct;
  final String? correctAnswer;

  const DailyChallengeModel({
    required this.id,
    required this.question,
    required this.choices,
    this.alreadyAnswered = false,
    this.correct = false,
    this.correctAnswer,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: _parseInt(
        json['id'] ??
            json['challengeId'] ??
            json['challenge_id'],
      ),
      question: _fixText(
        json['question'] ??
            json['title'] ??
            json['text'] ??
            '',
      ),
      choices: _parseChoices(
        json['choices'] ??
            json['options'] ??
            json['answers'],
      ),
      alreadyAnswered: _parseBool(
        json['alreadyAnswered'] ??
            json['already_answered'] ??
            json['answered'] ??
            json['isAnswered'] ??
            json['is_answered'],
      ),
      correct: _parseBool(
        json['correct'] ??
            json['isCorrect'] ??
            json['is_correct'],
      ),
      correctAnswer: _fixNullableText(
        json['correctAnswer'] ??
            json['correct_answer'] ??
            json['answer'],
      ),
    );
  }

  bool get isValid {
    return id != 0 &&
        question.trim().isNotEmpty &&
        (choices.isNotEmpty || alreadyAnswered);
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
          .map(_fixText)
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  static String _fixText(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) return text;

    final looksBroken = text.contains('Ø') ||
        text.contains('Ù') ||
        text.contains('Ã') ||
        text.contains('Â');

    if (!looksBroken) return text;

    try {
      return utf8.decode(latin1.encode(text)).trim();
    } catch (_) {
      return text;
    }
  }

  static String? _fixNullableText(dynamic value) {
    final fixed = _fixText(value);
    return fixed.trim().isEmpty ? null : fixed;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
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

class DailyChallengeAnswerModel {
  final bool correct;
  final String? correctAnswer;
  final bool alreadyAnswered;

  const DailyChallengeAnswerModel({
    required this.correct,
    required this.correctAnswer,
    this.alreadyAnswered = false,
  });

  factory DailyChallengeAnswerModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeAnswerModel(
      correct: DailyChallengeModel._parseBool(
        json['correct'] ??
            json['isCorrect'] ??
            json['is_correct'],
      ),
      correctAnswer: DailyChallengeModel._fixNullableText(
        json['correctAnswer'] ??
            json['correct_answer'] ??
            json['answer'],
      ),
      alreadyAnswered: DailyChallengeModel._parseBool(
        json['alreadyAnswered'] ??
            json['already_answered'] ??
            json['answered'] ??
            json['isAnswered'] ??
            json['is_answered'],
      ),
    );
  }
}