import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/coins_service.dart';
import 'coins_state.dart';

class CoinsCubit extends Cubit<CoinsState> {
  final CoinsService _coinsService;

  CoinsCubit({
    CoinsService? coinsService,
  })  : _coinsService = coinsService ?? CoinsService(),
        super(const CoinsInitial());

  bool _isLoading = false;

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
  /// The endpoint does not require childId because the backend reads the
  /// selected child.
  Future<void> loadCoins({
    bool showLoading = true,
  }) async {
    if (_isLoading) return;

    _isLoading = true;

    final previousCoins = currentCoins;

    if (showLoading) {
      emit(
        CoinsLoading(
          previousCoins: previousCoins,
        ),
      );
    }

    try {
      final coins = await _coinsService.getSelectedChildCoins();

      emit(
        CoinsLoaded(
          coins: coins,
        ),
      );
    } catch (error) {
      emit(
        CoinsError(
          message: _cleanErrorMessage(error),
          previousCoins: previousCoins,
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Refreshes the balance without replacing the current number with a
  /// loading state. Useful after completing an activity.
  Future<void> refreshCoins() async {
    await loadCoins(showLoading: false);
  }

  /// Updates the number locally when the app already knows the new balance.
  ///
  /// This does not send any request to the backend.
  void setCoins(int coins) {
    emit(
      CoinsLoaded(
        coins: coins < 0 ? 0 : coins,
      ),
    );
  }

  /// Clears the old child's balance before loading another selected child.
  ///
  /// Call this after changing the selected child, then call [loadCoins].
  Future<void> reloadForSelectedChild() async {
    emit(const CoinsInitial());
    await loadCoins();
  }

  String _cleanErrorMessage(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('FormatException: ', '');
  }
}
