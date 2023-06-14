import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/ratings/screens/edit_item_screen.dart';

class AddItemCard extends StatelessWidget {
  const AddItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToAdd() {
      context.push(EditItemScreen.routeName);
    }

    return AspectRatio(
      aspectRatio: 2 / 3,
      child: InkWell(
        onTap: () => navigateToAdd(),
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
        child: Card(
          margin: EdgeInsets.zero,
          child: Center(child: Icon(PlatformIcons(context).add)),
        ),
      ),
    );
  }
}
