import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class SignInFailedDialog extends StatelessWidget {
  final FirebaseAuthException error;

  const SignInFailedDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    void okay() {
      context.pop();
    }

    String errorMessage() {
      switch (error.code) {
        case "invalid-email":
        case "user-not-found":
        case "wrong-password":
          return "The email or password is incorrect. Try again.";
        case "user-disabled":
          return "This account has been disabled.";
        default:
          return "An error occured.";
      }
    }

    return AlertDialog.adaptive(
      title: const Text("Sign in failed"),
      content: Text(errorMessage()),
      actions: [
        PlatformDialogAction(
          onPressed: () => okay(),
          child: const Text("Okay"),
        ),
      ],
    );
  }
}
