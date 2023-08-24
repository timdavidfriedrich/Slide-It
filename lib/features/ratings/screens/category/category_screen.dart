import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/map/screens/category_map_screen.dart';
import 'package:rating/features/ratings/models/category.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/widgets/item_card.dart';

class CategoryScreen extends StatefulWidget {
  static const String routeName = "/Category";
  final Category category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  void _openMap() {
    context.push(CategoryMapScreen.routeName, extra: widget.category);
  }

  void _edit() {
    // context.push(EditCategoryScreen.routeName, extra: widget.category);
  }

  @override
  Widget build(BuildContext context) {
    List<Item> items = widget.category.items;
    List<Item> itemsFirstRow = items.sublist(0, widget.category.items.length ~/ 2);
    List<Item> itemsSecondRow = items.sublist(widget.category.items.length ~/ 2, widget.category.items.length);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            title: Text(widget.category.name, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(widget.category.group.name, style: Theme.of(context).textTheme.bodySmall),
          ),
          actions: [
            IconButton(
              onPressed: _openMap,
              // TODO: Replace with platform icon
              icon: const Icon(Icons.map),
            ),
            IconButton(
              onPressed: _edit,
              icon: Icon(PlatformIcons(context).edit),
            ),
          ],
        ),
        body: items.isEmpty
            ? const Center(child: Text("Diese Kategorie ist leer."))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Constants.mediumPadding,
                  Constants.normalPadding,
                  Constants.mediumPadding,
                  Constants.largePadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          itemsFirstRow.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: Constants.normalPadding),
                            child: ItemCard(item: itemsFirstRow.elementAt(index)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Constants.normalPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          itemsSecondRow.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: Constants.normalPadding),
                            child: ItemCard(item: itemsSecondRow.elementAt(index)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
