import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';
import 'package:rating/features/ratings/services/item.dart';

class ItemAppBar extends StatelessWidget {
  final Item item;
  final bool showBackButton;
  final bool showEditButton;
  const ItemAppBar({super.key, required this.item, this.showBackButton = true, this.showEditButton = true});

  @override
  Widget build(BuildContext context) {
    void back() {
      context.pop();
    }

    void edit() {
      context.push(EditItemScreen.routeName, extra: item);
    }

    return Row(
      children: [
        IconButton(onPressed: () => back(), icon: Icon(PlatformIcons(context).back)),
        Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              "${item.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(item.category).name})",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        if (showEditButton) IconButton(onPressed: () => edit(), icon: Icon(PlatformIcons(context).edit)),
      ],
    );
  }
}
