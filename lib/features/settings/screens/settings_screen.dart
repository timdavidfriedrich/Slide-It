import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/screens/screen.dart';
import 'package:rating/features/core/services/auth_service.dart';

class SettingsScreen extends StatefulWidget implements Screen {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

  @override
  String get displayName => "Einstellungen";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.settings_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.settings);
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _signOut() {
    AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.largePadding),
        children: [
          PlatformElevatedButton(onPressed: () => _signOut(), child: const Text("Sign out")),
        ],
      ),
    );
  }
}
