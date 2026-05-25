class CartItemModel {
  final int id;
  final int kitId;
  final String kitName;
  final String kitDescription;
  final String kitImageURL;
  final double kitPrice;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.kitId,
    required this.kitName,
    required this.kitDescription,
    required this.kitImageURL,
    required this.kitPrice,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kitId: (json['kitId'] as num?)?.toInt() ?? 0,
      kitName: json['kitName'] as String? ?? '',
      kitDescription: json['kitDescription'] as String? ?? '',
      kitImageURL: json['kitImageURL'] as String? ?? '',
      kitPrice: (json['kitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      kitId: kitId,
      kitName: kitName,
      kitDescription: kitDescription,
      kitImageURL: kitImageURL,
      kitPrice: kitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  CartItemModel copy() => copyWith();
}

class CartModel {
  final int id;
  final List<CartItemModel> items;

  const CartModel({
    required this.id,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final list = raw is List ? raw : const <dynamic>[];
    return CartModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      items: list
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList(),
    );
  }

  int get lineItemCount => items.length;

  int get unitCount => items.fold(0, (s, e) => s + e.quantity);

  double get subtotal =>
      items.fold(0.0, (s, e) => s + e.kitPrice * e.quantity);

  CartModel deepCopy() =>
      CartModel(id: id, items: items.map((e) => e.copy()).toList());
}
