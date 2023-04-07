import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/features/core/screen.dart';

class SettingsScreen extends StatefulWidget implements Screen {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

  @override
  String get displayName => "Einstellungen";

  @override
  Icon get icon => const Icon(Icons.settings_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.settings);
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
