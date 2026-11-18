import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/ui_helpers.dart';
import '../widgets/auth_form_layout.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      phone = TextEditingController(),
      address = TextEditingController();
  @override
  void initState() {
    super.initState();
    final p = context.read<AuthProvider>().profile;
    name.text = p?.name ?? '';
    phone.text = p?.phone ?? '';
    address.text = p?.address ?? '';
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: centeredContent(
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                  controller: phone,
                  validator: validPhone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  controller: address,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                  ),
                ),
                const SizedBox(height: 24),
                AuthButton(
                  loading: auth.loading,
                  label: 'Save changes',
                  onPressed: () {
                    if (form.currentState!.validate()) {
                      perform(context, () async {
                        await auth.updateProfile(
                          name.text.trim(),
                          phone.text.trim(),
                          address.text.trim(),
                        );
                        if (context.mounted) {
                          message(context, 'Profile saved.');
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
