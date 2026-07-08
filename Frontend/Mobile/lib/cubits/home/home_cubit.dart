import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/home/home_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService _homeService;

  HomeCubit(this._homeService) : super(const HomeInitial());

  Future<void> initHome() async {
    emit(const HomeLoading());

    try {
      final isNewUser = await _homeService.isNewUser();

      if (isNewUser) {
        emit(const HomeNewUser());
        return;
      }

      final data = await _homeService.getReturningUserHomeData();

      emit(
        HomeReturningUser(data),
      );
    } catch (e) {
      emit(
        HomeError(
          _cleanError(e),
        ),
      );
    }
  }

  Future<void> loadHome() async {
    emit(const HomeLoading());

    try {
      final data = await _homeService.getReturningUserHomeData();

      emit(
        HomeReturningUser(data),
      );
    } catch (e) {
      emit(
        HomeError(
          _cleanError(e),
        ),
      );
    }
  }

  Future<void> refreshHome() async {
    await loadHome();
  }

  Future<bool> submitChallengeAnswer(
      int challengeId,
      String answer,
      ) async {
    final currentState = state;

    if (currentState is! HomeLoaded) {
      return false;
    }

    final currentData = currentState.data;

    if (currentData.challengeAnswered ||
        currentData.isSubmittingChallengeAnswer) {
      return false;
    }

    emit(
      HomeReturningUser(
        currentData.copyWith(
          isSubmittingChallengeAnswer: true,
          submittingAnswer: answer,
          clearCorrectAnswer: true,
        ),
      ),
    );

    try {
      final result = await _homeService.submitDailyChallengeAnswer(
        challengeId,
        answer,
      );

      emit(
        HomeReturningUser(
          currentData.copyWith(
            challengeAnswered: true,
            challengeCorrect: result.correct,
            correctAnswer: result.correctAnswer,
            isSubmittingChallengeAnswer: false,
            clearSubmittingAnswer: true,
          ),
        ),
      );

      return result.correct;
    } catch (e) {
      emit(
        HomeReturningUser(
          currentData.copyWith(
            isSubmittingChallengeAnswer: false,
            clearSubmittingAnswer: true,
          ),
        ),
      );

      emit(
        HomeError(
          _cleanError(e),
        ),
      );

      return false;
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}