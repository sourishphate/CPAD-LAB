import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/food_grid.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final menu = context.watch<MenuProvider>();
    if (favorites.loading || menu.loading) return const LoadingView();
    if (menu.error != null) {
      return ErrorView(message: menu.error!, onRetry: menu.reload);
    }
    if (favorites.error != null) {
      return ErrorView(
        message: favorites.error!,
        onRetry: () => favorites.load(favorites.uid!),
      );
    }
    final items = favorites.favoriteItems;
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        hint: 'Tap the heart on any item to save it here.',
      );
    }
    return LayoutBuilder(
      builder: (context, c) => MediaQuery.sizeOf(context).width >= 600
          ? FoodGrid(items: items)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: items.map((f) => FoodCard(food: f)).toList(),
            ),
    );
  }
}
