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
      if (result['success'] == true) {
        await _refreshQuietly();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadFromServer() async {
    try {
      final result = await ApiService.getCart();
      if (result['success'] == true && result['cart'] is CartModel) {
        final cart = result['cart'] as CartModel;
        if (cart.items.isEmpty) {
          emit(CartEmpty());
        } else {
          emit(CartLoaded(cart));
        }
        return;
      }
      if (result['notFound'] == true) {
        emit(CartEmpty());
        return;
      }
      emit(CartError(result['message']?.toString() ?? 'Failed to load cart'));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _refreshQuietly() async {
    final result = await ApiService.getCart();
    if (result['success'] == true && result['cart'] is CartModel) {
      final cart = result['cart'] as CartModel;
      if (cart.items.isEmpty) {
        emit(CartEmpty());
      } else {
        emit(CartLoaded(cart));
      }
    }
  }
}
