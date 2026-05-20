import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/models/cart_model.dart';
import '../../shared/services/api_service.dart';
import 'cart_state.dart';

/// Cart state synced with backend only (no local persistence).
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    await _loadFromServer();
  }

  /// Returns `true` if the item was added and cart was refreshed.
  Future<bool> addItem(int kitId, int quantity) async {
    try {
      final result =
          await ApiService.addCartItem(kitId: kitId, quantity: quantity);
      if (result['success'] == true) {
        await _refreshQuietly();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateItem(int itemId, int quantity) async {
    if (state is! CartLoaded) return;
    final loaded = state as CartLoaded;
    final snapshot = loaded.cart.deepCopy();

    final nextCart = loaded.cart.withItemQuantity(itemId, quantity);
    if (nextCart == null) return;
    if (nextCart.items.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(CartLoaded(nextCart));
    }

    final result =
        await ApiService.updateCartItem(itemId: itemId, quantity: quantity);
    if (result['success'] != true) {
      _emitFromSnapshot(snapshot);
      return;
    }
    await _refreshQuietly();
  }

  Future<void> removeItem(int itemId) async {
    if (state is! CartLoaded) return;
    final loaded = state as CartLoaded;
    final snapshot = loaded.cart.deepCopy();

    final nextItems = loaded.cart.items.where((i) => i.id != itemId).toList();
    if (nextItems.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(CartLoaded(CartModel(id: loaded.cart.id, items: nextItems)));
    }

    final result = await ApiService.removeCartItem(itemId: itemId);
    if (result['success'] != true) {
      _emitFromSnapshot(snapshot);
      return;
    }
    await _refreshQuietly();
  }

  Future<void> clearCart() async {
    try {
      final result = await ApiService.clearCart();
      if (result['success'] == true) {
        emit(CartEmpty());
      } else {
        emit(CartError(result['message']?.toString() ?? 'Failed to clear cart'));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void _emitFromSnapshot(CartModel snapshot) {
    if (snapshot.items.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(CartLoaded(snapshot));
    }
  }

  Future<void> _loadFromServer() async {
    final result = await ApiService.getCart();
    await _applyGetCartResult(result);
  }

  Future<void> _refreshQuietly() async {
    final result = await ApiService.getCart();
    await _applyGetCartResult(result, isQuiet: true);
  }

  Future<void> _applyGetCartResult(
    Map<String, dynamic> result, {
    bool isQuiet = false,
  }) async {
    if (result['success'] == true) {
      final cart = result['cart'] as CartModel;
      if (cart.items.isEmpty) {
        emit(CartEmpty());
      } else {
        emit(CartLoaded(cart));
      }
      return;
    }

    if (result['notFound'] == true) {
      final created = await ApiService.createCart();
      if (created['success'] == true) {
        emit(CartEmpty());
      } else {
        emit(CartError(
            created['message']?.toString() ?? 'Could not create cart'));
      }
      return;
    }

    final message =
        result['message']?.toString() ?? 'Failed to load cart';
    if (isQuiet && state is CartLoaded) {
      // Avoid clobbering a visible cart on background sync failure.
      return;
    }
    emit(CartError(message));
  }
}
