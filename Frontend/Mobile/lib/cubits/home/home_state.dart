import '../../models/home/daily_challenge_model.dart';
import 'home_data.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeNewUser extends HomeState {
  const HomeNewUser();
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}

class HomeLoaded extends HomeState {
  final HomeData data;

  final String lastActivityName;
  final int lastLevelNumber;
  final int completedActivities;
  final int totalActivities;
  final DailyChallengeModel? dailyChallenge;
  final bool challengeAnswered;
  final bool challengeCorrect;
  final String? correctAnswer;

  HomeLoaded(this.data)
      : lastActivityName = data.lastReachedActivity?.activityName ?? '',
        lastLevelNumber =
            data.lastReachedActivity?.currentLevelNumber ?? data.currentLevel,
        completedActivities = data.activitiesDoneCount,
        totalActivities = data.totalActivitiesCount,
        dailyChallenge = data.dailyChallenge,
        challengeAnswered = data.challengeAnswered,
        challengeCorrect = data.challengeCorrect,
        correctAnswer = data.correctAnswer;
}

/// Kept for compatibility with the current HomeScreen.
/// Later we can replace usages with HomeLoaded directly.
class HomeReturningUser extends HomeLoaded {
  HomeReturningUser(super.data);
}