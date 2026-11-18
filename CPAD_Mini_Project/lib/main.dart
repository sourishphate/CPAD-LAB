import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/menu_service.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'services/order_service.dart';
import 'services/profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!isSupabaseConfigured) {
    runApp(
      const FoodHubApp(
        setupMessage:
            'Add your Supabase project URL and public anon key in lib/config/supabase_config.dart, then restart. See SETUP.md.',
      ),
    );
    return;
  }
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
    final client = Supabase.instance.client;
    // Provider shares service-backed state across pages without global mutable maps.
    runApp(
      MultiProvider(
        providers: [
          Provider(create: (_) => MenuService(client)),
          Provider(create: (_) => CartService(client)),
          Provider(create: (_) => FavoritesService(client)),
          Provider(create: (_) => OrderService(client)),
          ChangeNotifierProvider(
            create: (_) =>
                AuthProvider(AuthService(client), ProfileService(client)),
          ),
        ],
        child: const FoodHubApp(),
      ),
    );
  } catch (_) {
    runApp(
      const FoodHubApp(
        setupMessage:
            'FoodHub could not initialize. Check your Supabase configuration and connection, then restart.',
      ),
    );
  }
}

class FoodHubApp extends StatelessWidget {
  final String? setupMessage;
  const FoodHubApp({super.key, this.setupMessage});
  @override
  Widget build(BuildContext context) => MaterialApp(
    // Reset pushed routes too, so an expired session cannot leave old order pages open.
    key: ValueKey(
      setupMessage ?? context.select<AuthProvider, String?>((a) => a.user?.id),
    ),
    debugShowCheckedModeBanner: false,
    title: 'FoodHub',
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.orange,
      scaffoldBackgroundColor: Colors.grey.shade100,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    home: setupMessage == null
        ? const AuthGate()
        : Scaffold(
            appBar: AppBar(title: const Text('🍔 FoodHub')),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.settings,
                        size: 60,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connect FoodHub to Supabase',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(setupMessage!, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
  );
}
