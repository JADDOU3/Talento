import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/coins_service.dart';
import 'coins_state.dart';

class CoinsCubit extends Cubit<CoinsState> {
  final CoinsService _coinsService;

  CoinsCubit({
    CoinsService? coinsService,
  })  : _coinsService = coinsService ?? CoinsService(),
        super(const CoinsInitial());

  int _latestRequestId = 0;

  int get currentCoins {
    final currentState = state;

    if (currentState is CoinsLoaded) {
      return currentState.coins;
    }

    if (currentState is CoinsLoading) {
      return currentState.previousCoins;
    }

    if (currentState is CoinsError) {
      return currentState.previousCoins;
    }

    return 0;
  }

  /// Loads the coins balance for the child currently selected on the backend.
  ///
  /// Every request gets an id. If an older request finishes after a newer
  /// selected-child request, its result is ignored so it cannot restore the
  /// previous child's balance.
  Future<void> loadCoins({
    bool showLoading = true,
    bool clearPreviousCoins = false,
  }) async {
    final requestId = ++_latestRequestId;
    final previousCoins = clearPreviousCoins ? 0 : currentCoins;

    if (showLoading) {
      emit(
        CoinsLoading(
          previousCoins: previousCoins,
        ),
      );
    }

    try {
      final coins = await _coinsService.getSelectedChildCoins();

      if (requestId != _latestRequestId || isClosed) return;

      emit(
        CoinsLoaded(
          coins: coins,
        ),
      );
    } catch (error) {
      if (requestId != _latestRequestId || isClosed) return;

      emit(
        CoinsError(
          message: _cleanErrorMessage(error),
          previousCoins: previousCoins,
        ),
      );
    }
  }

  /// Refreshes the current selected child's balance while keeping the last
  /// visible value during the request.
  Future<void> refreshCoins() async {
    await loadCoins(showLoading: false);
  }

  /// Clears the previous child's balance and loads the balance of the child
  /// that has just been selected on the backend.
  Future<void> reloadForSelectedChild() async {
    await loadCoins(
      showLoading: true,
      clearPreviousCoins: true,
    );
  }

  /// Clears account-specific coins data, for example during logout/login.
  void reset() {
    _latestRequestId++;
    emit(const CoinsInitial());
  }

  /// Updates the number locally only when the app already knows the complete
  /// new balance. This method does not add rewards to the old value.
  void setCoins(int coins) {
    _latestRequestId++;
    emit(
      CoinsLoaded(
        coins: coins < 0 ? 0 : coins,
      ),
    );
  }

  String _cleanErrorMessage(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('FormatException: ', '');
  }
}
