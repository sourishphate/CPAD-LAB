import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_errors.dart';
import '../models/order_model.dart';

class OrderService {
  final SupabaseClient _client;
  OrderService(this._client);
  Future<List<OrderModel>> load(String uid) => guarded(
    () async =>
        (await _client
                .from('orders')
                .select('*, order_items(*)')
                .eq('user_id', uid)
                .order('created_at', ascending: false))
            .map(OrderModel.fromMap)
            .toList(),
  );
  Future<String> place(String address, String? coupon) => guarded(
    () async =>
        await _client.rpc(
              'place_order',
              params: {'p_address': address, 'p_coupon': coupon},
            )
            as String,
    order: true,
  );
}
