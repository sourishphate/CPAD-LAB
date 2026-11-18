import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/favorites_provider.dart';
import 'emoji_stack.dart';
import 'quantity_control.dart';
import 'ui_helpers.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final bool isGrid;
  const FoodCard({super.key, required this.food, this.isGrid = false});
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final heart = IconButton(
      tooltip: favorites.isFavorite(food.id)
          ? 'Remove favorite'
          : 'Add favorite',
      visualDensity: VisualDensity.compact,
      onPressed: favorites.loading || favorites.pending.contains(food.id)
          ? null
          : () => perform(context, () => favorites.toggle(food.id)),
      icon: Icon(
        favorites.isFavorite(food.id) ? Icons.favorite : Icons.favorite_border,
        color: favorites.isFavorite(food.id) ? Colors.red : Colors.grey,
      ),
    );
    final emoji = EmojiStack(food: food.toMap());
    return Card(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(isGrid ? 10 : 15),
        child: isGrid
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Align(alignment: Alignment.topRight, child: heart),
                    emoji,
                    const SizedBox(height: 12),
                    _details(true),
                    const SizedBox(height: 10),
                    QuantityControl(itemId: food.id, available: food.available),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  emoji,
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                food.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            heart,
                          ],
                        ),
                        _details(false, showName: false),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: QuantityControl(
                            itemId: food.id,
                            available: food.available,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _details(bool grid, {bool showName = true}) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: grid
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      if (showName)
        Text(
          food.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      const SizedBox(height: 4),
      Text(
        food.description,
        textAlign: grid ? TextAlign.center : TextAlign.start,
        style: TextStyle(fontSize: grid ? 10 : 12, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 8),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 15),
            Text(' ${food.rating.toStringAsFixed(1)}'),
            const SizedBox(width: 10),
            const Icon(Icons.timer, size: 15, color: Colors.grey),
            Text(' ${food.prepTime}'),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        alignment: grid ? WrapAlignment.center : WrapAlignment.start,
        children: [
          Text(
            '₹${food.price}',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Free Delivery',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
      if (!food.available)
        const Text(
          'Currently unavailable',
          style: TextStyle(color: Colors.red),
        ),
    ],
  );
}
