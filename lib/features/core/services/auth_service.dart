import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/onboarding/widgets/password_reset_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_in_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_up_failed_dialog.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static AuthService instance = AuthService();

  Future<bool> reloadUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await user!.reload();
      Log.hint("Reloaded user (User ID: ${user.uid}).");
      return true;
    } catch (e) {
      Log.error(e);
      return false;
    }
  }

  // ? Should anonymous sign in be implemented?
  // static Future signInAnonymously() async {
  //   try {
  //     await _firebaseAuth.signInAnonymously();
  //   } catch (error) {
  //     Log.error(error);
  //   }
  // }

  Future<bool> signInWithGoogle() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      Log.hint("Signed in with Google (User ID: ${user!.uid}).");
      return true;
    } catch (error) {
      Log.error("GOOGLE SIGN IN: $error");
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String name, String email, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await sendVerificationEmail();
      Log.hint("Created user with email and password (User ID: ${user?.uid}).");
      return true;
    } catch (error) {
      Log.error("EMAIL SIGN UP: $error");
      if (error is! FirebaseAuthException) return false;
      showAdaptiveDialog(context: Global.context, builder: (context) => SignUpFailedDialog(error: error));
      return false;
    }
  }

  Future<bool> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await user!.sendEmailVerification();
      Log.hint("Send verification email (User ID: ${user.uid}).");
      return true;
    } catch (error) {
      Log.error("VERIFICATION EMAIL: $error");
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
      await Provider.of<DataProvider>(Global.context, listen: false).loadData();
      // Navigator.pop(Global.context);
      Global.pop();
      Log.hint("User signed in with email and password (User ID: ${user?.uid}).");
      return true;
    } catch (error) {
      Log.error("EMAIL SIGN IN: $error");
      if (error is! FirebaseAuthException) return false;
      showAdaptiveDialog(context: Global.context, builder: (context) => SignInFailedDialog(error: error));
      return false;
    }
  }

  Future<bool> signOut() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await _firebaseAuth.signOut();
      Log.hint("User signed out (User ID: ${user!.uid}).");
      return true;
    } catch (error) {
      Log.error("SIGN OUT: $error");
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      Log.hint("Send password reset email (to: $email).");
      return true;
    } catch (error) {
      Log.error("PASSWORD RESET EMAIL: $error");
      if (error is! FirebaseAuthException) return false;
      showAdaptiveDialog(context: Global.context, builder: (context) => PasswordResetFailedDialog(error: error));
      return false;
    }
  }

  Future<bool> deleteUserEntry() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await user!.delete();
      Log.hint("Deleted User (ID: ${user.uid}) from Auth Service.");
      return true;
    } catch (error) {
      Log.error("DELETE ACCOUNT: $error");
      return false;
    }
  }
}
