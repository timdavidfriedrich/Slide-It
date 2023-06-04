import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class SignUpFailedDialog extends StatelessWidget {
  final FirebaseAuthException error;

  const SignUpFailedDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    void okay() {
      context.pop();
    }

    String errorMessage() {
      switch (error.code) {
        case "email-already-in-use":
          return "The email is already in use. Try signing in.";
        case "invalid-email":
          return "The email is invalid. Try again.";
        case "operation-not-allowed":
          return "The operation is not allowed. Try again later.";
        case "weak-password":
          return error.message.toString();
        default:
          return "An error occured.";
      }
    }

    return PlatformAlertDialog(
      title: const Text("Sign up failed"),
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
