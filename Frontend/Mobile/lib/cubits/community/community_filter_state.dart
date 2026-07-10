import '../../models/kit/kit_model.dart';
import '../../models/kit/mindset_model.dart';

abstract class CommunityFilterState {}

class CommunityFilterInitial extends CommunityFilterState {}

class CommunityFilterLoading extends CommunityFilterState {}

class CommunityFilterLoaded extends CommunityFilterState {
  final List<MindsetModel> mindsets;
  final List<KitModel> kits;

  CommunityFilterLoaded({
    required this.mindsets,
    required this.kits,
  });
}

class CommunityFilterError extends CommunityFilterState {
  final String message;

  CommunityFilterError(this.message);
}
