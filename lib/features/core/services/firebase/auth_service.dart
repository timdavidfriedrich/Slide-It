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
    } catch (error) {
      Log.error(error);
    }
  }

  Future<bool> createUserWithEmailAndPassword(String name, String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await sendVerificationEmail();
      await CloudService.instance.saveUserData(name: name);
      return true;
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => SignUpFailedDialog(error: error));
      Log.error(error);
      return false;
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user!.sendEmailVerification();
    } catch (error) {
      Log.error(error);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
      await Provider.of<DataProvider>(Global.context, listen: false).loadData();
      Navigator.pop(Global.context);
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => SignInFailedDialog(error: error));
      Log.error(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (error) {
      Log.error(error);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      showDialog(context: Global.context, builder: (context) => PasswordResetFailedDialog(error: error));
      Log.error(error);
    }
  }
}
