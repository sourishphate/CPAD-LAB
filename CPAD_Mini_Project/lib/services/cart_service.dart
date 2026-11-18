import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_errors.dart';
import '../models/cart_line.dart';

class CartService {
  final SupabaseClient _client;
  CartService(this._client);
  Future<Map<String, int>> load(String uid) => guarded(() async {
    final rows = await _client.from('cart_items').select().eq('user_id', uid);
    return {
      for (final row in rows)
        CartLine.fromMap(row).itemId: CartLine.fromMap(row).quantity,
    };
  });
  Future<void> setQuantity(String uid, String id, int quantity) =>
      guarded(() async {
        if (quantity <= 0) {
          await _client
              .from('cart_items')
              .delete()
              .eq('user_id', uid)
              .eq('item_id', id);
        } else {
          await _client
              .from('cart_items')
              .upsert(
                CartLine(userId: uid, itemId: id, quantity: quantity).toMap(),
                onConflict: 'user_id,item_id',
              );
        }
      });
  Future<void> clear(String uid) => guarded(() async {
    await _client.from('cart_items').delete().eq('user_id', uid);
  });
  Future<Map<String, dynamic>> preview(String code) => guarded(
    () async => Map<String, dynamic>.from(
      await _client.rpc('preview_coupon', params: {'p_code': code}),
    ),
    order: true,
  );
}
