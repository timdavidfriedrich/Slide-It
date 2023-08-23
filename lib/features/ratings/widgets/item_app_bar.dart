import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/core/utils/string_parser.dart';
import 'package:rating/features/geolocation/screens/category_map_screen.dart';
import 'package:rating/features/ratings/screens/item/edit_item_screen.dart';
import 'package:rating/features/ratings/models/item.dart';

class ItemAppBar extends StatefulWidget {
  final Item item;
  final bool showBackButton;
  final bool showEditButton;
  final bool showMapButton;
  const ItemAppBar({super.key, required this.item, this.showBackButton = true, this.showMapButton = true, this.showEditButton = true});

  @override
  State<ItemAppBar> createState() => _ItemAppBarState();
}

class _ItemAppBarState extends State<ItemAppBar> {
  bool _showFullName = false;
  final int _maxNameLength = 28;

  void _back() {
    context.pop();
  }

  void _openMap() {
    context.push(CategoryMapScreen.routeName, extra: (widget.item.category, widget.item));
  }

  void _edit() {
    context.push(EditItemScreen.routeName, extra: widget.item);
  }

  void _toggleFullName() {
    setState(() => _showFullName = !_showFullName);
  }

  String _truncateIfNecessary(String string) {
    if (_showFullName) return string;
    return StringParser.truncate(string, _maxNameLength);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.showBackButton) IconButton(onPressed: () => _back(), icon: Icon(PlatformIcons(context).back)),
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
        // TODO: replace icon with PlatformIcon
        if (widget.showMapButton && widget.item.location != null) IconButton(onPressed: _openMap, icon: const Icon(Icons.map)),
        if (widget.showEditButton) IconButton(onPressed: _edit, icon: Icon(PlatformIcons(context).edit)),
      ],
    );
  }
}
