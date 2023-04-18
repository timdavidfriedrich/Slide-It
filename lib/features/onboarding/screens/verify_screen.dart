import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/features/core/screens/app_scaffold.dart';
import 'package:rating/features/core/services/auth_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  Timer? reloadTimer;
  bool _sendButtonBlocked = false;
  Timer? _blockTimer;
  final int _seconds = 60;
  late int _secondsLeft;

  void _startReloadTimer() async {
    setState(() => reloadTimer = Timer.periodic(const Duration(seconds: 3), (_) => _reload()));
  }

  void _reload() async {
    await AuthService.reloadUser().whenComplete(() {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        reloadTimer?.cancel();
        Navigator.pushNamed(context, AppScaffold.routeName);
      }
    });
  }

  void _resetBlockTimer() {
    _blockTimer?.cancel();
    setState(() => _secondsLeft = _seconds);
  }

  Future<void> _sendVerificationEmail() async {
    AuthService.sendVerificationEmail();
    setState(() => _sendButtonBlocked = true);
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft == 0) {
        setState(() => _sendButtonBlocked = false);
        _resetBlockTimer();
      }
    });
  }

  @override
  void initState() {
    _resetBlockTimer();
    _startReloadTimer();
    super.initState();
  }

  @override
  void dispose() {
    reloadTimer?.cancel();
    _blockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Verify your email", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text("We sent you an email with a link. Please, click on it to verify your email address."),
              const SizedBox(height: 32),
              PlatformElevatedButton(
                onPressed: _sendButtonBlocked ? null : () => _sendVerificationEmail(),
                child: Text(_sendButtonBlocked ? "Wait $_secondsLeft seconds" : "Resend verification email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
