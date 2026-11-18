import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/service_errors.dart';
import 'loadable_provider.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';

class OrdersProvider extends LoadableProvider {
  @override
  void dispose() {
    orders = [];
    uid = null;
    super.dispose();
  }

  final OrderService service;
  final CartProvider cart;
  final AuthProvider auth;
  OrdersProvider(this.service, this.cart, this.auth);
  List<OrderModel> orders = [];
  String? uid;
  bool placing = false;
  Future<void> load(String user) => loadTask((token) async {
    uid = user;
    final rows = await service.load(user);
    if (token == generation) orders = rows;
  });
  Future<String> placeOrder(String address, String? coupon) async {
    if (placing || cart.busy) {
      throw const ServiceFailure(
        'Please wait for your cart to finish updating.',
      );
    }
    final user = uid;
    if (user == null) throw const ServiceFailure('Please sign in again');
    final token = generation;
    placing = true;
    cart.checkingOut = true;
    cart.notifyCheckout();
    notifyListeners();
    try {
      final id = await service.place(address, coupon);
      if (token != generation) return id;
      cart.clearLocal();
      // A failed refresh must not turn a successfully committed order into a retry.
      await Future.wait([load(user), auth.loadProfile()]);
      if (uid == user) await cart.load(user);
      return id;
    } catch (e) {
      if (uid == user) error = readableError(e);
      rethrow;
    } finally {
      if (uid == user) {
        placing = false;
        cart.checkingOut = false;
        cart.notifyCheckout();
        notifyListeners();
      }
    }
  }

  void clear() {
    resetBase();
    orders = [];
    uid = null;
    placing = false;
    notifyListeners();
  }
}
