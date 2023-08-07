import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/shell_content.dart';
import 'package:rating/features/social/widgets/profile_card.dart';

class SettingsScreen extends StatefulWidget implements ShellContent {
  static const routeName = "/settings";
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
        children: const [
          ProfileCard(),
        ],
      ),
    );
  }
}
