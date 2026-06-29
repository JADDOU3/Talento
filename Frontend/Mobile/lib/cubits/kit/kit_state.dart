import '../../models/kit/kit_model.dart';

abstract class KitState {
  const KitState();
}

class KitInitial extends KitState {
  const KitInitial();
}

class KitLoading extends KitState {
  const KitLoading();
}

class KitLoaded extends KitState {
  final List<KitModel> kits;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final String? loadMoreError;

  const KitLoaded(
      this.kits, {
        this.hasMore = false,
        this.currentPage = 0,
        this.isLoadingMore = false,
        this.loadMoreError,
      });

  KitLoaded copyWith({
    List<KitModel>? kits,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return KitLoaded(
      kits ?? this.kits,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
      clearLoadMoreError ? null : loadMoreError ?? this.loadMoreError,
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