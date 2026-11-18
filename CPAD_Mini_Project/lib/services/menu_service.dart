import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_errors.dart';
import '../models/food_item.dart';

class MenuService {
  final SupabaseClient _client;
  MenuService(this._client);
  Future<List<FoodItem>> load() => guarded(
    () async => (await _client.from('menu_items').select().order('name'))
        .map(FoodItem.fromMap)
        .toList(),
  );
}
