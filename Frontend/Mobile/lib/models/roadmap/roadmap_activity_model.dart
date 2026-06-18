enum RoadmapActivityStatus {
  completed,
  current,
  locked,
}

class RoadmapActivityModel {
  final int activityId;
  final String activityName;
  final String coverImageKey;
  final String coverImageUrl;
  final RoadmapActivityStatus status;
  final int currentLevelNumber;
  final int totalLevels;
  final int completedLevels;

  const RoadmapActivityModel({
    required this.activityId,
    required this.activityName,
    required this.coverImageKey,
    required this.coverImageUrl,
    required this.status,
    required this.currentLevelNumber,
    required this.totalLevels,
    required this.completedLevels,
  });

  factory RoadmapActivityModel.fromJson(Map<String, dynamic> json) {
    final currentLevelNumber = _parseInt(
      json['currentLevelNumber'] ??
          json['current_level_number'] ??
          json['levelNumber'] ??
          json['level_number'],
    );

    final totalLevels = _parseInt(
      json['totalLevels'] ??
          json['total_levels'],
    );

    final completedLevels = _parseInt(
      json['completedLevels'] ??
          json['completed_levels'],
    );

    return RoadmapActivityModel(
      activityId: _parseInt(
        json['activityId'] ??
            json['id'] ??
            json['activity_id'],
      ),
      activityName: (
          json['activityName'] ??
              json['name'] ??
              json['title'] ??
              ''
      ).toString(),
      coverImageKey: (
          json['coverImageKey'] ??
              json['imageKey'] ??
              json['s3Key'] ??
              ''
      ).toString(),
      coverImageUrl: (
          json['coverImageUrl'] ??
              json['imageUrl'] ??
              json['imageURL'] ??
              json['url'] ??
              ''
      ).toString(),
      status: _parseStatus(
        json['status'],
        completedValue: json['completed'] ??
            json['isCompleted'] ??
            json['is_completed'],
        completedLevels: completedLevels,
        totalLevels: totalLevels,
      ),
      currentLevelNumber: currentLevelNumber,
      totalLevels: totalLevels,
      completedLevels: completedLevels,
    );
  }

  bool get isCompleted => status == RoadmapActivityStatus.completed;

  bool get isCurrent => status == RoadmapActivityStatus.current;

  bool get isLocked => status == RoadmapActivityStatus.locked;

  bool get hasCoverImage => coverImageUrl.trim().isNotEmpty;

  String get levelText {
    if (isCompleted) {
      return 'تم إنجازها';
    }

    if (totalLevels <= 0) {
      return '';
    }

    final safeCurrentLevel = currentLevelNumber <= 0
        ? 1
        : currentLevelNumber;

    return 'المستوى $safeCurrentLevel من $totalLevels';
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
        text == 'done';
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}