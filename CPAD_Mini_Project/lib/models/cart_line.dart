class CartLine {
  final String userId;
  final String itemId;
  final int quantity;
  const CartLine({
    required this.userId,
    required this.itemId,
    required this.quantity,
  });
  factory CartLine.fromMap(Map<String, dynamic> map) => CartLine(
    userId: map['user_id'] as String,
    itemId: map['item_id'] as String,
    quantity: map['quantity'] as int,
  );
  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'item_id': itemId,
    'quantity': quantity,
  };
}
