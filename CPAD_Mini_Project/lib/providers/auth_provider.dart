import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart'
    show User, AuthChangeEvent;
import '../models/app_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/service_errors.dart';
import 'loadable_provider.dart';

class AuthProvider extends LoadableProvider {
  final AuthService service;
  final ProfileService profiles;
  late final StreamSubscription<dynamic> _subscription;
  User? user;
  AppProfile? profile;
  bool initializing = true, recovering = false;
  AuthProvider(this.service, this.profiles) {
    user = service.currentSession?.user;
    _subscription = service.authChanges.listen(
      (state) {
        final next = state.session?.user;
        if (user?.id != next?.id) {
          generation++;
          profile = null;
        }
        user = next;
        if (state.event == AuthChangeEvent.passwordRecovery) recovering = true;
        if (next == null) recovering = false;
        notifyListeners();
      },
      onError: (Object e) {
        error = readableError(e);
        notifyListeners();
      },
    );
    initializing = false;
  }
  Future<void> loadProfile() => loadTask((token) async {
    final uid = user?.id;
    if (uid == null) return;
    final row = await profiles.load(uid);
    if (token == generation) profile = row;
  });
  Future<void> _action(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = readableError(e);
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) =>
      _action(() => service.signIn(email, password));
  Future<bool> signUp(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    bool session = false;
    await _action(() async {
      session = await service.signUp(name, email, phone, password);
    });
    return session;
  }

  Future<void> signOut() => _action(() async {
    await service.signOut();
    user = null;
    profile = null;
    recovering = false;
    generation++;
  });
  Future<void> resetPassword(String email) =>
      _action(() => service.resetPassword(email));
  Future<void> updatePassword(String value) => _action(() async {
    await service.updatePassword(value);
    recovering = false;
  });
  Future<void> updateProfile(String name, String phone, String address) =>
      _action(() async {
        final uid = user?.id;
        if (uid == null) throw const ServiceFailure('Please sign in again');
        await profiles.update(uid, name, phone, address);
        final row = await profiles.load(uid);
        if (user?.id == uid) profile = row;
      });
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
