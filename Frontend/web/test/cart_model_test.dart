import 'package:flutter_test/flutter_test.dart';
import 'package:web/shared/models/cart_model.dart';

void main() {
  group('CartModel', () {
    test('subtotal, tax (8%), and total match line items', () {
      final cart = CartModel(
        id: 1,
        items: [
          CartItemModel(
            id: 1,
            kitId: 10,
            kitName: 'A',
            kitDescription: 'd',
            kitImageURL: '',
            kitPrice: 45,
            quantity: 1,
          ),
          CartItemModel(
            id: 2,
            kitId: 11,
            kitName: 'B',
            kitDescription: 'd',
            kitImageURL: '',
            kitPrice: 22,
            quantity: 2,
          ),
        ],
      );
      expect(cart.subtotal, 45 + 44);
      expect(cart.tax, double.parse((cart.subtotal * 0.08).toStringAsFixed(2)));
      expect(cart.total, cart.subtotal + cart.tax);
    });

    test('lineItemCount and unitCount', () {
      final cart = CartModel(
        id: 1,
        items: [
          CartItemModel(
            id: 1,
            kitId: 1,
            kitName: 'A',
            kitDescription: '',
            kitImageURL: '',
            kitPrice: 1,
            quantity: 3,
          ),
          CartItemModel(
            id: 2,
            kitId: 2,
            kitName: 'B',
            kitDescription: '',
            kitImageURL: '',
            kitPrice: 1,
            quantity: 1,
          ),
        ],
      );
      expect(cart.lineItemCount, 2);
      expect(cart.unitCount, 4);
    });

    test('fromJson tolerates missing items', () {
      final cart = CartModel.fromJson({'id': 5, 'items': null});
      expect(cart.id, 5);
      expect(cart.items, isEmpty);
    });

    test('withItemQuantity returns new cart or null', () {
      final cart = CartModel(
        id: 1,
        items: [
          CartItemModel(
            id: 7,
            kitId: 1,
            kitName: 'A',
            kitDescription: '',
            kitImageURL: '',
            kitPrice: 10,
            quantity: 1,
          ),
        ],
      );
      expect(cart.withItemQuantity(7, 0), isNull);
      final next = cart.withItemQuantity(7, 3);
      expect(next, isNotNull);
      expect(next!.items.single.quantity, 3);
      expect(identical(next, cart), isFalse);
    });
  });
}
