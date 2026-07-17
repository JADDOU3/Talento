class AIReportModel {
  final int id;
  final String summary;
  final String focusTrend;
  final String confidenceTrend;
  final String stressResponsePattern;
  final String learningBehaviorPattern;
  final String recommendedFutureObservation;
  final String contextSummary;
  final String analysisVersion;
  final double analysisConfidence;
  final List<MindsetScoreModel> mindsetScores;
  final DateTime generatedAt;

  const AIReportModel({
    required this.id,
    required this.summary,
    required this.focusTrend,
    required this.confidenceTrend,
    required this.stressResponsePattern,
    required this.learningBehaviorPattern,
    required this.recommendedFutureObservation,
    required this.contextSummary,
    required this.analysisVersion,
    required this.analysisConfidence,
    required this.mindsetScores,
    required this.generatedAt,
  });

  factory AIReportModel.fromJson(Map<String, dynamic> json) {
    final rawMindsetScores = json['mindsetScores'] ??
        json['mindset_scores'] ??
        json['scores'] ??
        [];

    return AIReportModel(
      id: _toInt(json['id'] ?? json['reportId']),
      summary: _toString(json['summary']),
      focusTrend: _toString(json['focusTrend'] ?? json['focus_trend']),
      confidenceTrend:
      _toString(json['confidenceTrend'] ?? json['confidence_trend']),
      stressResponsePattern: _toString(
        json['stressResponsePattern'] ?? json['stress_response_pattern'],
      ),
      learningBehaviorPattern: _toString(
        json['learningBehaviorPattern'] ?? json['learning_behavior_pattern'],
      ),
      recommendedFutureObservation: _toString(
        json['recommendedFutureObservation'] ??
            json['recommended_future_observation'],
      ),
      contextSummary:
      _toString(json['contextSummary'] ?? json['context_summary']),
      analysisVersion:
      _toString(json['analysisVersion'] ?? json['analysis_version']),
      analysisConfidence: _toDouble(
        json['analysisConfidence'] ?? json['analysis_confidence'],
      ),
      mindsetScores: _parseMindsetScores(rawMindsetScores),
      generatedAt: _toDateTime(
        json['generatedAt'] ?? json['generated_at'] ?? json['createdAt'],
      ),
    );
  }

  static List<MindsetScoreModel> _parseMindsetScores(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => MindsetScoreModel.fromJson(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }
}

class MindsetScoreModel {
  final String mindsetName;
  final double score;

  const MindsetScoreModel({
    required this.mindsetName,
    required this.score,
  });

  factory MindsetScoreModel.fromJson(Map<String, dynamic> json) {
    return MindsetScoreModel(
      mindsetName: _toString(
        json['mindsetName'] ??
            json['mindset_name'] ??
            json['name'] ??
            json['mindset'],
      ),
      score: _toDouble(json['score'] ?? json['value']),
    );
  }
}

class DailySessionModel {
  final String date;
  final int count;

  const DailySessionModel({
    required this.date,
    required this.count,
  });

  factory DailySessionModel.fromJson(Map<String, dynamic> json) {
    return DailySessionModel(
      date: _toString(json['date'] ?? json['day'] ?? json['sessionDate']),
      count: _toInt(json['count'] ?? json['total'] ?? json['sessionsCount']),
    );
  }
}

class PerformanceModel {
  final int id;
  final int activityId;
  final double completionScore;
  final double efficiencyScore;
  final double persistenceScore;
  final double independenceScore;
  final double strategyScore;
  final DateTime lastUpdated;

  const PerformanceModel({
    required this.id,
    required this.activityId,
    required this.completionScore,
    required this.efficiencyScore,
    required this.persistenceScore,
    required this.independenceScore,
    required this.strategyScore,
    required this.lastUpdated,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      id: _toInt(json['id']),
      activityId: _toInt(json['activityId'] ?? json['activity_id']),
      completionScore: _toDouble(
        json['completionScore'] ?? json['completion_score'],
      ),
      efficiencyScore: _toDouble(
        json['efficiencyScore'] ?? json['efficiency_score'],
      ),
      persistenceScore: _toDouble(
        json['persistenceScore'] ?? json['persistence_score'],
      ),
      independenceScore: _toDouble(
        json['independenceScore'] ?? json['independence_score'],
      ),
      strategyScore: _toDouble(
        json['strategyScore'] ?? json['strategy_score'],
      ),
      lastUpdated: _toDateTime(
        json['lastUpdated'] ?? json['last_updated'] ?? json['updatedAt'],
      ),
    );
  }
}


class JournalActivitiesProgressModel {
  final int completedActivities;
  final int totalActivities;

  const JournalActivitiesProgressModel({
    required this.completedActivities,
    required this.totalActivities,
  });

  const JournalActivitiesProgressModel.empty()
      : completedActivities = 0,
        totalActivities = 0;

  bool get allActivitiesCompleted {
    return totalActivities > 0 && completedActivities >= totalActivities;
  }

  double get progress {
    if (totalActivities <= 0) return 0;

    return (completedActivities / totalActivities)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}

String _toString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

DateTime _toDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}