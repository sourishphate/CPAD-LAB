import 'package:flutter/material.dart';
import '../services/service_errors.dart';

Future<void> perform(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (context.mounted && success != null) message(context, success);
  } catch (e) {
    if (context.mounted) message(context, readableError(e));
  }
}

void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
String? requiredName(String? v) =>
    (v ?? '').trim().isEmpty ? 'Enter your name' : null;
String? validEmail(String? v) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v ?? '').trim())
    ? null
    : 'Enter a valid email';
String? validPhone(String? v) => RegExp(r'^\d{10}$').hasMatch((v ?? '').trim())
    ? null
    : 'Enter exactly 10 digits';
String? validPassword(String? v) =>
    (v ?? '').length >= 6 ? null : 'Use at least 6 characters';
Widget centeredContent(Widget child, {double width = 600}) => Align(
  alignment: Alignment.topCenter,
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: width),
    child: child,
  ),
);
