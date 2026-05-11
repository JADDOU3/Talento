// lib/features/catalog/cubits/kit/kit_state.dart

import '../../../../shared/models/kit_model.dart';

abstract class KitState {
  const KitState();
}

class KitInitial extends KitState {
  const KitInitial();
}

class KitLoading extends KitState {
  const KitLoading();
}

class KitLoadingMore extends KitState {
  final List<KitModel> currentKits;
  final List<MindsetModel> mindsets;
  const KitLoadingMore(this.currentKits, {this.mindsets = const []});
}

class KitLoaded extends KitState {
  final List<KitModel> kits;
  final int currentPage;
  final bool hasMore;
  final List<MindsetModel> mindsets;

  const KitLoaded({
    required this.kits,
    required this.currentPage,
    required this.hasMore,
    this.mindsets = const [],
  });

  KitLoaded copyWith({
    List<KitModel>? kits,
    int? currentPage,
    bool? hasMore,
    List<MindsetModel>? mindsets,
  }) {
    return KitLoaded(
      kits: kits ?? this.kits,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      mindsets: mindsets ?? this.mindsets,
    );
  }
}

class KitDetailsLoaded extends KitState {
  final KitModel kit;
  const KitDetailsLoaded(this.kit);
}

class KitError extends KitState {
  final String message;
  const KitError(this.message);
}