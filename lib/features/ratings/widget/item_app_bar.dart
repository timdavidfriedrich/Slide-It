import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';
import 'package:rating/features/ratings/services/item.dart';

class ItemAppBar extends StatefulWidget {
  final Item item;
  final bool showBackButton;
  final bool showEditButton;
  const ItemAppBar({super.key, required this.item, this.showBackButton = true, this.showEditButton = true});

  @override
  State<ItemAppBar> createState() => _ItemAppBarState();
}

class _ItemAppBarState extends State<ItemAppBar> {
  bool _showFullName = false;
  final int _maxNameLength = 28;

  void _back() {
    context.pop();
  }

  void _edit() {
    context.push(EditItemScreen.routeName, extra: widget.item);
  }

  void _toggleFullName() {
    setState(() => _showFullName = !_showFullName);
  }

  String _truncateIfNecessary(String name) {
    String result;
    if (_showFullName) return name;
    if (name.length < _maxNameLength) return name;
    result = name.substring(0, min(_maxNameLength, widget.item.name.length));
    result += "...";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () => _back(), icon: Icon(PlatformIcons(context).back)),
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleFullName(),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_truncateIfNecessary(widget.item.name), style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(
                "${widget.item.category.name} (${Provider.of<DataProvider>(context).getGroupFromCategory(widget.item.category).name})",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        if (widget.showEditButton) IconButton(onPressed: () => _edit(), icon: Icon(PlatformIcons(context).edit)),
      ],
    );
  }
}
