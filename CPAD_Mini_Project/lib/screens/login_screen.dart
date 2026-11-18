import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_layout.dart';
import '../widgets/ui_helpers.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthFormLayout(
      title: 'Welcome back',
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: email,
              validator: validEmail,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            PasswordField(controller: password, validator: validPassword),
            const SizedBox(height: 24),
            AuthButton(
              loading: auth.loading,
              label: 'Login',
              onPressed: () {
                if (form.currentState!.validate()) {
                  perform(
                    context,
                    () => auth.signIn(email.text.trim(), password.text),
                  );
                }
              },
            ),
            TextButton(
              onPressed: auth.loading
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
              child: const Text('New to FoodHub? Sign up'),
            ),
            TextButton(
              onPressed: auth.loading
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}
