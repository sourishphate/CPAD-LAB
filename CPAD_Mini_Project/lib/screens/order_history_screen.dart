import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/orders_provider.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state.dart';
import '../widgets/ui_helpers.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    Widget body;
    if (provider.loading) {
      body = const LoadingView();
    } else if (provider.error != null) {
      body = ErrorView(
        message: provider.error!,
        onRetry: () => provider.load(provider.uid!),
      );
    } else if (provider.orders.isEmpty) {
      body = const EmptyState(icon: Icons.receipt_long, title: 'No orders yet');
    } else {
      body = RefreshIndicator(
        onRefresh: () => provider.load(provider.uid!),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: provider.orders
              .map(
                (order) => Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(order: order),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '#${order.shortId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(label: Text(order.status)),
                            ],
                          ),
                          Text(
                            DateFormat(
                              'd MMM yyyy, h:mm a',
                            ).format(order.createdAt.toLocal()),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.items
                                .map((i) => '${i.quantity}x ${i.name}')
                                .join(', '),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${order.total}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: centeredContent(body),
    );
  }
}
