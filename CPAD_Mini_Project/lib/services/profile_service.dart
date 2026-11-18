import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_errors.dart';
import '../models/app_profile.dart';

class ProfileService {
  final SupabaseClient _client;
  ProfileService(this._client);
  Future<AppProfile> load(String uid) => guarded(
    () async => AppProfile.fromMap(
      await _client.from('profiles').select().eq('id', uid).single(),
    ),
  );
  Future<void> update(String uid, String name, String phone, String address) =>
      guarded(() async {
        await _client
            .from('profiles')
            .update({'name': name, 'phone': phone, 'address': address})
            .eq('id', uid);
      });
}
