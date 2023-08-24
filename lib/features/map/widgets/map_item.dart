import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/utils/string_parser.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/screens/item/view_item_screen.dart';
import 'package:rating/features/settings/provider/settings_provider.dart';

class MapItem extends StatelessWidget {
  final Item item;
  final bool highlighted;
  final Function()? onTap;
  const MapItem({super.key, required this.item, this.highlighted = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    const int maxNameLength = 16;
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    void showItem() {
      if (highlighted) {
        context.pop();
        return;
      }
      context.push(ViewItemScreen.routeName, extra: item);
    }

    return InkWell(
      onTap: onTap ?? showItem,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.all(Constants.smallPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
              border: Border.all(
                color: highlighted ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.background,
                width: Constants.minimalPadding,
              ),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: item.image ?? Text(StringParser.truncate(item.name, maxNameLength)),
          ),
          Positioned(
            top: -Constants.minimalPadding,
            right: -Constants.minimalPadding,
            child: Container(
              padding: const EdgeInsets.all(Constants.minimalPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                item.averageRating.toStringAsFixed(settings.numberOfDecimals),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
