import '../../shared/models/kit_model.dart';

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
  final KitModel kit;
  const KitLoaded(this.kit);
}

class KitError extends KitState {
  final String message;
  const KitError(this.message);
}
