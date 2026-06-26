import 'dart:convert';

class SoundTrackerLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final String description;
  final List<SoundTrackerMediaModel> media;

  const SoundTrackerLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.description,
    required this.media,
  });

  factory SoundTrackerLevelModel.fromJson(Map<String, dynamic> json) {
    return SoundTrackerLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber'] ?? json['level_number']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      media: _extractMedia(json),
    );
  }

  static List<SoundTrackerLevelModel> listFromPageResponse(dynamic decoded) {
    final List content;

    if (decoded is Map<String, dynamic>) {
      content = decoded['content'] as List? ?? [];
    } else if (decoded is List) {
      content = decoded;
    } else {
      content = [];
    }

    return content
        .whereType<Map>()
        .map(
          (item) => SoundTrackerLevelModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  SoundTrackerMediaModel? get targetMedia {
    final targets = media.where((item) => item.isTarget).toList();

    targets.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (targets.isNotEmpty) return targets.first;

    if (media.isNotEmpty) return media.first;

    return null;
  }

  String get audioUrl {
    return targetMedia?.url.trim() ?? '';
  }

  bool get hasAudio {
    return audioUrl.isNotEmpty;
  }

  Map<String, dynamic> get targetMeta {
    return targetMedia?.meta ?? <String, dynamic>{};
  }

  int get challengeId {
    return _parseInt(targetMeta['challengeId'] ?? targetMeta['challenge_id']);
  }

  List<String> get expectedSequence {
    final target = targetMedia;

    if (target == null) return <String>[];

    final choices = target.meta['choices'];

    if (choices is List) {
      final parsedChoices = <_ExpectedSoundChoice>[];

      for (final choice in choices) {
        if (choice is! Map) continue;

        final data = Map<String, dynamic>.from(choice);

        final label = (data['label'] ??
            data['sound'] ??
            data['name'] ??
            data['value'] ??
            '')
            .toString()
            .trim();

        if (label.isEmpty) continue;

        parsedChoices.add(
          _ExpectedSoundChoice(
            label: label,
            order: _parseInt(data['order']),
          ),
        );
      }

      parsedChoices.sort((a, b) => a.order.compareTo(b.order));

      final result = parsedChoices.map((choice) => choice.label).toList();

      if (result.isNotEmpty) return result;
    }

    final labelFromTarget = target.label.trim();

    if (labelFromTarget.isNotEmpty) {
      return <String>[labelFromTarget];
    }

    final labelFromMeta = (target.meta['label'] ??
        target.meta['sound'] ??
        target.meta['name'] ??
        target.meta['value'] ??
        '')
        .toString()
        .trim();

    if (labelFromMeta.isNotEmpty) {
      return <String>[labelFromMeta];
    }

    return <String>[];
  }

  int get sectionCount {
    final sequenceCount = expectedSequence.length;

    if (sequenceCount > 0) return sequenceCount;

    if (levelNumber == 2 || levelNumber == 3) {
      return levelNumber;
    }

    return 1;
  }

  bool get isMultiSection {
    return sectionCount > 1;
  }

  bool isCorrectForSection({
    required int sectionIndex,
    required String scannedValue,
  }) {
    final sequence = expectedSequence;

    if (sectionIndex < 0 || sectionIndex >= sequence.length) {
      return false;
    }

    final expected = sequence[sectionIndex];

    return _matchesQrValue(
      expected: expected,
      scannedValue: scannedValue,
    );
  }

  static List<SoundTrackerMediaModel> _extractMedia(
      Map<String, dynamic> json,
      ) {
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
            .map(
              (item) => SoundTrackerMediaModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();

        if (result.isNotEmpty) return result;
      }
    }

    return <SoundTrackerMediaModel>[];
  }

  static bool _matchesQrValue({
    required String expected,
    required String scannedValue,
  }) {
    final normalizedExpected = _normalize(expected);

    if (normalizedExpected.isEmpty) return false;

    final candidates = _qrCandidates(scannedValue);

    for (final candidate in candidates) {
      if (_normalize(candidate) == normalizedExpected) {
        return true;
      }
    }

    return false;
  }

  static List<String> _qrCandidates(String scannedValue) {
    final raw = scannedValue.trim();

    if (raw.isEmpty) return <String>[];

    final candidates = <String>{raw};

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);

        for (final key in [
          'label',
          'value',
          'name',
          'sound',
          'cardLabel',
          'card_label',
          'qrValue',
          'qr_value',
        ]) {
          final value = map[key]?.toString().trim();

          if (value != null && value.isNotEmpty) {
            candidates.add(value);
          }
        }
      }
    } catch (_) {
      // QR may be plain text, not JSON.
    }

    final uri = Uri.tryParse(raw);

    if (uri != null && uri.pathSegments.isNotEmpty) {
      final lastSegment = uri.pathSegments.last.trim();

      if (lastSegment.isNotEmpty) {
        candidates.add(lastSegment);
      }
    }

    for (final separator in [':', '=', '/', '|']) {
      if (raw.contains(separator)) {
        final lastPart = raw.split(separator).last.trim();

        if (lastPart.isNotEmpty) {
          candidates.add(lastPart);
        }
      }
    }

    return candidates.toList();
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '')
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]'), '');
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }
}

class SoundTrackerMediaModel {
  final int id;
  final String s3Key;
  final String url;
  final String role;
  final String label;
  final String description;
  final int sortOrder;
  final Map<String, dynamic> meta;

  const SoundTrackerMediaModel({
    required this.id,
    required this.s3Key,
    required this.url,
    required this.role,
    required this.label,
    required this.description,
    required this.sortOrder,
    required this.meta,
  });

  factory SoundTrackerMediaModel.fromJson(Map<String, dynamic> json) {
    return SoundTrackerMediaModel(
      id: _parseInt(json['id']),
      s3Key: (json['s3Key'] ?? json['s3_key'] ?? '').toString(),
      url: _readUrl(json),
      role: (json['role'] ?? '').toString().toUpperCase(),
      label: (json['label'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      sortOrder: _parseInt(json['sortOrder'] ?? json['sort_order']),
      meta: _parseMeta(json['meta']),
    );
  }

  bool get isTarget => role == 'TARGET';

  static String _readUrl(Map<String, dynamic> json) {
    final candidates = [
      json['url'],
      json['audioUrl'],
      json['audio_url'],
      json['mediaUrl'],
      json['media_url'],
      json['fileUrl'],
      json['file_url'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  static Map<String, dynamic> _parseMeta(dynamic value) {
    if (value == null) return <String, dynamic>{};

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    return <String, dynamic>{};
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }
}

class _ExpectedSoundChoice {
  final String label;
  final int order;

  const _ExpectedSoundChoice({
    required this.label,
    required this.order,
  });
}