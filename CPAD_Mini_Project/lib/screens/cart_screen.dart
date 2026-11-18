import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/quantity_control.dart';
import '../widgets/ui_helpers.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onBrowse, onOrdered;
  const CartScreen({
    super.key,
    required this.onBrowse,
    required this.onOrdered,
  });
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final address = TextEditingController(), coupon = TextEditingController();
  bool addressEdited = false;
  String? _profileAddress;
  @override
  void dispose() {
    address.dispose();
    coupon.dispose();
    super.dispose();
  }

  Future<void> place() async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    await perform(context, () async {
      final id = await orders.placeOrder(
        address.text.trim(),
        cart.appliedCoupon,
      );
      if (!mounted) return;
      final matches = orders.orders.where((o) => o.id == id);
      // Show the committed order's total, never an old client estimate.
      final total = matches.isEmpty ? null : matches.first.total;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order placed!'),
          content: Text(
            'Order #${id.substring(0, 8).toUpperCase()}${total == null ? '' : '\nTotal: ₹$total'}\nThank you for ordering with FoodHub.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('View profile & orders'),
            ),
          ],
        ),
      );
      if (mounted) {
        coupon.clear();
        widget.onOrdered();
      }
    });
  }

  Widget price(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : null,
            color: label == 'Delivery fee' ? Colors.green : null,
          ),
        ),
      ],
    ),
  );
  Widget summary(CartProvider cart) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Coupon',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: coupon,
            enabled: !cart.busy,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Enter coupon code',
              border: OutlineInputBorder(),
            ),
          ),
          TextButton(
            onPressed: cart.busy
                ? null
                : () => perform(
                    context,
                    () => cart.applyCoupon(coupon.text.trim()),
                  ),
            child: cart.previewing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Apply'),
          ),
          if (cart.couponMessage != null)
            Text(
              cart.couponValid
                  ? 'FOOD50 applied, you save ₹${cart.discount}'
                  : cart.couponMessage!,
              style: TextStyle(
                color: cart.couponValid ? Colors.green : Colors.red,
              ),
            ),
          if (cart.appliedCoupon != null)
            TextButton(
              onPressed: cart.busy
                  ? null
                  : () {
                      coupon.clear();
                      perform(context, cart.removeCoupon);
                    },
              child: const Text('Remove coupon'),
            ),
          if (cart.error != null) ...[
            Text(cart.error!, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: cart.busy ? null : cart.refreshQuote,
              child: const Text('Retry price preview'),
            ),
          ],
          const Divider(),
          price('Subtotal', '₹${cart.quotedSubtotal}'),
          price('Discount', '−₹${cart.discount}'),
          price('Delivery fee', 'FREE'),
          price(
            'Total',
            cart.total == null ? 'Updating…' : '₹${cart.total}',
            bold: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: address,
            enabled: !cart.checkingOut,
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() => addressEdited = true),
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              hintText: 'Required before placing an order',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
  );
  Widget orderButton(CartProvider cart) {
    final placing = context.watch<OrdersProvider>().placing;
    return FilledButton(
      onPressed:
          cart.totalItems == 0 ||
              address.text.trim().isEmpty ||
              cart.busy ||
              placing ||
              cart.total == null
          ? null
          : place,
      child: placing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Place Order'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>(),
        menu = context.watch<MenuProvider>();
    final profile = context.watch<AuthProvider>().profile;
    if (!addressEdited && _profileAddress != profile?.address) {
      _profileAddress = profile?.address;
      address.text = profile?.address ?? '';
    }
    if (cart.loading || menu.loading) return const LoadingView();
    if (menu.error != null) {
      return ErrorView(message: menu.error!, onRetry: menu.reload);
    }
    if (cart.error != null && cart.quantities.isEmpty) {
      return ErrorView(
        message: cart.error!,
        onRetry: () => cart.load(cart.uid!),
      );
    }
    if (cart.quantities.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        action: FilledButton(
          onPressed: widget.onBrowse,
          child: const Text('Browse food'),
        ),
      );
    }
    final lines = cart.quantities.entries.map((entry) {
      final matches = menu.items.where((f) => f.id == entry.key);
      if (matches.isEmpty) {
        return Card(
          child: ListTile(
            title: const Text('Item no longer available'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: cart.busy
                  ? null
                  : () => perform(context, () => cart.remove(entry.key)),
            ),
          ),
        );
      }
      final food = matches.first;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(food.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('₹${food.price} each'),
                    if (!food.available)
                      const Text(
                        'Unavailable — remove to order',
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        QuantityControl(
                          itemId: food.id,
                          available: food.available,
                        ),
                        Text(
                          '₹${food.price * entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove item',
                onPressed: cart.busy
                    ? null
                    : () => perform(context, () => cart.remove(entry.key)),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      );
    }).toList();
    return LayoutBuilder(
      builder: (context, c) {
        final wide = MediaQuery.sizeOf(context).width >= 600;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: lines,
                ),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      summary(cart),
                      const SizedBox(height: 12),
                      orderButton(cart),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [...lines, summary(cart)],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total: ${cart.total == null ? 'Updating…' : '₹${cart.total}'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  orderButton(cart),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
