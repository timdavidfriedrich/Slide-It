import 'package:flutter/material.dart';
import 'package:rating/features/core/widgets/error_info.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/ratings/services/category_screen_arguments.dart';

class CategoryScreen extends StatefulWidget {
  static const String routeName = "/Category";
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Future<Category> _loadCategory() async {
    CategoryScreenArguments arguments = ModalRoute.of(context)?.settings.arguments as CategoryScreenArguments;

    return arguments.category;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Category>(
        future: _loadCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorInfo(message: snapshot.error.toString());
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          Category category = snapshot.data!;
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(title: Text(category.name)),
            ),
          );
        });
  }
}
