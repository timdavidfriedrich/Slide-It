import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/onboarding/widgets/password_reset_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_in_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_up_failed_dialog.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  static AuthService instance = AuthService();

  Future<void> reloadUser() async {
    if (user == null) reloadUser();
    await user!.reload();
    Log.hint("Reloaded user (User ID: ${user!.uid}).");
  }

  // ? Should anonymous sign in be implemented?
  // static Future signInAnonymously() async {
  //   try {
  //     await _firebaseAuth.signInAnonymously();
  //   } catch (error) {
  //     Log.error(error);
  //   }
  // }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      Log.hint("Signed in with Google (User ID: ${user!.uid}).");
    } catch (error) {
      Log.error("GOOGLE SIGN IN: $error");
    }
  }

  Future<bool> createUserWithEmailAndPassword(String name, String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await sendVerificationEmail();
      await CloudService.instance.saveUserData(name: name);
      Log.hint("Created user with email and password (User ID: ${user!.uid}).");
      return true;
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => SignUpFailedDialog(error: error));
      Log.error("EMAIL SIGN UP: $error");
      return false;
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user!.sendEmailVerification();
      Log.hint("Send verification email (User ID: ${user!.uid}).");
    } catch (error) {
      Log.error("VERIFICATION EMAIL: $error");
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
      await Provider.of<DataProvider>(Global.context, listen: false).loadData();
      // Navigator.pop(Global.context);
      Global.pop();
      Log.hint("User signed in with email and password (User ID: ${user!.uid}).");
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => SignInFailedDialog(error: error));
      Log.error("EMAIL SIGN IN: $error");
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      Log.hint("User signed out (User ID: ${user!.uid}).");
    } catch (error) {
      Log.error("SIGN OUT: $error");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      Log.hint("Send password reset email (to: $email).");
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => PasswordResetFailedDialog(error: error));
      Log.error("PASSWORD RESET EMAIL: $error");
    }
  }
}
