import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, hint;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint = '',
    this.action,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (hint.isNotEmpty)
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ?action,
        ],
      ),
    ),
  );
}
