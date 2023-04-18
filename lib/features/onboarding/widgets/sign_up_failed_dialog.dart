import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpFailedDialog extends StatelessWidget {
  final FirebaseAuthException error;

  const SignUpFailedDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    void okay() {
      Navigator.pop(context);
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

    return AlertDialog(
      title: const Text("Sign up failed"),
      content: Text(errorMessage()),
      actions: [
        ElevatedButton(
          onPressed: () => okay(),
          child: const Text("Okay"),
        ),
      ],
    );
  }
}
