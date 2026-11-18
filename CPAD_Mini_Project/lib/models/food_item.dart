class FoodItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final double rating;
  final String prepTime;
  final String emoji;
  final String category;
  final String type;
  final bool bestseller;
  final bool offer;
  final bool available;
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.prepTime,
    required this.emoji,
    required this.category,
    required this.type,
    required this.bestseller,
    required this.offer,
    required this.available,
  });
  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String,
    price: map['price'] as int,
    rating: (map['rating'] as num).toDouble(),
    prepTime: map['prep_time'] as String,
    emoji: map['emoji'] as String,
    category: map['category'] as String,
    type: map['type'] as String,
    bestseller: map['bestseller'] as bool,
    offer: map['offer'] as bool,
    available: map['available'] as bool,
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'rating': rating,
    'prep_time': prepTime,
    'emoji': emoji,
    'category': category,
    'type': type,
    'bestseller': bestseller,
    'offer': offer,
    'available': available,
  };
}
