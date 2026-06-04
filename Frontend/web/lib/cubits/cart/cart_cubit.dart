import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/models/cart_model.dart';
import '../../shared/services/api_service.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    await _loadFromServer();
  }

  Future<bool> addItem(int kitId, int quantity) async {
    try {
      final result = await ApiService.ensureCartAndAddItem(
        kitId: kitId,
        quantity: quantity,
      );
      if (result['success'] == true && result['cart'] is CartModel) {
        _emitCart(result['cart'] as CartModel);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateItem(int itemId, int quantity) async {
    final snapshot = _currentCart();
    if (snapshot == null) return;

    _emitOptimisticUpdate(snapshot, itemId, quantity);

    final result = await ApiService.updateCartItem(
      itemId: itemId,
      quantity: quantity,
    );
    if (result['success'] == true && result['cart'] is CartModel) {
      _emitCart(result['cart'] as CartModel);
      return;
    }
    _emitCart(snapshot);
  }

  Future<void> removeItem(int itemId) async {
    final snapshot = _currentCart();
    if (snapshot == null) return;

    _emitOptimisticRemove(snapshot, itemId);

    final result = await ApiService.removeCartItem(itemId: itemId);
    if (result['success'] == true && result['cart'] is CartModel) {
      _emitCart(result['cart'] as CartModel);
      return;
    }
    _emitCart(snapshot);
  }

  Future<void> clearCart() async {
    final snapshot = _currentCart();
    emit(CartEmpty());

    final result = await ApiService.clearCart();
    if (result['success'] == true) {
      emit(CartEmpty());
      return;
    }
    if (snapshot != null) {
      _emitCart(snapshot);
    }
  }

  CartModel? _currentCart() {
    final s = state;
    if (s is CartLoaded) return s.cart;
    return null;
  }

  void _emitOptimisticUpdate(CartModel cart, int itemId, int quantity) {
    final items = cart.items
        .map((item) =>
            item.id == itemId ? item.copyWith(quantity: quantity) : item)
        .toList();
    _emitCart(CartModel(id: cart.id, items: items));
  }

  void _emitOptimisticRemove(CartModel cart, int itemId) {
    final items = cart.items.where((item) => item.id != itemId).toList();
    _emitCart(CartModel(id: cart.id, items: items));
  }

  void _emitCart(CartModel cart) {
    if (cart.items.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(CartLoaded(cart));
    }
  }

  Future<void> _loadFromServer() async {
    try {
      final result = await ApiService.getCart();
      if (result['success'] == true && result['cart'] is CartModel) {
        _emitCart(result['cart'] as CartModel);
        return;
      }
      if (result['notFound'] == true) {
        final created = await ApiService.createCart();
        if (created['success'] == true) {
          emit(CartEmpty());
          return;
        }
        emit(CartError(
          created['message']?.toString() ?? 'Failed to create cart',
        ));
        return;
      }
      emit(CartError(result['message']?.toString() ?? 'Failed to load cart'));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
