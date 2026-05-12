import '../../models/kit/kit_model.dart';

import '../../models/user_model.dart';
import '../../models/child_model.dart';


abstract class ProfileState {}

// Initial
class ProfileInitial extends ProfileState {}

// Loading
class ProfileLoading extends ProfileState {}

// Loaded
class ProfileLoaded extends ProfileState {
  final UserModel user;
  final List<ChildModel> children;
  final ChildModel? selectedChild;
  final List<KitModel> kits;

  ProfileLoaded({
    required this.user,
    required this.children,
    this.selectedChild,
    required this.kits,
  });
}

// Error
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// Kits Loading (when switching child)
class ProfileKitsLoading extends ProfileState {
  final UserModel user;
  final List<ChildModel> children;
  final ChildModel? selectedChild;

  ProfileKitsLoading({
    required this.user,
    required this.children,
    this.selectedChild,
  });
}