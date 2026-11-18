import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/ui_helpers.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading && auth.profile == null) return const LoadingView();
    if (auth.error != null && auth.profile == null) {
      return ErrorView(message: auth.error!, onRetry: auth.loadProfile);
    }
    final profile = auth.profile;
    return centeredContent(
      ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              (profile?.name ?? '').isEmpty
                  ? '?'
                  : profile!.name.characters.first.toUpperCase(),
              style: const TextStyle(fontSize: 32, color: Colors.orange),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile?.name ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(auth.user?.email ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(profile?.phone ?? 'Not added'),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Delivery address'),
                  subtitle: Text(
                    (profile?.address ?? '').isEmpty
                        ? 'Not added'
                        : profile!.address!,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: auth,
                  child: const EditProfileScreen(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('My Orders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final orders = context.read<OrdersProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: orders,
                    child: const OrderHistoryScreen(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: auth.loading
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Log out of FoodHub?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await perform(context, auth.signOut);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
