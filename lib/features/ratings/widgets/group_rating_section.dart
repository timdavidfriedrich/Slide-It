import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/features/core/models/app_user.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/ratings/models/rating.dart';
import 'package:rating/features/settings/provider/settings_provider.dart';

class GroupRatingSection extends StatelessWidget {
  final Item item;
  const GroupRatingSection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    return item.group.users.length <= 1
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${item.group.name}:", style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                    "⌀ ${item.averageRating.toStringAsFixed(settings.numberOfDecimals)} ${Constants.ratingValueUnit}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: Constants.smallPadding),
              if (item.ratings.length == 0 + (item.ownRating != null ? 1 : 0))
                const Text(
                  "Noch keine Bewertungen.",
                  textAlign: TextAlign.left,
                ),
              for (Rating r in item.ratings)
                if (r.userId != AppUser.currentUser?.uid)
                  ListTile(
                    leading: Provider.of<DataProvider>(context).getAppUserById(r.userId)?.getAvatar(),
                    title: Text(Provider.of<DataProvider>(context).getAppUserById(r.userId)?.name ?? "Unbenannt"),
                    subtitle: Text(r.comment ?? "Ohne Kommentar."),
                    trailing: Text(
                      "${r.value.toStringAsFixed(settings.numberOfDecimals)}${Constants.ratingValueUnit}",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
            ],
          );
  }
}
