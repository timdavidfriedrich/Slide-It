import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/screen.dart';

class HomeScreen extends StatefulWidget implements Screen {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  @override
  String get displayName => "Home";

  @override
  Icon get icon => const Icon(Icons.home_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.home);
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.largePadding),
          child: ListView(
            children: const [
              SizedBox(height: Constants.largePadding),
              Card(
                child: Placeholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
