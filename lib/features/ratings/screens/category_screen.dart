import 'package:flutter/material.dart';
import 'package:rating/features/ratings/services/category.dart';

class CategoryScreen extends StatefulWidget {
  static const String routeName = "/Category";
  final Category category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.category.name)),
      ),
    );
  }
}
