// lib/shared/models/cart_model.dart
class CartModel {
  final int id;
  final String createdAt;
  final List<CartItemModel> items;

  CartModel({
    required this.id,
    required this.createdAt,
    required this.items,
  });

  factory CartModel.empty() {
    return CartModel(
      id: 0,
      createdAt: DateTime.now().toIso8601String(),
      items: [],
    );
  }
  // Add this getter
  double get totalPrice {
    return items.fold<double>(0, (sum, item) => sum + (item.kitPrice * item.quantity));
  }

  int get unitCount {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return CartModel(
      id: json['id'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      items: itemsList.map((e) => CartItemModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CartItemModel {
  final int id;
  final int kitId;
  final String kitName;
  final double kitPrice;
  final int quantity;
  final String kitImageURL;
  final String? kitDescription;

  CartItemModel({
    required this.id,
    required this.kitId,
    required this.kitName,
    required this.kitPrice,
    required this.quantity,
    required this.kitImageURL,
    this.kitDescription,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int? ?? 0,
      kitId: json['kitId'] as int? ?? 0,
      kitName: json['kitName'] as String? ?? '',
      kitPrice: (json['kitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      kitImageURL: json['kitImageURL'] as String? ?? '',
      kitDescription: json['kitDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kitId': kitId,
      'kitName': kitName,
      'kitPrice': kitPrice,
      'quantity': quantity,
      'kitImageURL': kitImageURL,
      'kitDescription': kitDescription,
    };
  }
}