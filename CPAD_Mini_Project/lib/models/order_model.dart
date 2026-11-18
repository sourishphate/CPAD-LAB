import 'order_line.dart';

class OrderModel {
  final String id;
  final String userId;
  final int subtotal;
  final int discount;
  final int deliveryFee;
  final int total;
  final String? couponCode;
  final String address;
  final String status;
  final DateTime createdAt;
  final List<OrderLine> items;
  const OrderModel({
    required this.id,
    required this.userId,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.couponCode,
    required this.address,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });
  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    subtotal: map['subtotal'] as int,
    discount: map['discount'] as int,
    deliveryFee: map['delivery_fee'] as int,
    total: map['total'] as int,
    couponCode: map['coupon_code'] as String?,
    address: map['address'] as String,
    status: map['status'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    items: (map['order_items'] as List? ?? [])
        .map((e) => OrderLine.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'subtotal': subtotal,
    'discount': discount,
    'delivery_fee': deliveryFee,
    'total': total,
    'coupon_code': couponCode,
    'address': address,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'order_items': items.map((e) => e.toMap()).toList(),
  };
  String get shortId => id.substring(0, 8).toUpperCase();
}
