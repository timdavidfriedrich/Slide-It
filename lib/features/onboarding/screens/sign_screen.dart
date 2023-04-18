import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
// import 'package:rating/constants/asset_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/features/core/services/auth_service.dart';
import 'package:rating/features/onboarding/screens/forgot_password_screen.dart';
import 'package:rating/features/onboarding/screens/welcome_screen.dart';
import 'package:rating/features/onboarding/services/email_validator.dart';
import 'package:rating/features/onboarding/services/sign_arguments.dart';
import 'package:rating/features/onboarding/services/sign_type.dart';
import 'package:rating/features/onboarding/widgets/passwords_dont_match_dialog.dart';

class SignScreen extends StatefulWidget {
  static const String routeName = "${WelcomeScreen.routeName}/Sign";
  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  late SignArguments arguments;
  SignType signType = SignType.none;

  String _email = "";
  String _password = "";
  String _repeatedPassword = "";
  bool _isEmailValid = false;
  bool _isPasswordObscured = true;

  void _signIn() {
    AuthService.signInWithEmailAndPassword(_email, _password);
  }

  void _signUp() {
    if (_password != _repeatedPassword) {
      showDialog(context: context, builder: (context) => const PasswordsDontMatchDialog());
      return;
    }
    AuthService.createUserWithEmailAndPassword(_email, _password);
    Navigator.pop(context);
  }

  void _updateEmail(String email) {
    setState(() => _email = email);
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
    Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        arguments = (ModalRoute.of(context)!.settings.arguments as SignArguments);
        signType = arguments.signType;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          //     signType == SignType.signIn ? AssetPath.mascotWaving : AssetPath.mascotHanging,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  // TODO: Replace with arb
                  signType == SignType.signIn ? "Great to see\nyou again!" : "Welcome!",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 48),
                PlatformTextField(
                  // TODO: Replace with arb
                  material: (context, platform) {
                    return MaterialTextFieldData(
                      decoration: const InputDecoration(
                        label: Text("Email"),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    );
                  },
                  cupertino: (context, platform) {
                    return CupertinoTextFieldData(placeholder: "Email");
                  },
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    _updateEmail(text);
                    _checkIfEmailIsValid();
                  },
                ),
                const SizedBox(height: 16),
                PlatformTextField(
                  textInputAction: signType == SignType.signIn ? TextInputAction.done : TextInputAction.next,
                  obscureText: _isPasswordObscured,
                  onChanged: (text) => _updatePassword(text),
                  material: (context, platform) {
                    return MaterialTextFieldData(
                        decoration: InputDecoration(
                      label: const Text("Password"),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      suffixIcon: _password.isEmpty
                          ? null
                          : PlatformIconButton(
                              onPressed: () => _changePasswordVisibility(),
                              icon: Icon(_isPasswordObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                            ),
                    ));
                  },
                  cupertino: (context, platform) {
                    return CupertinoTextFieldData(
                      placeholder: "Password",
                      suffix: _password.isEmpty
                          ? null
                          : PlatformIconButton(
                              onPressed: () => _changePasswordVisibility(),
                              icon: Icon(_isPasswordObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                signType == SignType.signIn
                    ? Container()
                    : PlatformTextField(
                        material: (context, platform) {
                          return MaterialTextFieldData(
                            decoration: const InputDecoration(
                              label: Text("Repeat Password"),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                          );
                        },
                        cupertino: (context, platform) {
                          return CupertinoTextFieldData(placeholder: "Repeat Password");
                        },
                        obscureText: true,
                        onChanged: (text) => _updateRepeatedPassword(text),
                      ),
                const SizedBox(height: 32),
                signType == SignType.signIn
                    ? PlatformElevatedButton(
                        onPressed: !_isEmailValid || _password.isEmpty ? null : () => _signIn(),
                        // TODO: Replace with arb
                        child: const Text("Sign in"),
                      )
                    : PlatformElevatedButton(
                        onPressed: !_isEmailValid || _password.isEmpty || _repeatedPassword.isEmpty ? null : () => _signUp(),
                        // TODO: Replace with arb
                        child: const Text("Sign up"),
                      ),
                const SizedBox(height: 8),
                signType == SignType.signIn
                    ? PlatformTextButton(
                        onPressed: () => _navigateToForgotPasswordScreen(),
                        child: Text(
                          // TODO: Replace with arb
                          "Forgot password?",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).hintColor),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}