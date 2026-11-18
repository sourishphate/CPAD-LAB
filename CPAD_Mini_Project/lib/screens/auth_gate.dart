import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/session_providers.dart';
import '../widgets/loading_view.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.initializing) return const LoadingView();
    if (auth.recovering) return const ForgotPasswordScreen(recovery: true);
    if (auth.user == null) return const LoginScreen();
    return SessionProviders(key: ValueKey(auth.user!.id), uid: auth.user!.id);
  }
}
