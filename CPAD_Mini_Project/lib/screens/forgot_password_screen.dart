import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_layout.dart';
import '../widgets/ui_helpers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool recovery;
  const ForgotPasswordScreen({super.key, this.recovery = false});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final form = GlobalKey<FormState>();
  final value = TextEditingController();
  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthFormLayout(
      title: widget.recovery ? 'Set a new password' : 'Reset password',
      back: !widget.recovery,
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.recovery)
              PasswordField(
                controller: value,
                validator: validPassword,
                label: 'New password',
              )
            else
              TextFormField(
                controller: value,
                validator: validEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            const SizedBox(height: 24),
            AuthButton(
              loading: auth.loading,
              label: widget.recovery ? 'Save password' : 'Send reset email',
              onPressed: () {
                if (form.currentState!.validate()) {
                  perform(
                    context,
                    () => widget.recovery
                        ? auth.updatePassword(value.text)
                        : auth.resetPassword(value.text.trim()),
                    success: widget.recovery
                        ? 'Password updated.'
                        : 'If this email is registered, a reset link has been sent.',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
