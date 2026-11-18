import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_service.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';
import '../services/order_service.dart';
import '../screens/main_shell.dart';
import 'auth_provider.dart';
import 'menu_provider.dart';
import 'cart_provider.dart';
import 'favorites_provider.dart';
import 'orders_provider.dart';

// A keyed session owns every user's state. Logout disposes this entire subtree;
// a different user always receives fresh providers, including during late requests.
class SessionProviders extends StatelessWidget {
  final String uid;
  const SessionProviders({super.key, required this.uid});
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (c) => MenuProvider(c.read<MenuService>()),
      ),
      ChangeNotifierProvider(
        create: (c) =>
            CartProvider(c.read<CartService>(), c.read<MenuProvider>()),
      ),
      ChangeNotifierProvider(
        create: (c) => FavoritesProvider(
          c.read<FavoritesService>(),
          c.read<MenuProvider>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (c) => OrdersProvider(
          c.read<OrderService>(),
          c.read<CartProvider>(),
          c.read<AuthProvider>(),
        ),
      ),
    ],
    child: MainShell(uid: uid),
  );
}
