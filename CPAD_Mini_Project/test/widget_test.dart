import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/menu_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/providers/orders_provider.dart';
import 'package:flutter_application_1/screens/main_shell.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_application_1/screens/order_detail_screen.dart';
import 'package:flutter_application_1/models/order_model.dart';
import 'fakes.dart';

void main() {
  testWidgets(
    'Unconfigured application explains setup without a backend request',
    (tester) async {
      await tester.pumpWidget(
        const FoodHubApp(setupMessage: 'Configure your project'),
      );
      expect(find.text('Connect FoodHub to Supabase'), findsOneWidget);
    },
  );
  for (final size in [
    const Size(320, 640),
    const Size(600, 960),
    const Size(600, 320),
    const Size(800, 400),
    const Size(1400, 900),
  ]) {
    testWidgets('All tabs fit ${size.width} x ${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = AuthProvider(FakeAuthService(), FakeProfileService());
      final menu = MenuProvider(FakeMenuService());
      final cart = CartProvider(FakeCartService(), menu);
      final favorites = FavoritesProvider(FakeFavoritesService(), menu);
      final orders = OrdersProvider(FakeOrderService(), cart, auth);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider.value(value: menu),
            ChangeNotifierProvider.value(value: cart),
            ChangeNotifierProvider.value(value: favorites),
            ChangeNotifierProvider.value(value: orders),
          ],
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.orange,
            ),
            home: const MainShell(uid: 'test-user'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byType(size.width >= 600 ? NavigationRail : BottomNavigationBar),
        findsOneWidget,
      );
      for (final label in ['Favorites', 'Cart', 'Profile', 'Home']) {
        final nav = find.byType(
          size.width >= 600 ? NavigationRail : BottomNavigationBar,
        );
        final destination = find
            .descendant(of: nav, matching: find.text(label))
            .first;
        await tester.ensureVisible(destination);
        await tester.tap(destination);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Overflow on $label at $size',
        );
      }
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
      menu.dispose();
      cart.dispose();
      favorites.dispose();
      orders.dispose();
    });
  }
  testWidgets('Login and signup validate at narrow and tablet widths', (
    tester,
  ) async {
    final auth = AuthProvider(FakeAuthService(), FakeProfileService());
    for (final width in [320.0, 800.0]) {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      for (final screen in [const LoginScreen(), const SignupScreen()]) {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: auth,
            child: MaterialApp(home: screen),
          ),
        );
        await tester.pumpAndSettle();
        final button = find.byType(FilledButton);
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('Enter a valid email'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
  });
  testWidgets('Order details display purchase snapshots on narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final order = OrderModel.fromMap({
      'id': '12345678-0000-0000-0000-000000000000',
      'user_id': 'u',
      'subtotal': 200,
      'discount': 43,
      'delivery_fee': 0,
      'total': 157,
      'coupon_code': 'FOOD50',
      'address': 'College campus',
      'status': 'Placed',
      'created_at': '2026-11-14T14:45:00Z',
      'order_items': [
        {
          'id': 'line',
          'order_id': '12345678',
          'item_id': 'test-food',
          'name': 'Original meal name',
          'emoji': '🍕',
          'price': 200,
          'quantity': 1,
        },
      ],
    });
    await tester.pumpWidget(MaterialApp(home: OrderDetailScreen(order: order)));
    await tester.pumpAndSettle();
    expect(find.text('Original meal name'), findsOneWidget);
    expect(find.text('₹157'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
