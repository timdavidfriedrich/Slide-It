import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PasswordsDontMatchDialog extends StatelessWidget {
  const PasswordsDontMatchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: const Text("Sign up failed"),
      content: const Text("The passwords don't match. Please try again."),
      actions: [
        PlatformDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text("Okay"),
        ),
      ],
    );
  }
}
