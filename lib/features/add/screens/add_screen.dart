import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/add/screens/choose_category_screen.dart';
import 'package:rating/features/add/services/add_screen_arguments.dart';
import 'package:rating/features/categories/services/category.dart';
import 'package:rating/features/core/screens/app_scaffold.dart';
import 'package:rating/features/core/screens/screen.dart';
import 'package:rating/features/core/services/group.dart';

class AddScreen extends StatefulWidget implements Screen {
  static const routeName = "/add";
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();

  @override
  String get displayName => "Hinzufügen";

  @override
  Icon get icon {
    bool isIos = Theme.of(Global.context).platform == TargetPlatform.iOS;
    bool isMacOs = Theme.of(Global.context).platform == TargetPlatform.macOS;
    return isIos || isMacOs ? cupertinoIcon : materialIcon;
  }

  @override
  Icon get materialIcon => const Icon(Icons.add);

  @override
  Icon get cupertinoIcon => const Icon(CupertinoIcons.add, size: 20);
}

class _AddScreenState extends State<AddScreen> {
  String _nameText = "";
  Group? _group;
  Category? _category;
  bool _isInputValid = false;

  double _sliderValue = Constants.minRating;
  final double _minValue = Constants.minRating;
  final double _maxValue = Constants.maxRating;

  void _loadArguments() {
    AddScreenArguments arguments = ModalRoute.of(context)!.settings.arguments as AddScreenArguments;
    setState(() {
      _group = arguments.group;
      _category = arguments.category;
    });
  }

  void _openCamera() {}

  void _setNameText(String text) {
    setState(() => _nameText = text);
    _checkIfInputValid();
  }

  void _openChangeCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text("Kategorie wechseln"),
        content: const Text("Möchtest du die Kategorie wirklich wechseln? Die bisherigen Änderungen gehen verloren."),
        material: (context, platform) {
          return MaterialAlertDialogData(
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: Constants.normalPadding,
              vertical: Constants.smallPadding,
            ),
          );
        },
        actions: [
          PlatformDialogAction(
            child: const Text("Abbrechen"),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: const Text("Wechseln"),
            onPressed: () => _changeCategory(),
          ),
        ],
      ),
    );
  }

  void _changeCategory() {
    Navigator.popUntil(context, ModalRoute.withName(AppScaffold.routeName));
    Navigator.pushNamed(context, ChooseCategoryScreen.routeName);
  }

  void _checkIfInputValid() {
    setState(() => _isInputValid = _nameText.isNotEmpty);
  }

  void _save() {}

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadArguments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS
          ? CupertinoNavigationBar(middle: Text(widget.displayName))
          : AppBar(title: Text(widget.displayName)) as PreferredSizeWidget?,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: () => _openCamera(),
                child: Icon(PlatformIcons(context).photoCamera, size: Constants.mediumPadding),
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            PlatformTextField(
              material: (context, platform) {
                return MaterialTextFieldData(
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                );
              },
              cupertino: (context, platform) {
                return CupertinoTextFieldData(placeholder: "Name");
              },
              onChanged: (value) => _setNameText(value),
            ),
            const SizedBox(height: Constants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: PlatformSlider(
                    min: _minValue,
                    max: _maxValue,
                    value: _sliderValue,
                    onChanged: (value) => setState(() => _sliderValue = value),
                  ),
                ),
                const SizedBox(width: Constants.normalPadding),
                Text(_sliderValue.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: Constants.normalPadding),
            if (_group != null && _category != null)
              Card(
                child: ListTile(
                  title: Text(_category!.name),
                  trailing: Text(_group!.name),
                  onTap: () => _openChangeCategoryDialog(),
                ),
              ),
            const SizedBox(height: Constants.largePadding),
            PlatformElevatedButton(onPressed: _isInputValid ? () => _save() : null, child: const Text("Speichern")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
