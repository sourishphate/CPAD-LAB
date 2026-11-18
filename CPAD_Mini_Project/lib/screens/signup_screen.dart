import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_layout.dart';
import '../widgets/ui_helpers.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  @override
  void dispose() {
    for (final c in [name, email, phone, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    await perform(context, () async {
      final session = await context.read<AuthProvider>().signUp(
        name.text.trim(),
        email.text.trim(),
        phone.text.trim(),
        password.text,
      );
      if (!mounted) return;
      message(
        context,
        session
            ? 'Welcome to FoodHub!'
            : 'Check your email to confirm your account, then log in. If already registered, try logging in or resetting your password.',
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) => AuthFormLayout(
    title: 'Create your account',
    back: true,
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: name,
            validator: requiredName,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: email,
            validator: validEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            controller: phone,
            validator: validPhone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone (10 digits)'),
          ),
          PasswordField(controller: password, validator: validPassword),
          PasswordField(
            controller: confirm,
            label: 'Confirm password',
            validator: (v) =>
                v == password.text ? null : 'Passwords must match',
          ),
          const SizedBox(height: 24),
          AuthButton(
            loading: context.watch<AuthProvider>().loading,
            label: 'Sign Up',
            onPressed: submit,
          ),
        ],
      ),
    ),
  );
}
