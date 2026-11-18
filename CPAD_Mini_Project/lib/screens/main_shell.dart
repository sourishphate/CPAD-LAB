import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/orders_provider.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final String uid;
  const MainShell({super.key, required this.uid});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) load();
    });
  }

  Future<void> load() async {
    final auth = context.read<AuthProvider>(),
        menu = context.read<MenuProvider>();
    final cart = context.read<CartProvider>(),
        favorites = context.read<FavoritesProvider>(),
        orders = context.read<OrdersProvider>();
    await Future.wait([
      auth.loadProfile(),
      menu.reload(),
      cart.load(widget.uid),
      favorites.load(widget.uid),
      orders.load(widget.uid),
    ]);
  }

  Widget cartIcon(int count) => Stack(
    clipBehavior: Clip.none,
    children: [
      const Icon(Icons.shopping_cart),
      if (count > 0)
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(3),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((c) => c.totalItems);
    final size = MediaQuery.sizeOf(context),
        orientation = MediaQuery.orientationOf(context);
    final icons = [
      const Icon(Icons.home),
      const Icon(Icons.favorite),
      cartIcon(count),
      const Icon(Icons.person),
    ];
    const labels = ['Home', 'Favorites', 'Cart', 'Profile'];
    final pages = IndexedStack(
      index: selected,
      children: [
        const HomeScreen(),
        const FavoritesScreen(),
        CartScreen(
          onBrowse: () => setState(() => selected = 0),
          onOrdered: () => setState(() => selected = 3),
        ),
        const ProfileScreen(),
      ],
    );
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 600;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              ['🍔 FoodHub', 'Favorites', 'My Cart', 'Profile'][selected],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Tooltip(
                  message:
                      '${size.width.toInt()}×${size.height.toInt()} | ${orientation.name}',
                  child: const Icon(Icons.notifications),
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : BottomNavigationBar(
                  currentIndex: selected,
                  selectedItemColor: Colors.orange,
                  unselectedItemColor: Colors.grey,
                  onTap: (i) => setState(() => selected = i),
                  items: List.generate(
                    4,
                    (i) => BottomNavigationBarItem(
                      icon: icons[i],
                      label: labels[i],
                    ),
                  ),
                ),
          body: SafeArea(
            child: wide
                ? Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: LayoutBuilder(
                          builder: (context, railConstraints) =>
                              SingleChildScrollView(
                                child: SizedBox(
                                  height: railConstraints.maxHeight < 340
                                      ? 340
                                      : railConstraints.maxHeight,
                                  child: NavigationRail(
                                    selectedIndex: selected,
                                    labelType: NavigationRailLabelType.all,
                                    onDestinationSelected: (i) =>
                                        setState(() => selected = i),
                                    destinations: List.generate(
                                      4,
                                      (i) => NavigationRailDestination(
                                        icon: icons[i],
                                        label: Text(labels[i]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: pages),
                    ],
                  )
                : pages,
          ),
        );
      },
    );
  }
}
