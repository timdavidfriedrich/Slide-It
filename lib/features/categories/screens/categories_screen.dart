import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating/features/core/screen.dart';

class CategoriesScreen extends StatefulWidget implements Screen {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();

  @override
  String get displayName => "Kategorien";

  @override
  Icon get icon => const Icon(Icons.category_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.list_bullet);
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
