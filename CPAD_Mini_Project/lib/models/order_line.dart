class OrderLine {
  final String id;
  final String orderId;
  final String itemId;
  final String name;
  final String emoji;
  final int price;
  final int quantity;
  const OrderLine({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.name,
    required this.emoji,
    required this.price,
    required this.quantity,
  });
  factory OrderLine.fromMap(Map<String, dynamic> map) => OrderLine(
    id: map['id'] as String,
    orderId: map['order_id'] as String,
    itemId: map['item_id'] as String,
    name: map['name'] as String,
    emoji: map['emoji'] as String,
    price: map['price'] as int,
    quantity: map['quantity'] as int,
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'item_id': itemId,
    'name': name,
    'emoji': emoji,
    'price': price,
    'quantity': quantity,
  };
}
