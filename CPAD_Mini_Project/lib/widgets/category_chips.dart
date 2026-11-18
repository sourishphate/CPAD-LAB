import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});
  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        MenuProvider.categories.length,
        (i) => ChoiceChip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(MenuProvider.categories[i]),
          selected: menu.selectedCategory == i,
          selectedColor: Colors.orange,
          labelStyle: const TextStyle(color: Colors.black87),
          onSelected: (_) => menu.category(i),
        ),
      ),
    );
  }
}
