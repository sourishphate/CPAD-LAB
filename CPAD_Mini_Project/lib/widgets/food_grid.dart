import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'food_card.dart';

class FoodGrid extends StatelessWidget {
  final List<FoodItem> items;
  final Widget? header, emptyState;
  const FoodGrid({
    super.key,
    required this.items,
    this.header,
    this.emptyState,
  });
  @override
  Widget build(BuildContext context) => OrientationBuilder(
    builder: (context, orientation) {
      // Lab 3: portrait uses two columns; landscape uses three. A scrollable card
      // keeps the existing design safe even in the narrow right panel at 600 dp.
      final columns = MediaQuery.orientationOf(context) == Orientation.portrait
          ? 2
          : 3;
      return CustomScrollView(
        slivers: [
          if (header != null) SliverToBoxAdapter(child: header),
          if (items.isEmpty && emptyState != null)
            SliverFillRemaining(hasScrollBody: false, child: emptyState!)
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 340,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => FoodCard(food: items[i], isGrid: true),
                  childCount: items.length,
                ),
              ),
            ),
        ],
      );
    },
  );
}
