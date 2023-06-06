import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/screens/choose_category_screen.dart';
import 'package:rating/features/ratings/screens/rate_item_screen.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/services/shell_content.dart';
import 'package:rating/features/core/services/firebase/cloud_service.dart';
import 'package:rating/features/ratings/services/rating.dart';
import 'package:rating/features/social/services/app_user.dart';

class EditItemScreen extends StatefulWidget implements ShellContent {
  static const routeName = "/Add";
  final Item? itemToEdit;
  const EditItemScreen({super.key, this.itemToEdit});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();

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

class _EditItemScreenState extends State<EditItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  Category? _category;
  bool _isInputValid = false;

  double _ratingValue = Constants.noRatingValue;
  String? _comment;

  void _checkIfInputValid() {
    setState(() => _isInputValid = (_nameController.text.isNotEmpty || widget.itemToEdit != null) && _category != null);
  }

  bool _hasRating() {
    return _ratingValue > 0.0;
  }

  void initValues() {
    setState(() {
      _nameController.text = widget.itemToEdit?.name ?? "";
      _category = widget.itemToEdit?.category;
    });
  }

  void _openCamera() {}

  void _changeCategory() async {
    final result = await context.push<Category>(ChooseCategoryScreen.routeName);
    if (result == null) return;
    setState(() => _category = result);
    _checkIfInputValid();
  }

  void _addRating() async {
    final result = await context.push<(double, String?)>(
      RateItemScreen.routeName,
      extra: (Item(categoryId: _category?.id ?? "", name: _nameController.text), _ratingValue, _comment),
    );
    if (result == null) return;
    final (ratingValue, comment) = result;
    setState(() {
      _ratingValue = ratingValue;
      _comment = comment;
    });
  }

  void _save() {
    if (_category == null) return;
    User? user = AppUser.currentUser;
    if (user == null) context.pop();

    Item item = Item(name: _nameController.text, categoryId: _category!.id);
    Rating rating = Rating(
      itemId: item.id,
      userId: user!.uid,
      value: _ratingValue,
      comment: _comment,
    );
    if (widget.itemToEdit == null) {
      item.ratings.add(rating);
      CloudService.instance.addItem(category: _category!, item: item);
    } else {
      CloudService.instance.editItem(item: item);
    }
    context.pop();
  }

  @override
  void initState() {
    super.initState();
    initValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit == null ? widget.displayName : "Bearbeiten"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Constants.mediumPadding),
          children: [
            const SizedBox(height: Constants.normalPadding),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => _openCamera(),
                child: widget.itemToEdit != null
                    ? widget.itemToEdit!.image
                    : Icon(PlatformIcons(context).photoCamera, size: Constants.mediumPadding),
              ),
            ),
            const SizedBox(height: Constants.mediumPadding),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                hintText: widget.itemToEdit?.name,
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
            if (widget.itemToEdit == null)
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  enabled: _category != null && _nameController.text.isNotEmpty,
                  onTap: () => _addRating(),
                  title: Text(_hasRating() ? "Meine Bewertung:" : "(Klicke zum Bewerten)"),
                  subtitle: _comment != null ? Text(_comment!) : null,
                  trailing: _hasRating()
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_ratingValue.toStringAsFixed(Constants.ratingValueDigit)),
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
              child: Text(_hasRating() || widget.itemToEdit != null ? "Speichern" : "Ohne Bewertung speichern"),
            ),
            const SizedBox(height: Constants.largePadding),
          ],
        ),
      ),
    );
  }
}
