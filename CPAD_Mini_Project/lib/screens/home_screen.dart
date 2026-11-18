import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/quick_filter_chips.dart';
import '../widgets/offer_banner.dart';
import '../widgets/layout_badge.dart';
import '../widgets/food_card.dart';
import '../widgets/food_grid.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Widget location(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final name = profile?.name.trim().split(' ').first ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(
            'Hi, $name',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 8),
        const Text('Deliver To', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.orange),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                (profile?.address ?? '').trim().isEmpty
                    ? 'Mumbai, Maharashtra'
                    : profile!.address!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget searchBar(MenuProvider menu) => TextField(
    controller: search,
    onChanged: menu.search,
    decoration: InputDecoration(
      hintText: 'Search food...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: menu.searchQuery.isNotEmpty
          ? IconButton(
              onPressed: () {
                search.clear();
                menu.search('');
              },
              icon: const Icon(Icons.clear),
            )
          : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );
  Widget heading(MenuProvider menu) => Row(
    children: [
      const Expanded(
        child: Text(
          'Popular Food',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      TextButton(
        onPressed: () {
          search.clear();
          menu.search('');
          menu.category(0);
          menu.quickFilter('All');
        },
        child: const Text(
          'See All',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
  static const noResults = EmptyState(
    icon: Icons.search_off,
    title: 'No items found',
    hint: 'Try changing filters or search term',
  );
  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    // Lab 3: retain MediaQuery dimensions and orientation alongside LayoutBuilder.
    final size = MediaQuery.sizeOf(context),
        orientation = MediaQuery.orientationOf(context);
    if (menu.loading) return const LoadingView();
    if (menu.error != null) {
      return ErrorView(message: menu.error!, onRetry: menu.reload);
    }
    final items = menu.filteredItems;
    return LayoutBuilder(
      builder: (context, c) {
        // NavigationRail takes some width; use screen width for the same 600 dp switch.
        final wide = size.width >= 600;
        final badge = LayoutBadge(
          label: wide
              ? 'Tablet/Web Layout (≥600 dp) | ${orientation.name}'
              : 'Mobile Layout (<600 dp)',
          color: wide ? Colors.green : Colors.blue,
        );
        if (!wide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                badge,
                const SizedBox(height: 12),
                location(context),
                const SizedBox(height: 20),
                searchBar(menu),
                const SizedBox(height: 25),
                const OfferBanner(),
                const SizedBox(height: 25),
                const CategoryChips(),
                const SizedBox(height: 25),
                const Text(
                  'Quick Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const QuickFilterChips(),
                const SizedBox(height: 25),
                heading(menu),
                const SizedBox(height: 15),
                if (items.isEmpty)
                  noResults
                else
                  ...items.map((f) => FoodCard(food: f)),
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      badge,
                      const SizedBox(height: 16),
                      location(context),
                      const SizedBox(height: 20),
                      searchBar(menu),
                      const SizedBox(height: 20),
                      const OfferBanner(),
                      const SizedBox(height: 20),
                      const Text(
                        'Quick Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const QuickFilterChips(),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 4,
              child: FoodGrid(
                items: items,
                emptyState: noResults,
                header: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CategoryChips(),
                      const SizedBox(height: 12),
                      heading(menu),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
