// lib/shared/models/order_model.dart

/// Mirrors backend `OrderDTO`.
class OrderModel {
  final int id;
  final double totalPrice;

  /// Raw enum name from the backend (e.g. "PENDING", "DELIVERED" — exact
  /// values not yet confirmed against `OrderStatus.java`). Kept as a plain
  /// string rather than a Dart enum to avoid guessing wrong case names;
  /// swap this for a real enum once you confirm the backend's values.
  final String status;

  final DateTime? createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  /// Human-friendly order number for display (backend has no dedicated
  /// order-number field, so this derives one from the id).
  String get displayNumber => '#${id.toString().padLeft(5, '0')}';
}

/// Mirrors backend `OrderItemDTO`.
///
/// Note: there is no image field on this DTO — only kitId/kitName/price/
/// quantity. If you want a thumbnail per order row, either add an image
/// field to the backend DTO, or look the kit up separately by [kitId]
/// (e.g. via the existing KitCubit/kit endpoints) and join client-side.
class OrderItemModel {
  final int id;
  final int kitId;
  final String kitName;
  final double price;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.kitId,
    required this.kitName,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kitId: (json['kitId'] as num?)?.toInt() ?? 0,
      kitName: json['kitName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}