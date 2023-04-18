import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log/log.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/onboarding/widgets/password_reset_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_in_failed_dialog.dart';
import 'package:rating/features/onboarding/widgets/sign_up_failed_dialog.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final User? user = FirebaseAuth.instance.currentUser;

  static Future<void> reloadUser() async {
    await user!.reload();
  }

  // ? Should anonymous sign in be implemented?
  // static Future signInAnonymously() async {
  //   // Messenger.loadingAnimation();
  //   try {
  //     await _firebaseAuth.signInAnonymously();
  //   } catch (error) {
  //     Log.error(error);
  //   }
  //   // Navigator.pop(Global.context);
  // }

  static Future<void> signInWithGoogle() async {
    try {
      Log.warning("vamos");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      Log.warning("signed in with google");
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      Log.warning("got auth status");
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      Log.warning("got credentials");
      await _firebaseAuth.signInWithCredential(credential);
      Log.warning("signed in");
      await CloudService.loadUserData();
      Log.warning("loaded user data");
    } catch (error) {
      Log.error(error);
    }
  }

  static Future<void> createUserWithEmailAndPassword(String email, String password) async {
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

  static Future<void> sendVerificationEmail() async {
    try {
      await user!.sendEmailVerification();
    } catch (error) {
      Log.error(error);
    }
  }

  static Future<void> signInWithEmailAndPassword(String email, String password) async {
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

  static Future<void> signOut() async {
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
