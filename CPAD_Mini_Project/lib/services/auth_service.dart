import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_errors.dart';

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;
  Future<void> signIn(String email, String password) => guarded(() async {
    await _client.auth.signInWithPassword(email: email, password: password);
  });
  Future<bool> signUp(
    String name,
    String email,
    String phone,
    String password,
  ) => guarded(() async {
    final result = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );
    // Auth can intentionally conceal duplicate signup; make the UI useful in either case.
    return result.session != null;
  });
  Future<void> signOut() => guarded(() => _client.auth.signOut());
  Future<void> resetPassword(String email) =>
      guarded(() => _client.auth.resetPasswordForEmail(email));
  Future<void> updatePassword(String password) => guarded(() async {
    await _client.auth.updateUser(UserAttributes(password: password));
  });
}
