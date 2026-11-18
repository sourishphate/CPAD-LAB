import 'package:flutter/foundation.dart';
import '../services/service_errors.dart';

// Generation tokens prevent late responses from restoring data after logout.
abstract class LoadableProvider extends ChangeNotifier {
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    generation++;
    super.dispose();
  }

  bool loading = false;
  String? error;
  int generation = 0;
  Future<void> loadTask(Future<void> Function(int token) task) async {
    final token = ++generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await task(token);
    } catch (e) {
      if (token == generation) error = readableError(e);
    } finally {
      if (token == generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void resetBase() {
    generation++;
    loading = false;
    error = null;
  }
}
