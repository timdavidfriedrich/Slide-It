import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PasswordResetFailedDialog extends StatelessWidget {
  final FirebaseAuthException error;

  const PasswordResetFailedDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    void okay() {
      Navigator.pop(context);
    }

    String errorMessage() {
      switch (error.code) {
        case "auth/invalid-email":
        case "auth/user-not-found":
          return "There is no user corresponding to this email address. Try again.";
        case "auth/missing-android-pkg-name":
        case "auth/missing-continue-uri":
        case "auth/missing-ios-bundle-id":
        case "auth/invalid-continue-uri":
        case "auth/unauthorized-continue-uri":
        default:
          return "An error occured.";
      }
    }

    return PlatformAlertDialog(
      title: const Text('Password reset failed'),
      content: Text(errorMessage()),
      actions: [
        PlatformDialogAction(
          onPressed: () => okay(),
          child: const Text('Okay'),
        ),
      ],
    );
  }
}
