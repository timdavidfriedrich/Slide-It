import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class PasswordsDontMatchDialog extends StatelessWidget {
  const PasswordsDontMatchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    okay() {
      context.pop();
    }

    return PlatformAlertDialog(
      title: const Text("Sign up failed"),
      content: const Text("The passwords don't match. Please try again."),
      actions: [
        PlatformDialogAction(
          onPressed: () => okay(),
          child: const Text("Okay"),
        ),
      ],
    );
  }
}
