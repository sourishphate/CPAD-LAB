import 'package:flutter/material.dart';

class AuthFormLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool back;
  const AuthFormLayout({
    super.key,
    required this.title,
    required this.child,
    this.back = false,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: back ? AppBar(title: Text(title)) : null,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, c) {
          final form = Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🍔 FoodHub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          );
          return Center(
            child: SingleChildScrollView(
              child: c.maxWidth >= 600
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Card(child: form),
                    )
                  : form,
            ),
          );
        },
      ),
    ),
  );
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
  });
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: hidden,
    validator: widget.validator,
    autocorrect: false,
    enableSuggestions: false,
    decoration: InputDecoration(
      labelText: widget.label,
      suffixIcon: IconButton(
        tooltip: hidden ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => hidden = !hidden),
        icon: Icon(hidden ? Icons.visibility : Icons.visibility_off),
      ),
    ),
  );
}

class AuthButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback onPressed;
  const AuthButton({
    super.key,
    required this.loading,
    required this.label,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: loading ? null : onPressed,
    child: loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(label),
  );
}
