import 'package:flutter/material.dart';
import 'package:rating/features/core/services/firebase/auth_service.dart';
// import 'package:rating/constants/asset_path.dart';
import 'package:rating/features/onboarding/screens/sign_screen.dart';
import 'package:rating/features/onboarding/services/sign_arguments.dart';
import 'package:rating/features/onboarding/services/sign_type.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = "/Onboarding";
  const WelcomeScreen({super.key});

  void _navigateToSignIn(BuildContext context) {
    Navigator.of(context).pushNamed(SignScreen.routeName, arguments: SignArguments(signType: SignType.signIn));
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.of(context).pushNamed(SignScreen.routeName, arguments: SignArguments(signType: SignType.signUp));
  }

  void _signInWithGoogle() async {
    await AuthService.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            Text("Slide It",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
            const SizedBox(height: 24),
            // ? Flexible(child: Image.asset(AssetPath.mascotIdle)),
            const Spacer(),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _navigateToSignIn(context),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)),
              child: Text("Login", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToSignUp(context),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)),
              child: Text("Register", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _signInWithGoogle(),
              child: Text("Mit Google anmelden", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
