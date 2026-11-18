import 'package:flutter/material.dart';
import 'empty_state.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.cloud_off,
    title: 'Could not load data',
    hint: message,
    action: TextButton(onPressed: onRetry, child: const Text('Retry')),
  );
}
