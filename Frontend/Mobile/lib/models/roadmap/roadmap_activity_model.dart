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
      status: _parseStatus(json['status']),
      currentLevelNumber: _parseInt(json['currentLevelNumber']),
      totalLevels: _parseInt(json['totalLevels']),
      completedLevels: _parseInt(json['completedLevels']),
    );
  }

  bool get isCompleted => status == RoadmapActivityStatus.completed;

  bool get isCurrent => status == RoadmapActivityStatus.current;

  bool get isLocked => status == RoadmapActivityStatus.locked;

  bool get hasCoverImage => coverImageUrl.trim().isNotEmpty;

  String get levelText {
    if (totalLevels <= 0) {
      return '';
    }

    return 'المستوى $currentLevelNumber من $totalLevels';
  }

  static RoadmapActivityStatus _parseStatus(dynamic value) {
    final status = value?.toString().trim().toUpperCase();

    switch (status) {
      case 'COMPLETED':
        return RoadmapActivityStatus.completed;
      case 'CURRENT':
        return RoadmapActivityStatus.current;
      case 'LOCKED':
        return RoadmapActivityStatus.locked;
      default:
        return RoadmapActivityStatus.locked;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}