import 'package:flutter/material.dart';

class PasswordsDontMatchDialog extends StatelessWidget {
  const PasswordsDontMatchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sign up failed"),
      content: const Text("The passwords don't match. Please try again."),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Okay"),
        ),
      ],
    );
  }
}
