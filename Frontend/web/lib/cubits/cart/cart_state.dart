import '../../shared/models/cart_model.dart';

abstract class CartState {
  const CartState();
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartModel cart;
  const CartLoaded(this.cart);
}

class CartEmpty extends CartState {}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
}
