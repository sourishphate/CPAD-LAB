import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/models/app_profile.dart';
import 'package:flutter_application_1/models/food_item.dart';
import 'package:flutter_application_1/models/order_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/profile_service.dart';
import 'package:flutter_application_1/services/menu_service.dart';
import 'package:flutter_application_1/services/cart_service.dart';
import 'package:flutter_application_1/services/favorites_service.dart';
import 'package:flutter_application_1/services/order_service.dart';
import 'package:flutter_application_1/services/service_errors.dart';

final testClient = SupabaseClient(
  'https://example.supabase.co',
  'public-test-key',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);
const testFood = FoodItem(
  id: 'test-food',
  name: 'Test meal with a longer name',
  description: 'A sample catalogue description for layout tests',
  price: 200,
  rating: 4.8,
  prepTime: '20 min',
  emoji: '🍕',
  category: 'Pizza',
  type: 'Veg',
  bestseller: true,
  offer: true,
  available: true,
);
final testProfile = AppProfile(
  id: 'test-user',
  name: 'Student Name',
  phone: '9876543210',
  address: 'College campus, main gate',
  hasOrdered: false,
  createdAt: DateTime.utc(2026),
);

class FakeAuthService extends AuthService {
  FakeAuthService() : super(testClient);
  @override
  Session? get currentSession => Session(
    accessToken: 'test-token',
    tokenType: 'bearer',
    user: User(
      id: 'test-user',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-11-14T00:00:00Z',
    ),
  );
  @override
  Stream<AuthState> get authChanges => const Stream.empty();
}

class FakeProfileService extends ProfileService {
  FakeProfileService() : super(testClient);
  @override
  Future<AppProfile> load(String uid) async => testProfile;
}

class FakeMenuService extends MenuService {
  FakeMenuService() : super(testClient);
  @override
  Future<List<FoodItem>> load() async => [testFood];
}

class FakeCartService extends CartService {
  FakeCartService() : super(testClient);
  Map<String, int> rows = {'test-food': 1};
  bool fail = false;
  String? lastCode;
  @override
  Future<Map<String, int>> load(String uid) async => Map.of(rows);
  @override
  Future<void> setQuantity(String uid, String id, int quantity) async {
    if (fail) throw const ServiceFailure('Test request failed');
    quantity <= 0 ? rows.remove(id) : rows[id] = quantity;
  }

  @override
  Future<Map<String, dynamic>> preview(String code) async {
    lastCode = code;
    // Deliberately unusual server values prove Dart displays server output.
    return {
      'valid': code == 'FOOD50',
      'discount': code == 'FOOD50' ? 43 : 0,
      'subtotal': 200,
      'total': code == 'FOOD50' ? 157 : 200,
      'message': code == 'FOOD50' ? 'FOOD50 applied' : 'Invalid coupon code',
    };
  }
}

class FakeFavoritesService extends FavoritesService {
  FakeFavoritesService() : super(testClient);
  bool fail = false;
  @override
  Future<Set<String>> load(String uid) async => {'test-food'};
  @override
  Future<void> setFavorite(String uid, String id, bool value) async {
    if (fail) throw const ServiceFailure('Test request failed');
  }
}

class FakeOrderService extends OrderService {
  FakeOrderService() : super(testClient);
  @override
  Future<List<OrderModel>> load(String uid) async => [];
}
