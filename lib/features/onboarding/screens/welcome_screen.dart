import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/firebase/auth_service.dart';
import 'package:rating/features/onboarding/screens/sign_screen.dart';
import 'package:rating/features/onboarding/services/sign_type.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = "/Welcome";
  const WelcomeScreen({super.key});

  void _navigateToSignIn(BuildContext context) {
    context.push(SignScreen.routeName, extra: SignType.signIn);
  }

  void _navigateToSignUp(BuildContext context) {
    context.push(SignScreen.routeName, extra: SignType.signUp);
  }

  void _signInWithGoogle() async {
    await AuthService.instance.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Constants.largePadding),
              const SizedBox(height: Constants.largePadding),
              Text("Slide It",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _navigateToSignIn(context),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)),
                child: Text("Einloggen", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
              const SizedBox(height: Constants.normalPadding),
              ElevatedButton(
                onPressed: () => _navigateToSignUp(context),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)),
                child: Text("Registrieren", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
              const SizedBox(height: Constants.normalPadding),
              TextButton(
                onPressed: () => _signInWithGoogle(),
                child: Text("Mit Google anmelden", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              ),
              const SizedBox(height: Constants.largePadding),
            ],
          ),
        ),
      ),
    );
  }
}
