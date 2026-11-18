import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

class QuickFilterChips extends StatelessWidget {
  const QuickFilterChips({super.key});
  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: MenuProvider.quickFilters
          .map(
            (f) => ChoiceChip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(f),
              selected: menu.selectedQuickFilter == f,
              selectedColor: Colors.orange,
              labelStyle: const TextStyle(color: Colors.black87),
              onSelected: (_) => menu.quickFilter(f),
            ),
          )
          .toList(),
    );
  }
}
