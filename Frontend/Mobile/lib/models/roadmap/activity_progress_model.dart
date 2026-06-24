class ActivityProgressModel {
  final int activityId;
  final int currentLevelNumber;
  final int currentLevelId;
  final int completedLevels;
  final int totalLevels;
  final bool completed;
  final DateTime? updatedAt;

  const ActivityProgressModel({
    required this.activityId,
    required this.currentLevelNumber,
    required this.currentLevelId,
    required this.completedLevels,
    required this.totalLevels,
    required this.completed,
    required this.updatedAt,
  });

  factory ActivityProgressModel.fromJson(Map<String, dynamic> json) {
    return ActivityProgressModel(
      activityId: _parseInt(
        json['activityId'] ??
            json['activity_id'] ??
            json['id'],
      ),
      currentLevelNumber: _parseInt(
        json['currentLevelNumber'] ??
            json['current_level_number'],
      ),
      currentLevelId: _parseInt(
        json['currentLevelId'] ??
            json['current_level_id'] ??
            json['levelId'] ??
            json['level_id'],
      ),
      completedLevels: _parseInt(
        json['completedLevels'] ??
            json['completed_levels'],
      ),
      totalLevels: _parseInt(
        json['totalLevels'] ??
            json['total_levels'],
      ),
      completed: _parseBool(
        json['completed'] ??
            json['isCompleted'] ??
            json['is_completed'],
      ),
      updatedAt: _parseDateTime(
        json['updatedAt'] ??
            json['updated_at'],
      ),
    );
  }

  bool get hasValidCurrentLevel => currentLevelId > 0;

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;

    final normalized = value.toString().trim().toLowerCase();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'completed';
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    return DateTime.tryParse(raw);
  }
}