import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceFailure implements Exception {
  final String message;
  const ServiceFailure(this.message);
  @override
  String toString() => message;
}

// Services are the only Supabase boundary. Never expose transport/database internals.
Future<T> guarded<T>(Future<T> Function() action, {bool order = false}) async {
  try {
    return await action();
  } on AuthException catch (e) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) {
      throw const ServiceFailure('Email or password is incorrect.');
    }
    if (m.contains('already registered') ||
        m.contains('already been registered')) {
      throw const ServiceFailure(
        'This email is already registered. Try logging in.',
      );
    }
    if (m.contains('weak') || m.contains('password')) {
      throw const ServiceFailure(
        'Use a stronger password with at least 6 characters.',
      );
    }
    if (m.contains('not confirmed')) {
      throw const ServiceFailure('Confirm your email before logging in.');
    }
    if (m.contains('rate') || m.contains('too many')) {
      throw const ServiceFailure(
        'Too many attempts. Please wait a few minutes.',
      );
    }
    if (m.contains('network') || m.contains('fetch') || m.contains('socket')) {
      throw const ServiceFailure(
        'Check your internet connection and try again.',
      );
    }
    throw const ServiceFailure('Authentication failed. Please try again.');
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST205' || e.code == '42P01' || e.code == 'PGRST202') {
      throw const ServiceFailure(
        'FoodHub database setup is incomplete. Please contact the app administrator.',
      );
    }
    // Only our intentional RAISE EXCEPTION messages are safe to display verbatim.
    if (order && e.code == 'P0001') {
      throw ServiceFailure(e.message);
    }
    throw const ServiceFailure(
      'Could not access FoodHub data. Check your connection and database setup.',
    );
  } on ServiceFailure {
    rethrow;
  } catch (_) {
    throw const ServiceFailure(
      'Something went wrong. Check your connection and try again.',
    );
  }
}

String readableError(Object e) =>
    e is ServiceFailure ? e.message : 'Something went wrong. Please try again.';
