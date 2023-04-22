import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/ratings/services/add_screen_arguments.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/widget/change_category_dialog.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/services/screen.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:rating/features/ratings/services/rating.dart';

class AddScreen extends StatefulWidget implements Screen {
  static const routeName = "/add";
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();

  @override
  String get displayName => "Objekt Hinzufügen";

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
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

  void _openChangeCategoryDialog() {
    showDialog(context: context, builder: (context) => const ChangeCategoryDialog());
  }

  void _updateSliderValue(double value) {
    setState(() => _sliderValue = value);
  }

  void _checkIfInputValid() {
    setState(() => _isInputValid = _nameController.text.isNotEmpty);
  }

  void _save() {
    if (_category == null) return;
    // TODO: Refactor (way too much weird code)
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) Navigator.pop(context);
    Item item = Item(name: _nameController.text, categoryId: _category!.groupId);
    Rating rating = Rating(itemId: item.id, userId: user!.uid, value: _sliderValue, comment: _commentController.text);
    item.ratings.add(rating);
    CloudService.addItem(category: _category!, item: item);
    Navigator.pop(context);
  }

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
            const SizedBox(height: Constants.normalPadding),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: () => _openCamera(),
                child: Icon(PlatformIcons(context).photoCamera, size: Constants.mediumPadding),
              ),
            ),
            const SizedBox(height: Constants.normalPadding),
            PlatformTextField(
              controller: _nameController,
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
              onChanged: (_) => _checkIfInputValid(),
            ),
            const SizedBox(height: Constants.mediumPadding),
            Text("Meine Bewertung", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Constants.smallPadding),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Constants.normalPadding, vertical: Constants.normalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Rating:",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: PlatformSlider(
                            min: _minValue,
                            max: _maxValue,
                            value: _sliderValue,
                            onChanged: (value) => _updateSliderValue(value),
                          ),
                        ),
                        const SizedBox(width: Constants.normalPadding),
                        Text(
                          _sliderValue.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: Constants.smallPadding),
                    PlatformTextField(
                      controller: _commentController,
                      maxLines: 3,
                      material: (context, platform) {
                        return MaterialTextFieldData(
                          decoration: const InputDecoration(
                            labelText: "Begründung (optional)",
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        );
                      },
                      cupertino: (context, platform) {
                        return CupertinoTextFieldData(placeholder: "Begründung (optional)");
                      },
                      onChanged: (_) => _checkIfInputValid(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            PlatformElevatedButton(onPressed: _isInputValid ? () => _save() : null, child: const Text("Speichern")),
            if (_group != null && _category != null)
              PlatformTextButton(
                padding: EdgeInsets.zero,
                onPressed: () => _openChangeCategoryDialog(),
                child: ListTile(
                  textColor: Theme.of(context).hintColor,
                  title: Text("Kategorie: ${_category!.name}"),
                  trailing: Text(_group!.name),
                ),
              ),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
