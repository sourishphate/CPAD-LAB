import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/providers/menu_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/models/order_model.dart';
import 'fakes.dart';

void main() {
  test(
    'Cart displays server quote and rolls back failed quantity mutation',
    () async {
      final menu = MenuProvider(FakeMenuService());
      await menu.reload();
      final service = FakeCartService();
      final cart = CartProvider(service, menu);
      await cart.load('user');
      await cart.applyCoupon('FOOD50');
      expect(cart.discount, 43);
      expect(cart.total, 157);
      await cart.increment('test-food');
      expect(cart.totalItems, 2);
      expect(service.lastCode, 'FOOD50');
      service.fail = true;
      await expectLater(cart.decrement('test-food'), throwsException);
      expect(cart.totalItems, 2);
      expect(cart.mutating, false);
      cart.reset();
      expect(cart.quantities, isEmpty);
      expect(cart.appliedCoupon, isNull);
      expect(cart.total, isNull);
      cart.dispose();
      menu.dispose();
    },
  );
  test('Favorites rollback and reset isolate user state', () async {
    final menu = MenuProvider(FakeMenuService());
    await menu.reload();
    final service = FakeFavoritesService();
    final provider = FavoritesProvider(service, menu);
    await provider.load('user');
    service.fail = true;
    await expectLater(provider.toggle('test-food'), throwsException);
    expect(provider.isFavorite('test-food'), true);
    expect(provider.pending, isEmpty);
    provider.clear();
    expect(provider.ids, isEmpty);
    expect(provider.uid, isNull);
    provider.dispose();
    menu.dispose();
  });
  test('Menu filters combine category, name and dietary filter', () async {
    final menu = MenuProvider(FakeMenuService());
    await menu.reload();
    menu.search('MEAL');
    menu.category(1);
    menu.quickFilter('Veg');
    expect(menu.filteredItems.length, 1);
    menu.quickFilter('Non-Veg');
    expect(menu.filteredItems, isEmpty);
    menu.clear();
    expect(menu.selectedCategory, 0);
    menu.dispose();
  });
  test('Nested order map round-trips purchase snapshots', () {
    final map = {
      'id': '12345678-1234',
      'user_id': 'u',
      'subtotal': 200,
      'discount': 43,
      'delivery_fee': 0,
      'total': 157,
      'coupon_code': 'FOOD50',
      'address': 'Campus',
      'status': 'Placed',
      'created_at': '2026-11-14T14:45:00.000Z',
      'order_items': [
        {
          'id': 'l',
          'order_id': '12345678-1234',
          'item_id': 'food',
          'name': 'Original name',
          'emoji': '🍕',
          'price': 200,
          'quantity': 1,
        },
      ],
    };
    final order = OrderModel.fromMap(map);
    expect(order.toMap(), map);
    expect(order.shortId, '12345678');
  });
}
