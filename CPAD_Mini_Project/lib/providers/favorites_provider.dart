import '../models/food_item.dart';
import '../services/favorites_service.dart';
import '../services/service_errors.dart';
import 'loadable_provider.dart';
import 'menu_provider.dart';

class FavoritesProvider extends LoadableProvider {
  @override
  void dispose() {
    ids = {};
    pending.clear();
    uid = null;
    super.dispose();
  }

  final FavoritesService service;
  final MenuProvider menu;
  FavoritesProvider(this.service, this.menu);
  Set<String> ids = {};
  final Set<String> pending = {};
  String? uid;
  bool isFavorite(String id) => ids.contains(id);
  List<FoodItem> get favoriteItems =>
      menu.items.where((f) => ids.contains(f.id)).toList();
  Future<void> load(String user) => loadTask((token) async {
    uid = user;
    final rows = await service.load(user);
    if (token == generation) ids = rows;
  });
  Future<void> toggle(String id) async {
    final user = uid;
    if (user == null || pending.contains(id)) return;
    final token = generation;
    final was = ids.contains(id);
    pending.add(id);
    was ? ids.remove(id) : ids.add(id);
    notifyListeners();
    try {
      await service.setFavorite(user, id, !was);
    } catch (e) {
      if (token == generation) {
        was ? ids.add(id) : ids.remove(id);
        error = readableError(e);
      }
      rethrow;
    } finally {
      if (token == generation) {
        pending.remove(id);
        notifyListeners();
      }
    }
  }

  void clear() {
    resetBase();
    uid = null;
    ids = {};
    pending.clear();
    notifyListeners();
  }
}
