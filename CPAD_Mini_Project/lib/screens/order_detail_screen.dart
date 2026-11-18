import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../widgets/ui_helpers.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Order #${order.shortId}')),
    body: centeredContent(
      ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            DateFormat('d MMM yyyy, h:mm a').format(order.createdAt.toLocal()),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(label: Text(order.status)),
          ),
          const Divider(),
          ...order.items.map(
            (i) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(i.emoji, style: const TextStyle(fontSize: 30)),
              title: Text(i.name),
              subtitle: Text('${i.quantity} × ₹${i.price}'),
              trailing: Text('₹${i.quantity * i.price}'),
            ),
          ),
          const Divider(),
          _row('Subtotal', '₹${order.subtotal}'),
          _row('Discount', '−₹${order.discount}'),
          if (order.couponCode != null) _row('Coupon', order.couponCode!),
          _row(
            'Delivery fee',
            order.deliveryFee == 0 ? 'FREE' : '₹${order.deliveryFee}',
          ),
          _row('Total', '₹${order.total}'),
          const SizedBox(height: 24),
          const Text(
            'Delivery address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(order.address),
        ],
      ),
    ),
  );
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
