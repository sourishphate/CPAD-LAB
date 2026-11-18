import '../models/food_item.dart';
import '../services/menu_service.dart';
import 'loadable_provider.dart';

class MenuProvider extends LoadableProvider {
  @override
  void dispose() {
    items = [];
    searchQuery = '';
    selectedCategory = 0;
    selectedQuickFilter = 'All';
    super.dispose();
  }

  final MenuService service;
  MenuProvider(this.service);
  List<FoodItem> items = [];
  String searchQuery = '', selectedQuickFilter = 'All';
  int selectedCategory = 0;
  static const categories = [
    '⭐ All',
    '🍕 Pizza',
    '🍔 Burger',
    '🍜 Noodles',
    '🥗 Healthy',
    '🍰 Dessert',
    '☕ Coffee',
    '🍗 Chicken',
    '🍟 Snacks',
  ];
  static const quickFilters = ['All', 'Veg', 'Non-Veg', 'Bestseller', 'Offers'];
  Future<void> reload() => loadTask((token) async {
    final rows = await service.load();
    if (token == generation) items = rows;
  });
  void search(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void category(int value) {
    selectedCategory = value;
    notifyListeners();
  }

  void quickFilter(String value) {
    selectedQuickFilter = value;
    notifyListeners();
  }

  List<FoodItem> get filteredItems => items.where((f) {
    final category = categories[selectedCategory].split(' ').last;
    return f.available &&
        f.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
        (category == 'All' || f.category == category) &&
        switch (selectedQuickFilter) {
          'Veg' => f.type == 'Veg',
          'Non-Veg' => f.type == 'Non-Veg',
          'Bestseller' => f.bestseller,
          'Offers' => f.offer,
          _ => true,
        };
  }).toList();
  void clear() {
    resetBase();
    items = [];
    searchQuery = '';
    selectedCategory = 0;
    selectedQuickFilter = 'All';
    notifyListeners();
  }
}
