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

class HomeReturningUser extends HomeState {
  final HomeData data;

  const HomeReturningUser(this.data);
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}