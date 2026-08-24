import 'package:flutter/material.dart';

void main() {
  runApp(const FoodHubApp());
}

class FoodHubApp extends StatelessWidget {
  const FoodHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FoodHub",
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedBottom = 0;
  int selectedCategory = 0;
  String selectedQuickFilter = "All";
  String searchQuery = "";

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    "⭐ All",
    "🍕 Pizza",
    "🍔 Burger",
    "🍜 Noodles",
    "🥗 Healthy",
    "🍰 Dessert",
    "☕ Coffee",
    "🍗 Chicken",
    "🍟 Snacks",
  ];

  final List<String> quickFilters = [
    "All",
    "Veg",
    "Non-Veg",
    "Bestseller",
    "Offers",
  ];

  final List<Map<String, dynamic>> foodItems = [
    {
      "name": "Margherita Pizza",
      "desc": "Classic cheese & fresh basil",
      "price": "₹299",
      "rating": "4.8",
      "time": "20 min",
      "emoji": "🍕",
      "quantity": 0,
      "category": "Pizza",
      "type": "Veg",
      "bestseller": true,
      "offer": true,
    },
    {
      "name": "Cheese Burger",
      "desc": "Juicy patty with cheddar",
      "price": "₹199",
      "rating": "4.7",
      "time": "15 min",
      "emoji": "🍔",
      "quantity": 0,
      "category": "Burger",
      "type": "Non-Veg",
      "bestseller": true,
      "offer": false,
    },
    {
      "name": "Chicken Biryani",
      "desc": "Aromatic basmati rice",
      "price": "₹249",
      "rating": "4.9",
      "time": "25 min",
      "emoji": "🍛",
      "quantity": 0,
      "category": "Chicken",
      "type": "Non-Veg",
      "bestseller": true,
      "offer": true,
    },
    {
      "name": "Hakka Noodles",
      "desc": "Stir-fried with veggies",
      "price": "₹229",
      "rating": "4.6",
      "time": "18 min",
      "emoji": "🍜",
      "quantity": 0,
      "category": "Noodles",
      "type": "Veg",
      "bestseller": false,
      "offer": false,
    },
    {
      "name": "Caesar Salad",
      "desc": "Crisp romaine lettuce",
      "price": "₹179",
      "rating": "4.5",
      "time": "12 min",
      "emoji": "🥗",
      "quantity": 0,
      "category": "Healthy",
      "type": "Veg",
      "bestseller": false,
      "offer": false,
    },
    {
      "name": "Cold Coffee",
      "desc": "Chilled & frothy blend",
      "price": "₹149",
      "rating": "4.8",
      "time": "10 min",
      "emoji": "☕",
      "quantity": 0,
      "category": "Coffee",
      "type": "Veg",
      "bestseller": false,
      "offer": true,
    },
    {
      "name": "Chocolate Brownie",
      "desc": "Rich molten chocolate",
      "price": "₹169",
      "rating": "4.9",
      "time": "8 min",
      "emoji": "🍰",
      "quantity": 0,
      "category": "Dessert",
      "type": "Veg",
      "bestseller": true,
      "offer": false,
    },
    {
      "name": "French Fries",
      "desc": "Crispy & perfectly salted",
      "price": "₹129",
      "rating": "4.7",
      "time": "10 min",
      "emoji": "🍟",
      "quantity": 0,
      "category": "Snacks",
      "type": "Veg",
      "bestseller": false,
      "offer": false,
    },
  ];

  int get cartCount =>
      foodItems.fold(0, (sum, item) => sum + (item["quantity"] as int));

  List<Map<String, dynamic>> get filteredItems {
    return foodItems.where((food) {
      final matchesSearch = food["name"].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      String selectedCatString = categories[selectedCategory].split(" ").last;
      final matchesCategory =
          selectedCatString == "All" || food["category"] == selectedCatString;
      bool matchesQuickFilter = true;
      if (selectedQuickFilter == "Veg") {
        matchesQuickFilter = food["type"] == "Veg";
      } else if (selectedQuickFilter == "Non-Veg") {
        matchesQuickFilter = food["type"] == "Non-Veg";
      } else if (selectedQuickFilter == "Bestseller") {
        matchesQuickFilter = food["bestseller"] == true;
      } else if (selectedQuickFilter == "Offers") {
        matchesQuickFilter = food["offer"] == true;
      }
      return matchesSearch && matchesCategory && matchesQuickFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "🍔 FoodHub",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message:
                  "${screenWidth.toInt()}×${screenHeight.toInt()}  |  ${orientation.name}",
              child: const Icon(Icons.notifications),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottom,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (value) => setState(() => selectedBottom = value),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                if (cartCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return _buildTabletLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
    );
  }

  // ─── MOBILE LAYOUT ────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BoxConstraints constraints) {
    final itemsToShow = filteredItems;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLayoutBadge("Mobile Layout  (<600 dp)", Colors.blue),
            const SizedBox(height: 12),
            _buildLocationHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 25),
            _buildOfferBanner(constraints),
            const SizedBox(height: 25),
            _buildCategoriesRow(),
            const SizedBox(height: 25),
            const Text(
              "Quick Filters",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildQuickFilters(),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Popular Food",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "See All",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            itemsToShow.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) =>
                        _buildFoodCard(itemsToShow[index], isGrid: false),
                  ),
          ],
        ),
      ),
    );
  }

  // ─── TABLET / WEB LAYOUT ──────────────────────────────────────────────────
  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX 1: Constrain sidebar min/max width so it never gets too
        // narrow at ~600 dp where flex-2 would only give ~200 dp,
        // causing the sidebar content to squeeze and overflow.
        // ConstrainedBox keeps it between 200 and 300 dp regardless of flex.
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLayoutBadge(
                    "Tablet/Web Layout  (≥600 dp)",
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildLocationHeader(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildOfferBanner(constraints),
                  const SizedBox(height: 20),
                  const Text(
                    "Quick Filters",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildQuickFilters(),
                ],
              ),
            ),
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Right panel takes all remaining space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoriesRow(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Popular Food",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "See All",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    // FIX 2: Use LayoutBuilder inside OrientationBuilder so
                    // crossAxisCount is decided by the RIGHT PANEL's actual
                    // available width, not the full screen width.
                    // This prevents too many columns at intermediate widths.
                    return LayoutBuilder(
                      builder: (context, gridConstraints) {
                        final int crossAxisCount =
                            gridConstraints.maxWidth > 500
                            ? 3
                            : gridConstraints.maxWidth > 300
                            ? 2
                            : 1;

                        // FIX 3: childAspectRatio is computed from actual
                        // column width so cards are always tall enough to
                        // fit emoji + text + button without clipping.
                        final double colWidth =
                            (gridConstraints.maxWidth -
                                (crossAxisCount - 1) * 12 -
                                32) /
                            crossAxisCount;
                        // Card content needs ~210 dp of height for 3-line
                        // text + button; ratio = width / height.
                        final double aspectRatio = colWidth / 220;

                        final itemsToShow = filteredItems;
                        return itemsToShow.isEmpty
                            ? _buildEmptyState()
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: aspectRatio,
                                    ),
                                itemCount: itemsToShow.length,
                                itemBuilder: (context, index) => _buildFoodCard(
                                  itemsToShow[index],
                                  isGrid: true,
                                ),
                              );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── SHARED COMPONENTS ────────────────────────────────────────────────────

  Widget _buildLayoutBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.devices, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deliver To", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Row(
          children: const [
            Icon(Icons.location_on, color: Colors.orange),
            SizedBox(width: 5),
            Flexible(
              child: Text(
                "Mumbai, Maharashtra",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: (value) => setState(() => searchQuery = value),
      decoration: InputDecoration(
        hintText: "Search food...",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() => searchQuery = "");
                },
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
  }

  Widget _buildOfferBanner(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xffFF9800), Color(0xffFF5722)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "🔥 50% OFF",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "On Your First Order",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Use Code: FOOD50",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.fastfood, size: 60, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(categories.length, (index) {
        return ChoiceChip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(categories[index]),
          selected: selectedCategory == index,
          selectedColor: Colors.orange,
          labelStyle: const TextStyle(color: Colors.black87),
          onSelected: (_) => setState(() => selectedCategory = index),
        );
      }),
    );
  }

  Widget _buildQuickFilters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: quickFilters.map((filter) {
        return ChoiceChip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(filter),
          selected: selectedQuickFilter == filter,
          selectedColor: Colors.orange,
          labelStyle: const TextStyle(color: Colors.black87),
          onSelected: (_) => setState(() => selectedQuickFilter = filter),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No items found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            "Try changing filters or search term",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food, {required bool isGrid}) {
    return isGrid ? _buildGridCard(food) : _buildListCard(food);
  }

  // ─── LIST CARD (mobile) ───────────────────────────────────────────────────
  // FIX 4: Wrap the entire card content in IntrinsicHeight so the Row
  // children can use CrossAxisAlignment.stretch without overflow.
  // The quantity control is wrapped in a Column with mainAxisSize.min
  // so it never forces the Row taller than the text content.
  Widget _buildListCard(Map<String, dynamic> food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmojiStack(food),
            const SizedBox(width: 15),
            // Expanded ensures text column fills available width
            // and never pushes the button off screen.
            Expanded(child: _buildFoodDetails(food)),
            const SizedBox(width: 8),
            // FIX 5: Column wrapper with mainAxisSize.min keeps the
            // quantity control from expanding to full Row height and
            // keeps it top-aligned with the emoji/text.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildQuantityControl(food)],
            ),
          ],
        ),
      ),
    );
  }

  // ─── GRID CARD (tablet/web) ───────────────────────────────────────────────
  // FIX 6: Use a SingleChildScrollView fallback inside each grid card so
  // if for any reason content still exceeds the cell height (e.g. very
  // long food name), it scrolls instead of overflowing.
  Widget _buildGridCard(Map<String, dynamic> food) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section: emoji + details
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEmojiStack(food),
                const SizedBox(height: 8),
                _buildGridFoodDetails(food),
              ],
            ),
            // Bottom section: Add / quantity button always at bottom
            _buildQuantityControl(food),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiStack(Map<String, dynamic> food) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(food["emoji"], style: const TextStyle(fontSize: 40)),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: food["type"] == "Veg" ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.circle,
                size: 6,
                color: food["type"] == "Veg" ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        if (food["bestseller"] == true)
          Positioned(
            bottom: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Text(
                "🔥 Best",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // FIX 7: All text in grid details has overflow: ellipsis and tight
  // maxLines so no text can force the card taller than its aspect ratio.
  Widget _buildGridFoodDetails(Map<String, dynamic> food) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          food["name"],
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          food["desc"],
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        // FIX 8: Wrap rating + time row in FittedBox so it scales down
        // gracefully when the column is narrow (e.g. 3-col landscape).
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 13),
              const SizedBox(width: 3),
              Text(food["rating"], style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 8),
              const Icon(Icons.timer, size: 13, color: Colors.grey),
              const SizedBox(width: 3),
              Text(food["time"], style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // FIX 9: Price + Free Delivery also in FittedBox so it never
        // overflows on narrow 3-column cards.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                food["price"],
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                "Free Delivery",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFoodDetails(Map<String, dynamic> food) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          food["name"],
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          food["desc"],
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // FIX 10: Wrap the rating row in a FittedBox — at very narrow
        // mobile widths (e.g. 320 dp) the icons + text still fit cleanly.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 15),
              const SizedBox(width: 3),
              Text(food["rating"], style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 10),
              const Icon(Icons.timer, size: 15, color: Colors.grey),
              const SizedBox(width: 3),
              Text(food["time"], style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Flexible(
              child: Text(
                food["price"],
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              "Free Delivery",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // FIX 11: Quantity control uses mainAxisSize.min on its inner Row so
  // it never stretches beyond the buttons it contains.
  Widget _buildQuantityControl(Map<String, dynamic> food) {
    if (food["quantity"] == 0) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.add, color: Colors.white, size: 16),
        label: const Text("Add", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // FIX 12: Fixed padding keeps the button compact at all widths.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => setState(() => food["quantity"] = 1),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        // FIX 13: mainAxisSize.min prevents this Row from stretching
        // full-width inside the card, which was pushing text off-screen.
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            onPressed: () => setState(() => food["quantity"]--),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            "${food["quantity"]}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            onPressed: () => setState(() => food["quantity"]++),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
