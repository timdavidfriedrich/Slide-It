import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:log/log.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/cloud_service.dart';
import 'package:rating/features/onboarding/widgets/password_reset_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_in_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_up_failed_dialog.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final User? user = FirebaseAuth.instance.currentUser;

  static Future<void> reloadUser() async {
    await user!.reload();
  }

  static Future signInAnonymously() async {
    // Messenger.loadingAnimation();
    try {
      await _firebaseAuth.signInAnonymously();
    } catch (error) {
      Log.error(error);
    }
    // Navigator.pop(Global.context);
  }

  static Future createUserWithEmailAndPassword(String email, String password) async {
    // Messenger.loadingAnimation();
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await sendVerificationEmail();
      // Navigator.pop(Global.context);
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => SignUpFailedDialog(error: error));
      Log.error(error);
    }
  }

  static Future sendVerificationEmail() async {
    try {
      await user!.sendEmailVerification();
    } catch (error) {
      Log.error(error);
    }
  }

  static Future signInWithEmailAndPassword(String email, String password) async {
    // Messenger.loadingAnimation();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
      await CloudService.loadUserData();
      Navigator.pop(Global.context);
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => SignInFailedDialog(error: error));
      Log.error(error);
    }
  }

  static Future signOut() async {
    // Messenger.loadingAnimation();
    try {
      await _firebaseAuth.signOut();
      // await AppUser.instance.signOut();
    } catch (error) {
      Log.error(error);
    }
    // Navigator.pop(Global.context);
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => PasswordResetFailedDialog(error: error));
      Log.error(error);
    }
  }
}
