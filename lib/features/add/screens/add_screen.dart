import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/screens/screen.dart';

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
  String _groupText = "Choose a group";
  String _categoryText = "Choose a category";
  bool _isInputValid = false;

  double _sliderValue = Constants.minRating;
  final double _minValue = Constants.minRating;
  final double _maxValue = Constants.maxRating;

  void _openCamera() {}

  void _setNameText(String text) {
    setState(() => _nameText = text);
    _checkIfInputValid();
  }

  void _setGroupText(String text) {
    setState(() => _groupText = text);
    _checkIfInputValid();
  }

  void _setCategoryText(String category) {
    setState(() => _categoryText = category);
    _checkIfInputValid();
  }

  void _checkIfInputValid() {
    setState(() => _isInputValid = _nameText.isNotEmpty && _groupText.isNotEmpty && _categoryText.isNotEmpty);
  }

  void _save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS
          ? CupertinoNavigationBar(middle: Text(widget.displayName))
          : AppBar(title: Text(widget.displayName)) as PreferredSizeWidget?,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Constants.largePadding),
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
            const SizedBox(height: Constants.normalPadding),
            PlatformListTile(
              title: Text(_groupText),
              material: (context, platform) => MaterialListTileData(
                shape: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              trailing: PlatformPopupMenu(
                icon: Icon(PlatformIcons(context).downArrow),
                options: [
                  PopupMenuOption(label: "MIB-Gang", onTap: (value) => _setGroupText(value.label!)),
                  PopupMenuOption(label: "Familie", onTap: (value) => _setGroupText(value.label!)),
                ],
              ),
            ),
            const SizedBox(height: Constants.normalPadding),
            PlatformListTile(
              title: Text(_categoryText),
              material: (context, platform) => MaterialListTileData(
                shape: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              trailing: PlatformPopupMenu(
                icon: Icon(PlatformIcons(context).downArrow),
                options: [
                  PopupMenuOption(label: "Deckenrating", onTap: (value) => _setCategoryText(value.label!)),
                  PopupMenuOption(label: "Mensa-Essen", onTap: (value) => _setCategoryText(value.label!)),
                  PopupMenuOption(label: "Red Bull", onTap: (value) => _setCategoryText(value.label!)),
                ],
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            Text("Deine Bewertung: ${_sliderValue.toStringAsFixed(1)}"),
            const SizedBox(height: Constants.smallPadding),
            PlatformSlider(
              min: _minValue,
              max: _maxValue,
              value: _sliderValue,
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
            const SizedBox(height: Constants.mediumPadding),
            PlatformElevatedButton(onPressed: _isInputValid ? () => _save() : null, child: const Text("Speichern")),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
