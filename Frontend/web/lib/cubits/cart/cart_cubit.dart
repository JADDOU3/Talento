// lib/cubits/cart/cart_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/services/api_service.dart';
import '../../shared/models/cart_model.dart';
import '../../shared/services/auth_state.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    try {
      // Check if user is logged in first
      final authState = AuthState.instance;
      if (!authState.isLoggedIn) {
        // Return empty cart for unauthenticated users
        emit(CartLoaded(cart: CartModel(id: 0, createdAt: '', items: [])));
        return;
      }

      final result = await ApiService.getCart();

      if (result['success'] == true && result['cart'] != null) {
        emit(CartLoaded(cart: result['cart']));
      } else if (result['notFound'] == true) {
        // Cart doesn't exist yet - create one
        await createCart();
      } else {
        // On any error, show empty cart instead of error
        emit(CartLoaded(cart: CartModel(id: 0, createdAt: '', items: [])));
      }
    } catch (e) {
      // On network error, show empty cart
      emit(CartLoaded(cart: CartModel(id: 0, createdAt: '', items: [])));
    }
  }

  Future<void> createCart() async {
    try {
      final result = await ApiService.createCart();
      if (result['success'] == true) {
        await loadCart();
      } else {
        // Don't show error, just show empty cart
        emit(CartLoaded(cart: CartModel(id: 0, createdAt: '', items: [])));
      }
    } catch (e) {
      // Don't show error, just show empty cart
      emit(CartLoaded(cart: CartModel(id: 0, createdAt: '', items: [])));
    }
  }

  Future<bool> addItem(int kitId, int quantity) async {
    try {
      final authState = AuthState.instance;
      if (!authState.isLoggedIn) {
        // User not logged in, show message
        return false;
      }

      final result = await ApiService.addCartItem(kitId: kitId, quantity: quantity);
      if (result['success'] == true) {
        await loadCart();
        return true;
      } else {
        // Don't show error to user, just return false
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateItemQuantity(int itemId, int quantity) async {
    try {
      final result = await ApiService.updateCartItem(itemId, quantity);
      if (result['success'] == true) {
        await loadCart();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeItem(int itemId) async {
    try {
      final result = await ApiService.removeCartItem(itemId);
      if (result['success'] == true) {
        await loadCart();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkout() async {
    try {
      final result = await ApiService.checkout();
      if (result['success'] == true) {
        await loadCart();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCart() async {
    try {
      final result = await ApiService.clearCart();
      if (result['success'] == true) {
        await loadCart();
      }
    } catch (e) {
      // Silently fail
    }
  }
}