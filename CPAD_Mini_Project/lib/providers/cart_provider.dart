import '../services/cart_service.dart';
import '../services/service_errors.dart';
import 'loadable_provider.dart';
import 'menu_provider.dart';

class CartProvider extends LoadableProvider {
  @override
  void dispose() {
    quantities = {};
    uid = null;
    quote = null;
    appliedCoupon = null;
    couponMessage = null;
    super.dispose();
  }

  final CartService service;
  final MenuProvider menu;
  CartProvider(this.service, this.menu);
  Map<String, int> quantities = {};
  String? uid;
  bool mutating = false, previewing = false, checkingOut = false;
  String? appliedCoupon, couponMessage;
  bool couponValid = false;
  Map<String, dynamic>? quote;
  int _quoteVersion = 0;
  int get totalItems => quantities.values.fold(0, (a, b) => a + b);
  int get subtotal => menu.items.fold(
    0,
    (sum, f) => sum + (f.available ? f.price * (quantities[f.id] ?? 0) : 0),
  );
  int get discount => (quote?['discount'] as num?)?.toInt() ?? 0;
  // Total is displayed only from the server quote, never derived from a Dart coupon rule.
  int? get total => (quote?['total'] as num?)?.toInt();
  int get quotedSubtotal => (quote?['subtotal'] as num?)?.toInt() ?? subtotal;
  void notifyCheckout() => notifyListeners();
  bool get busy => mutating || previewing || checkingOut;
  Future<void> load(String user) => loadTask((token) async {
    uid = user;
    final rows = await service.load(user);
    if (token != generation) return;
    quantities = rows;
    await refreshQuote();
  });
  Future<void> refreshQuote([String? code]) async {
    final token = generation, version = ++_quoteVersion;
    final requested = code ?? appliedCoupon ?? '';
    quote = null;
    previewing = true;
    error = null;
    notifyListeners();
    try {
      final value = await service.preview(requested);
      if (token != generation || version != _quoteVersion) return;
      quote = value;
      couponValid = value['valid'] == true;
      appliedCoupon = couponValid ? requested.trim().toUpperCase() : null;
      couponMessage = requested.isEmpty ? null : value['message'] as String?;
    } catch (e) {
      if (token == generation && version == _quoteVersion) {
        error = readableError(e);
      }
    } finally {
      if (token == generation && version == _quoteVersion) {
        previewing = false;
        notifyListeners();
      }
    }
  }

  Future<void> applyCoupon(String code) async {
    await refreshQuote(code);
    if (code.trim().isEmpty && quote != null) {
      couponMessage = quote!['message'] as String?;
      notifyListeners();
    }
  }

  Future<void> removeCoupon() async {
    appliedCoupon = null;
    couponMessage = null;
    await refreshQuote('');
  }

  Future<void> _set(String id, int value) async {
    final user = uid;
    if (user == null || busy) return;
    final token = generation, old = quantities[id] ?? 0;
    final previousCode = appliedCoupon;
    mutating = true;
    quote = null;
    appliedCoupon = null;
    couponMessage = null;
    error = null;
    value <= 0 ? quantities.remove(id) : quantities[id] = value;
    notifyListeners();
    try {
      await service.setQuantity(user, id, value);
    } catch (e) {
      if (token == generation) {
        old == 0 ? quantities.remove(id) : quantities[id] = old;
        error = readableError(e);
      }
      rethrow;
    } finally {
      if (token == generation) {
        mutating = false;
        await refreshQuote(previousCode ?? '');
      }
    }
  }

  Future<void> add(String id) => _set(id, (quantities[id] ?? 0) + 1);
  Future<void> increment(String id) => add(id);
  Future<void> decrement(String id) => _set(id, (quantities[id] ?? 0) - 1);
  Future<void> remove(String id) => _set(id, 0);
  Future<void> clear() async {
    if (uid == null || busy) return;
    final token = generation;
    mutating = true;
    notifyListeners();
    try {
      await service.clear(uid!);
      if (token == generation) clearLocal();
    } finally {
      if (token == generation) {
        mutating = false;
        notifyListeners();
      }
    }
  }

  void clearLocal() {
    quantities = {};
    quote = null;
    appliedCoupon = null;
    couponMessage = null;
    couponValid = false;
    notifyListeners();
  }

  void reset() {
    resetBase();
    _quoteVersion++;
    uid = null;
    mutating = false;
    previewing = false;
    checkingOut = false;
    clearLocal();
  }
}
