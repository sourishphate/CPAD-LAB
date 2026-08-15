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
  int selectedCategory = 0; // 0 is "All"
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

  // ✅ UPDATED: Added "desc" (Description) to all food items
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

  int get cartCount {
    return foodItems.fold(0, (sum, item) => sum + (item["quantity"] as int));
  }

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
    final itemsToShow = filteredItems;

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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottom,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          setState(() {
            selectedBottom = value;
          });
        },
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Deliver To", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange),
                  SizedBox(width: 5),
                  Text(
                    "Mumbai, Maharashtra",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search food...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Container(
                height: 170,
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
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "On Your First Order",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
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
                      const Icon(Icons.fastfood, size: 80, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(categories[index]),
                        selected: selectedCategory == index,
                        selectedColor: Colors.orange,
                        labelStyle: const TextStyle(color: Colors.black87),
                        onSelected: (value) {
                          setState(() {
                            selectedCategory = index;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "Quick Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: quickFilters.map((filter) {
                  return ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(filter),
                    selected: selectedQuickFilter == filter,
                    selectedColor: Colors.orange,
                    labelStyle: const TextStyle(color: Colors.black87),
                    onSelected: (selected) {
                      setState(() {
                        selectedQuickFilter = filter;
                      });
                    },
                  );
                }).toList(),
              ),
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
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        children: const [
                          Icon(Icons.search_off, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "No items found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Try changing filters or search term",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemsToShow.length,
                      itemBuilder: (context, index) {
                        final food = itemsToShow[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Aligned to top so badge looks good
                              children: [
                                // ✅ NEW: Stack for Emoji Box, Veg Dot, and Bestseller Badge
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Base: The orange emoji box
                                    Container(
                                      width: 75,
                                      height: 75,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Center(
                                        child: Text(
                                          food["emoji"],
                                          style: const TextStyle(fontSize: 40),
                                        ),
                                      ),
                                    ),
                                    // Top Left: Veg / Non-Veg Dot
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          border: Border.all(
                                            color: food["type"] == "Veg"
                                                ? Colors.green
                                                : Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.circle,
                                            size: 6,
                                            color: food["type"] == "Veg"
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Bottom Right: Bestseller Badge
                                    if (food["bestseller"] == true)
                                      Positioned(
                                        bottom: -8,
                                        right: -8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
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
                                ),

                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food["name"],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // ✅ NEW: Description added to the Column
                                      const SizedBox(height: 4),
                                      Text(
                                        food["desc"],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(food["rating"]),
                                          const SizedBox(width: 15),
                                          const Icon(
                                            Icons.timer,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(food["time"]),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            food["price"],
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Free Delivery",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                food["quantity"] == 0
                                    ? ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          "Add",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            food["quantity"] = 1;
                                          });
                                        },
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  food["quantity"]--;
                                                });
                                              },
                                            ),
                                            Text(
                                              "${food["quantity"]}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  food["quantity"]++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}