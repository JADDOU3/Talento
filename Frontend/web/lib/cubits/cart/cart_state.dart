// lib/cubits/cart/cart_state.dart
import '../../shared/models/cart_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartModel cart;
  CartLoaded({required this.cart});
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}