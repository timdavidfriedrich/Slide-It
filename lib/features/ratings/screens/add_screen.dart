import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/screens/choose_category_screen.dart';
import 'package:rating/features/ratings/screens/rate_screen.dart';
import 'package:rating/features/ratings/services/add_screen_arguments.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/services/screen.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/ratings/services/rating.dart';

class AddScreen extends StatefulWidget implements Screen {
  static const routeName = "/Add";
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
  final TextEditingController _nameController = TextEditingController();
  Category? _category;
  Item? _containedItem;
  bool _isEditMode = false; // TODO: Implement edit mode
  bool _isInputValid = false;

  double _ratingValue = Constants.minRating;
  String? _comment;

  void _checkIfInputValid() {
    setState(() => _isInputValid = (_nameController.text.isNotEmpty || _containedItem != null) && _category != null);
  }

  bool _hasRating() {
    return _ratingValue > 0.0;
  }

  void _loadArguments() {
    AddScreenArguments? arguments = ModalRoute.of(context)!.settings.arguments as AddScreenArguments?;
    if (arguments == null) return;
    setState(() {
      _isEditMode = arguments.isEditMode;
    });
  }

  void _openCamera() {}

  void _changeCategory() async {
    final result = await Navigator.pushNamed(context, ChooseCategoryScreen.routeName);
    if (result is! Category) return;
    setState(() => _category = result);
    _checkIfInputValid();
  }

  void _addRating() async {
    // TODO: Give RateScreen the item as argument
    final result = await Navigator.pushNamed(context, RateScreen.routeName);
    if (result == null || result is! (double, String?)) return;
    final (ratingValue, comment) = result;
    setState(() {
      _ratingValue = ratingValue;
      _comment = comment;
    });
  }

  void _save() {
    if (_category == null) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) Navigator.pop(context);

    Item item = Item(name: _nameController.text, categoryId: _category!.id);
    Rating rating = Rating(
      itemId: item.id,
      userId: user!.uid,
      value: _ratingValue,
      comment: _comment,
    );
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
              child: _containedItem != null
                  ? _containedItem!.image
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      onPressed: () => _openCamera(),
                      child: Icon(PlatformIcons(context).photoCamera, size: Constants.mediumPadding),
                    ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
              onChanged: (_) => _checkIfInputValid(),
            ),
            const SizedBox(height: Constants.mediumPadding),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                onTap: () => _changeCategory(),
                title: Text(_category?.name ?? "(Wähle eine Kategorie)"),
                trailing: _category != null ? Text(Provider.of<DataProvider>(context).getGroupFromCategory(_category!).name) : null,
              ),
            ),
            const SizedBox(height: Constants.normalPadding),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                enabled: _category != null,
                onTap: () => _addRating(),
                title: Text(_hasRating() ? "Meine Bewertung:" : "(Klicke zum Bewerten)"),
                subtitle: _comment != null ? Text(_comment!) : null,
                trailing: _hasRating()
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_ratingValue.toStringAsFixed(1)),
                          const SizedBox(width: Constants.smallPadding),
                          const Text("🔥"),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            ElevatedButton(
              onPressed: _isInputValid ? () => _save() : null,
              child: Text(_hasRating() ? "Speichern" : "Ohne Bewertung speichern"),
            ),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
