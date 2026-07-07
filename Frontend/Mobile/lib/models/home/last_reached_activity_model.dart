class LastReachedActivityModel {
  final String activityName;
  final int currentLevelNumber;

  const LastReachedActivityModel({
    required this.activityName,
    required this.currentLevelNumber,
  });

  factory LastReachedActivityModel.fromJson(Map<String, dynamic> json) {
    return LastReachedActivityModel(
      activityName: (
          json['activityName'] ??
              json['activity_name'] ??
              json['name'] ??
              json['title'] ??
              ''
      ).toString(),
      currentLevelNumber: _parseInt(
        json['currentLevelNumber'] ??
            json['current_level_number'] ??
            json['levelNumber'] ??
            json['level_number'] ??
            json['level'],
      ),
    );
  }

  bool get isValid {
    return activityName.trim().isNotEmpty && currentLevelNumber > 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}