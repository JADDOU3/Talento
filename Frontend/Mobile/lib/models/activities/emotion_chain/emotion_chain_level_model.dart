import 'emotion_chain_challenge_model.dart';

class EmotionChainLevelModel {
  final int id;
  final int levelNumber;
  final String name;

  /// Ordered TARGET steps for this level.
  final List<EmotionChainChallengeModel> challenges;

  const EmotionChainLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.challenges,
  });

  /// The chainStep of every step, used by the progress bar.
  List<String> get chainSteps =>
      challenges.map((c) => c.chainStep).toList();

  factory EmotionChainLevelModel.fromJson(Map<String, dynamic> json) {
    final images = _extractImages(json);

    // Keep only TARGET images (this activity has no CHOICE images).
    final targets = images.where((img) {
      final meta = img['meta'];
      final role = (img['role'] ??
              (meta is Map ? meta['role'] : null) ??
              'TARGET')
          .toString()
          .toUpperCase();
      return role == 'TARGET';
    }).toList();

    // Order by sortOrder, then by challengeId.
    targets.sort((a, b) {
      final ao = _parseInt(a['sortOrder']);
      final bo = _parseInt(b['sortOrder']);
      if (ao != bo) return ao.compareTo(bo);
      return _challengeId(a).compareTo(_challengeId(b));
    });

    final challenges = targets
        .map((img) => EmotionChainChallengeModel.fromImage(img))
        .where((c) => c.challengeId != 0)
        .toList();

    return EmotionChainLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      challenges: challenges,
    );
  }

  static List<EmotionChainLevelModel> listFromPageResponse(
    Map<String, dynamic> json,
  ) {
    final content = json['content'];
    if (content is! List) return <EmotionChainLevelModel>[];

    return content
        .whereType<Map>()
        .map((item) =>
            EmotionChainLevelModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static int _challengeId(Map<String, dynamic> img) {
    final meta = img['meta'];
    if (meta is Map) return _parseInt(meta['challengeId']);
    return 0;
  }

  static List<Map<String, dynamic>> _extractImages(Map<String, dynamic> json) {
    final candidates = [
      json['images'],
      json['levelImages'],
      json['media'],
      json['items'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final result = candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        if (result.isNotEmpty) return result;
      }
    }
    return <Map<String, dynamic>>[];
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
