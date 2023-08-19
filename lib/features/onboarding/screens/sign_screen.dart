import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/services/auth_service.dart';
import 'package:rating/features/core/services/cloud_service.dart';
import 'package:rating/features/onboarding/screens/forgot_password_screen.dart';
import 'package:rating/features/onboarding/screens/welcome_screen.dart';
import 'package:rating/features/onboarding/utils/email_validator.dart';
import 'package:rating/features/onboarding/utils/sign_type.dart';
import 'package:rating/features/onboarding/widgets/passwords_dont_match_dialog.dart';

class SignScreen extends StatefulWidget {
  static const String routeName = "${WelcomeScreen.routeName}/Sign";
  final SignType? signType;
  const SignScreen({super.key, this.signType = SignType.none});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  String _name = "";
  String _email = "";
  String _password = "";
  String _repeatedPassword = "";
  bool _isEmailValid = false;
  bool _isPasswordObscured = true;

  void _signIn() {
    AuthService.instance.signInWithEmailAndPassword(_email, _password);
  }

  void _signUp() async {
    if (_password != _repeatedPassword) {
      showDialog(context: context, builder: (context) => const PasswordsDontMatchDialog());
      return;
    }

    final bool userHasBeenCreated = await AuthService.instance.createUserWithEmailAndPassword(_name, _email, _password);
    if (!userHasBeenCreated) return;
    final bool userDataHasBeenCreated = await CloudService.instance.saveUserData(name: _name);

    if (!userDataHasBeenCreated) return;
    if (!mounted) return;
    context.pop();
  }

  void _updateName(String name) {
    setState(() => _name = name);
  }

  void _updateEmail(String email) {
    setState(() => _email = email);
  }

  bool _isSignInValid() {
    return _isEmailValid && _password.isNotEmpty;
  }

  bool _isSignUpValid() {
    return _isEmailValid && _password.isNotEmpty && _repeatedPassword.isNotEmpty && _name.isNotEmpty;
  }

  void _checkIfEmailIsValid() {
    setState(() => _isEmailValid = EmailValidator.validate(_email));
  }

  void _updatePassword(String password) {
    setState(() => _password = password);
  }

  void _updateRepeatedPassword(String repeatedPassword) {
    setState(() => _repeatedPassword = repeatedPassword);
  }

  void _changePasswordVisibility() {
    setState(() => _isPasswordObscured = !_isPasswordObscured);
  }

  void _navigateToForgotPasswordScreen() {
    context.push(ForgotPasswordScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Expanded(
            //   child: Image.asset(
            //     widget.signType == widget.signType.signIn ? AssetPath.mascotWaving : AssetPath.mascotHanging,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.signType == SignType.signIn ? "Schön, dass du\nwieder da bist!" : "Willkommen!",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: Constants.largePadding),
                  if (widget.signType == SignType.signUp)
                    TextField(
                      decoration: const InputDecoration(
                        label: Text("Anzeigename"),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (text) => _updateName(text),
                    ),
                  const SizedBox(height: Constants.normalPadding),
                  TextField(
                    decoration: const InputDecoration(
                      label: Text("Email"),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (text) {
                      _updateEmail(text);
                      _checkIfEmailIsValid();
                    },
                  ),
                  const SizedBox(height: Constants.normalPadding),
                  TextField(
                    textInputAction: widget.signType == SignType.signIn ? TextInputAction.done : TextInputAction.next,
                    obscureText: _isPasswordObscured,
                    onChanged: (text) => _updatePassword(text),
                    decoration: InputDecoration(
                      label: const Text("Passwort"),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      suffixIcon: _password.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () => _changePasswordVisibility(),
                              icon: Icon(_isPasswordObscured ? PlatformIcons(context).eyeSolid : PlatformIcons(context).eyeSlashSolid),
                            ),
                    ),
                  ),
                  const SizedBox(height: Constants.normalPadding),
                  if (widget.signType == SignType.signUp)
                    TextField(
                      decoration: const InputDecoration(
                        label: Text("Password wiederholen"),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      obscureText: true,
                      onChanged: (text) => _updateRepeatedPassword(text),
                    ),
                  const SizedBox(height: Constants.mediumPadding),
                  widget.signType == SignType.signIn
                      ? ElevatedButton(
                          onPressed: _isSignInValid() ? () => _signIn() : null,
                          child: const Text("Einloggen"),
                        )
                      : ElevatedButton(
                          onPressed: _isSignUpValid() ? () => _signUp() : null,
                          child: const Text("Registrieren"),
                        ),
                  const SizedBox(height: Constants.smallPadding),
                  widget.signType == SignType.signIn
                      ? TextButton(
                          onPressed: () => _navigateToForgotPasswordScreen(),
                          child: Text(
                            "Passwort vergessen?",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: Constants.largePadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
