import '../../models/childmode/child_model.dart';
import '../../models/home/daily_challenge_model.dart';
import '../../models/home/last_reached_activity_model.dart';
import '../../models/kit/kit_model.dart';

class HomeData {
  final ChildModel? selectedChild;
  final KitModel? lastUsedKit;

  final int activitiesDoneCount;
  final int totalActivitiesCount;
  final int currentLevel;
  final int? latestActivitySessionId;

  final LastReachedActivityModel? lastReachedActivity;
  final DailyChallengeModel? dailyChallenge;

  final bool challengeAnswered;
  final bool challengeCorrect;
  final String? correctAnswer;

  final bool isSubmittingChallengeAnswer;
  final String? submittingAnswer;

  const HomeData({
    this.selectedChild,
    this.lastUsedKit,
    this.activitiesDoneCount = 0,
    this.totalActivitiesCount = 0,
    this.currentLevel = 1,
    this.latestActivitySessionId,
    this.lastReachedActivity,
    this.dailyChallenge,
    this.challengeAnswered = false,
    this.challengeCorrect = false,
    this.correctAnswer,
    this.isSubmittingChallengeAnswer = false,
    this.submittingAnswer,
  });

  double get progress {
    if (totalActivitiesCount == 0) return 0;
    return activitiesDoneCount / totalActivitiesCount;
  }

  bool get hasSelectedChild => selectedChild != null;

  bool get hasLastUsedKit => lastUsedKit != null;

  bool get hasLastReachedActivity {
    return lastReachedActivity != null && lastReachedActivity!.isValid;
  }

  bool get hasDailyChallenge {
    return dailyChallenge != null && dailyChallenge!.isValid;
  }

  String get progressLabel {
    return '$activitiesDoneCount من اصل $totalActivitiesCount أنشطة';
  }

  HomeData copyWith({
    ChildModel? selectedChild,
    KitModel? lastUsedKit,
    int? activitiesDoneCount,
    int? totalActivitiesCount,
    int? currentLevel,
    int? latestActivitySessionId,
    LastReachedActivityModel? lastReachedActivity,
    DailyChallengeModel? dailyChallenge,
    bool? challengeAnswered,
    bool? challengeCorrect,
    String? correctAnswer,
    bool? isSubmittingChallengeAnswer,
    String? submittingAnswer,
    bool clearCorrectAnswer = false,
    bool clearSubmittingAnswer = false,
  }) {
    return HomeData(
      selectedChild: selectedChild ?? this.selectedChild,
      lastUsedKit: lastUsedKit ?? this.lastUsedKit,
      activitiesDoneCount: activitiesDoneCount ?? this.activitiesDoneCount,
      totalActivitiesCount: totalActivitiesCount ?? this.totalActivitiesCount,
      currentLevel: currentLevel ?? this.currentLevel,
      latestActivitySessionId:
      latestActivitySessionId ?? this.latestActivitySessionId,
      lastReachedActivity: lastReachedActivity ?? this.lastReachedActivity,
      dailyChallenge: dailyChallenge ?? this.dailyChallenge,
      challengeAnswered: challengeAnswered ?? this.challengeAnswered,
      challengeCorrect: challengeCorrect ?? this.challengeCorrect,
      correctAnswer: clearCorrectAnswer
          ? null
          : correctAnswer ?? this.correctAnswer,
      isSubmittingChallengeAnswer:
      isSubmittingChallengeAnswer ?? this.isSubmittingChallengeAnswer,
      submittingAnswer: clearSubmittingAnswer
          ? null
          : submittingAnswer ?? this.submittingAnswer,
    );
  }
}