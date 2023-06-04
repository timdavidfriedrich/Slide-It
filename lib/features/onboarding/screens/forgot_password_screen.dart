import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/auth_service.dart';
import 'package:rating/features/onboarding/screens/sign_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = "${SignScreen.routeName}/ForgotPassword";

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _sendButtonBlocked = false;
  Timer? _resetBlockTimer;
  final int _seconds = 60;
  late int _secondsLeft;

  Future<void> _sendPasswordResetEmail(String email) async {
    AuthService.instance.sendPasswordResetEmail(email);
    setState(() => _sendButtonBlocked = true);
    _resetBlockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft == 0) {
        setState(() => _sendButtonBlocked = false);
        timer.cancel();
        _secondsLeft = _seconds;
      }
    });
  }

  @override
  void initState() {
    setState(() => _secondsLeft = _seconds);
    super.initState();
  }

  @override
  void dispose() {
    _resetBlockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // ? resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Password reset", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: Constants.normalPadding),
                const Text("Enter your email address to receive a link to reset your password."),
                const SizedBox(height: Constants.normalPadding),
                TextField(
                  decoration: const InputDecoration(
                    label: Text("Email"),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  controller: _emailController,
                ),
                const SizedBox(height: Constants.mediumPadding),
                ElevatedButton(
                  onPressed: _sendButtonBlocked ? null : () => _sendPasswordResetEmail(_emailController.text),
                  child: Text(_sendButtonBlocked ? "Wait $_secondsLeft seconds" : "Send link"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
