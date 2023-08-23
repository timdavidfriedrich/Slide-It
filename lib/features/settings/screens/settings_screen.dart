import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/core/utils/shell_content.dart';
import 'package:rating/features/settings/provider/settings_provider.dart';
import 'package:rating/features/social/widgets/profile_card.dart';

class SettingsScreen extends StatefulWidget implements ShellContent {
  static const routeName = "/settings";
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

  @override
  String get displayName => "Einstellungen";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.settings_outlined);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.settings);
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool hideGroups = true;

  Function(bool)? toggleNotificationsForGroup(String groupId) {
    final SettingsProvider settings = Provider.of<SettingsProvider>(context, listen: false);
    return !settings.allowNotifications
        ? null
        : (value) {
            if (value) {
              settings.unmuteGroupWithId(groupId);
            } else {
              settings.muteGroupWithId(groupId);
            }
          };
  }

  @override
  Widget build(BuildContext context) {
    final DataProvider data = Provider.of<DataProvider>(context);
    final SettingsProvider settings = Provider.of<SettingsProvider>(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Constants.normalPadding),
        children: [
          const ProfileCard(),
          const SizedBox(height: Constants.normalPadding),
          ListTile(
            title: const Text("Nachkommastellen"),
            trailing: DropdownButton<int>(
              value: settings.numberOfDecimals,
              onChanged: (value) {
                if (value == null) return;
                settings.numberOfDecimals = value;
              },
              items: List.generate(
                Constants.maxRatingValueDecimal + 1,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(index == 0 ? "Keine" : " $index"),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text("Farbiger Hintergrund beim Bewerten"),
            trailing: Switch(
              value: settings.dynamicRatingColorEnabled,
              onChanged: (value) => settings.dynamicRatingColorEnabled = value,
            ),
          ),
          ListTile(
            title: const Text("Nach Standort fragen"),
            trailing: Switch(
              value: settings.askForLocation,
              onChanged: (value) => settings.askForLocation = value,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () => setState(() => hideGroups = !hideGroups),
                  tileColor: hideGroups ? null : Theme.of(context).colorScheme.surface,
                  title: const Text("Benachrichtigungen"),
                  subtitle: Text(hideGroups ? "(Ausklappen)" : "(Einklappen)"),
                  trailing: Switch(
                    value: settings.allowNotifications,
                    onChanged: (value) => settings.allowNotifications = value,
                  ),
                ),
                hideGroups
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: Constants.mediumPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(data.userGroups.length, (index) {
                            return ListTile(
                              title: Text(data.userGroups[index].name),
                              trailing: Switch(
                                value: !settings.mutedGroupIds.contains(data.userGroups[index].id),
                                onChanged: toggleNotificationsForGroup(data.userGroups[index].id),
                              ),
                            );
                          }),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
