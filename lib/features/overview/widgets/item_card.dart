import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/overview/screens/item/view_item_screen.dart';
import 'package:rating/features/overview/models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    const double imageSize = 150;

    void showItemRatings() {
      context.push(ViewItemScreen.routeName, extra: item);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => showItemRatings(),
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(Constants.normalPadding),
          child: SizedBox(
            width: imageSize,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                    child: Image(
                      image: item.imageProvider!,
                      fit: BoxFit.cover,
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                const SizedBox(height: Constants.smallPadding),
                Flexible(child: Text(item.name, style: Theme.of(context).textTheme.labelSmall)),
                const SizedBox(height: Constants.minimalPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(item.averageRating.toStringAsFixed(Constants.ratingValueDigit)),
                    const SizedBox(width: Constants.smallPadding),
                    const Text(Constants.ratingValueUnit),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
