import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/utils/string_parser.dart';
import 'package:rating/features/map/provider/map_provider.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/screens/item/view_item_screen.dart';
import 'package:rating/features/ratings/widgets/my_rating_card.dart';

class ItemSheet extends StatelessWidget {
  final Function(DragEndDetails)? onHorizontalSwipe;
  final Function()? onClose;
  const ItemSheet({super.key, this.onHorizontalSwipe, this.onClose});

  @override
  Widget build(BuildContext context) {
    MapProvider map = Provider.of<MapProvider>(context);
    const int maxNameLength = 16;

    void openItemScreen() {
      context.pop();
      context.push(ViewItemScreen.routeName, extra: map.selectedItem);
      map.selectedItem = null;
    }

    return GestureDetector(
      onHorizontalDragEnd: onHorizontalSwipe,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Constants.normalPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Constants.defaultBorderRadius),
            topRight: Radius.circular(Constants.defaultBorderRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Constants.normalPadding),
            Row(
              children: [
                Expanded(
                  child: Text(
                    StringParser.truncate(map.selectedItem?.name ?? "", maxNameLength),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: Constants.normalPadding),
                IconButton(
                  onPressed: openItemScreen,
                  icon: Icon(PlatformIcons(context).fullscreen),
                ),
                const SizedBox(width: Constants.minimalPadding),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(PlatformIcons(context).clear),
                ),
              ],
            ),
            const SizedBox(height: Constants.smallPadding),
            MyRatingCard(item: map.selectedItem ?? Item.empty()),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
