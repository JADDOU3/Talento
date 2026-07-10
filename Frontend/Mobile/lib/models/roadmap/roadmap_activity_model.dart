enum RoadmapActivityStatus {
  completed,
  current,
  locked,
}

class RoadmapActivityModel {
  final int cardId;
  final int activityId;
  final String activityName;
  final String coverImageKey;
  final String coverImageUrl;
  final RoadmapActivityStatus status;
  final int currentLevelNumber;
  final int totalLevels;
  final int completedLevels;
  final int? levelFrom;
  final int? levelTo;
  final bool voiceEnabled;
  final int? storyCount;

  const RoadmapActivityModel({
    required this.cardId,
    required this.activityId,
    required this.activityName,
    required this.coverImageKey,
    required this.coverImageUrl,
    required this.status,
    required this.currentLevelNumber,
    required this.totalLevels,
    required this.completedLevels,
    this.levelFrom,
    this.levelTo,
    this.voiceEnabled = false,
    this.storyCount,
  });

  factory RoadmapActivityModel.fromJson(Map<String, dynamic> json) {
    final currentLevelNumber = _parseInt(
      json['currentLevelNumber'] ??
          json['current_level_number'] ??
          json['levelNumber'] ??
          json['level_number'],
    );

    final totalLevels = _parseInt(
      json['totalLevels'] ?? json['total_levels'],
    );

    final completedLevels = _parseInt(
      json['completedLevels'] ?? json['completed_levels'],
    );

    final activityName = (json['activityName'] ??
        json['name'] ??
        json['title'] ??
        '')
        .toString();

    return RoadmapActivityModel(
      cardId: _parseInt(
        json['cardId'] ?? json['card_id'],
      ),
      activityId: _parseInt(
        json['activityId'] ?? json['id'] ?? json['activity_id'],
      ),
      activityName: activityName,
      coverImageKey: (json['coverImageKey'] ??
          json['imageKey'] ??
          json['s3Key'] ??
          '')
          .toString(),
      coverImageUrl: (json['coverImageUrl'] ??
          json['imageUrl'] ??
          json['imageURL'] ??
          json['url'] ??
          '')
          .toString(),
      status: _parseStatus(
        json['status'],
        completedValue:
        json['completed'] ?? json['isCompleted'] ?? json['is_completed'],
        completedLevels: completedLevels,
        totalLevels: totalLevels,
      ),
      currentLevelNumber: currentLevelNumber,
      totalLevels: totalLevels,
      completedLevels: completedLevels,
      levelFrom: _parseNullableInt(
        json['levelFrom'] ?? json['level_from'],
      ),
      levelTo: _parseNullableInt(
        json['levelTo'] ?? json['level_to'],
      ),
      voiceEnabled: _parseVoiceEnabled(
        activityName: activityName,
        value: json['voiceEnabled'] ??
            json['voice_enabled'] ??
            json['isVoiceEnabled'] ??
            json['is_voice_enabled'] ??
            json['voice'] ??
            json['voiceActivity'],
      ),
      storyCount: _parseNullableInt(
        json['storyCount'] ?? json['story_count'] ?? json['storiesCount'],
      ),
    );
  }

  RoadmapActivityModel copyWith({
    int? cardId,
    int? activityId,
    String? activityName,
    String? coverImageKey,
    String? coverImageUrl,
    RoadmapActivityStatus? status,
    int? currentLevelNumber,
    int? totalLevels,
    int? completedLevels,
    int? levelFrom,
    int? levelTo,
    bool clearLevelFrom = false,
    bool clearLevelTo = false,
    bool? voiceEnabled,
    int? storyCount,
    bool clearStoryCount = false,
  }) {
    return RoadmapActivityModel(
      cardId: cardId ?? this.cardId,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      coverImageKey: coverImageKey ?? this.coverImageKey,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      currentLevelNumber: currentLevelNumber ?? this.currentLevelNumber,
      totalLevels: totalLevels ?? this.totalLevels,
      completedLevels: completedLevels ?? this.completedLevels,
      levelFrom: clearLevelFrom ? null : levelFrom ?? this.levelFrom,
      levelTo: clearLevelTo ? null : levelTo ?? this.levelTo,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      storyCount: clearStoryCount ? null : storyCount ?? this.storyCount,
    );
  }

  bool get isCompleted => status == RoadmapActivityStatus.completed;

  bool get isCurrent => status == RoadmapActivityStatus.current;

  bool get isLocked => status == RoadmapActivityStatus.locked;

  bool get hasCoverImage => coverImageUrl.trim().isNotEmpty;

  bool get hasStoryCount => storyCount != null && storyCount! > 0;

  bool get hasLevelSlice {
    return levelFrom != null &&
        levelTo != null &&
        levelFrom! > 0 &&
        levelTo! > 0;
  }

  int get safeCurrentLevelNumber {
    return currentLevelNumber <= 0 ? 1 : currentLevelNumber;
  }

  int get launchLevelNumber {
    if (levelFrom != null && levelFrom! > 0) {
      return levelFrom!;
    }

    return safeCurrentLevelNumber;
  }

  String get levelText {
    if (isCompleted) {
      return 'تم إنجازها';
    }

    if (hasLevelSlice) {
      if (levelFrom == levelTo) {
        return 'المستوى $levelFrom';
      }

      return 'المستويات $levelFrom - $levelTo';
    }

    if (totalLevels <= 0) {
      return '';
    }

    return 'المستوى $safeCurrentLevelNumber من $totalLevels';
  }

  static RoadmapActivityStatus _parseStatus(
      dynamic value, {
        dynamic completedValue,
        required int completedLevels,
        required int totalLevels,
      }) {
    if (_parseBool(completedValue)) {
      return RoadmapActivityStatus.completed;
    }

    if (totalLevels > 0 && completedLevels >= totalLevels) {
      return RoadmapActivityStatus.completed;
    }

    final status = value?.toString().trim().toUpperCase();

    switch (status) {
      case 'COMPLETED':
      case 'COMPLETE':
      case 'DONE':
        return RoadmapActivityStatus.completed;
      case 'CURRENT':
      case 'ACTIVE':
      case 'IN_PROGRESS':
      case 'INPROGRESS':
        return RoadmapActivityStatus.current;
      case 'LOCKED':
        return RoadmapActivityStatus.locked;
      default:
        return RoadmapActivityStatus.locked;
    }
  }

  static bool _parseVoiceEnabled({
    required String activityName,
    required dynamic value,
  }) {
    if (value != null) return _parseBool(value);

    final normalizedName = activityName.trim().toLowerCase();

    return normalizedName == 'story spinner' ||
        normalizedName == 'story spinner cards';
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value.toString().trim().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes' ||
        text == 'completed' ||
        text == 'complete' ||
        text == 'done' ||
        text == 'enabled' ||
        text == 'voice_enabled';
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }
}