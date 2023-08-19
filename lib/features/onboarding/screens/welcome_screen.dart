import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/auth_service.dart';
import 'package:rating/features/onboarding/screens/sign_screen.dart';
import 'package:rating/features/onboarding/utils/sign_type.dart';
import 'package:rive/rive.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = "/Welcome";
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late RiveAnimationController? _riveAnimationController;

  void _navigateToSignIn(BuildContext context) {
    context.push(SignScreen.routeName, extra: SignType.signIn);
  }

  void _navigateToSignUp(BuildContext context) {
    context.push(SignScreen.routeName, extra: SignType.signUp);
  }

  void _signInWithGoogle() async {
    await AuthService.instance.signInWithGoogle();
  }

  void _initLogo() {
    if (!mounted) return;
    setState(() => _riveAnimationController = SimpleAnimation("init"));
    Timer(const Duration(milliseconds: 1300), () => _showSlider());
  }

  void _showSlider() {
    if (!mounted) return;
    if (_riveAnimationController?.isActive ?? true) return;
    setState(() => _riveAnimationController = SimpleAnimation("drop slider"));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initLogo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Constants.largePadding),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: GestureDetector(
                    onTap: () => _initLogo(),
                    child: RiveAnimation.asset(
                      "assets/animations/logo.riv",
                      controllers: [_riveAnimationController!],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _navigateToSignIn(context),
                child: const Text("Einloggen"),
              ),
              const SizedBox(height: Constants.normalPadding),
              ElevatedButton(
                onPressed: () => _navigateToSignUp(context),
                child: const Text("Registrieren"),
              ),
              // const SizedBox(height: Constants.normalPadding),
              // TextButton(
              //   onPressed: () => _signInWithGoogle(),
              //   child: Text("Mit Google anmelden", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              // ),
              const SizedBox(height: Constants.largePadding),
            ],
          ),
        ),
      ),
    );
  }
}
