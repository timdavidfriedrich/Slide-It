import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/ratings/screens/view_item_screen.dart';
import 'package:rating/features/ratings/services/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
            width: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Constants.defaultBorderRadius,
                        ),
                        child: item.image)),
                const SizedBox(height: Constants.smallPadding),
                Flexible(child: Text(item.name)),
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
