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

  const KitLoaded(this.kits);
}

class KitDetailsLoaded extends KitState {
  final KitModel kit;

  const KitDetailsLoaded(this.kit);
}

class KitError extends KitState {
  final String message;

  const KitError(this.message);
}