// lib/features/profile/cubits/orders/orders_state.dart

import '../../../../shared/models/order_model.dart';

abstract class OrdersState {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  const OrdersLoaded(this.orders);
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
}