import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'ui_helpers.dart';

class QuantityControl extends StatelessWidget {
  final String itemId;
  final bool available;
  const QuantityControl({
    super.key,
    required this.itemId,
    this.available = true,
  });
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final n = cart.quantities[itemId] ?? 0;
    final disabled =
        cart.busy || cart.loading || cart.uid == null || !available;
    if (n == 0) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.add, color: Colors.white, size: 16),
        label: Text(
          available ? 'Add' : 'Unavailable',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: disabled
            ? null
            : () => perform(context, () => cart.add(itemId)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            Icons.remove,
            disabled
                ? null
                : () => perform(context, () => cart.decrement(itemId)),
          ),
          Text(
            '$n',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          _button(
            Icons.add,
            disabled
                ? null
                : () => perform(context, () => cart.increment(itemId)),
          ),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback? action) => IconButton(
    icon: Icon(icon, color: Colors.white, size: 16),
    onPressed: action,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
  );
}
