import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_errors.dart';

class FavoritesService {
  final SupabaseClient _client;
  FavoritesService(this._client);
  Future<Set<String>> load(String uid) => guarded(
    () async =>
        (await _client.from('favorites').select('item_id').eq('user_id', uid))
            .map((e) => e['item_id'] as String)
            .toSet(),
  );
  Future<void> setFavorite(String uid, String id, bool value) => guarded(
    () async {
      if (value) {
        await _client.from('favorites').insert({'user_id': uid, 'item_id': id});
      } else {
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', uid)
            .eq('item_id', id);
      }
    },
  );
}
