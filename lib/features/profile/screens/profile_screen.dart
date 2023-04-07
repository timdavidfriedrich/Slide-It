import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/features/core/screen.dart';

class ProfileScreen extends StatefulWidget implements Screen {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  String get displayName => "Profil";

  @override
  Icon get icon => const Icon(Icons.person_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.person);
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
