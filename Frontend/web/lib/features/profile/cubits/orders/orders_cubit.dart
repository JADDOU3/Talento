// lib/features/profile/cubits/orders/order_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/models/order_model.dart';
import '../../../../shared/services/api_service.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersInitial());

  /// Fetches the current user's order history from GET /api/orders/my.
  ///
  /// Uses [ApiService.get], which already handles the auth header and JSON
  /// decoding (same pattern as AuthService.getCurrentUser()). The backend
  /// returns a Spring `Page<OrderDTO>`, i.e. a JSON object with a `content`
  /// list — same shape KitCubit already parses for /kits/.
  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    try {
      final response = await ApiService.get('/orders/my');

      if (response == null) {
        emit(const OrdersError('Could not reach the server.'));
        return;
      }

      final rawList = (response['content'] as List<dynamic>?) ?? const [];
      final orders = rawList
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError('Failed to load orders: $e'));
    }
  }
}