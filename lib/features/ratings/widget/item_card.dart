import 'package:flutter/material.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/ratings/services/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Constants.normalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
            const SizedBox(height: Constants.normalPadding),
            Flexible(child: Text(item.name)),
            const SizedBox(height: Constants.minimalPadding),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: Constants.smallPadding),
                Text("Ø  ${item.averageRating.toStringAsFixed(1)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
