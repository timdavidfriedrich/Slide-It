import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/constants.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/firebase/storage_service.dart';
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

  Uint8List? _cameraImageData;

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

  Widget _getImage() {
    if (_cameraImageData != null) {
      return FittedBox(fit: BoxFit.cover, clipBehavior: Clip.hardEdge, child: Image.memory(_cameraImageData!));
    }
    if (widget.itemToEdit?.image != null) {
      return widget.itemToEdit!.image!;
    }
    return Center(child: Icon(PlatformIcons(context).photoCamera));
  }

  void _loadImageFromCamera() async {
    XFile? image;
    try {
      // TODO: Get ImageSource by dialog
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } catch (e) {
      Log.error(e);
    }
    if (image == null) return;
    Uint8List imageData = await image.readAsBytes();
    Uint8List compressImageData = await FlutterImageCompress.compressWithList(
      imageData,
      quality: Constants.imageCompressionQuality,
      minHeight: Constants.imageMaxSize,
      minWidth: Constants.imageMaxSize,
    );
    setState(() => _cameraImageData = compressImageData);
  }

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

  void _save() async {
    if (_category == null) return;
    AppUser? appUser = AppUser.current;
    if (appUser == null) return context.pop();
    Item item = Item(name: _nameController.text, categoryId: _category!.id);
    item.firebaseImageUrl = StorageService.instance.getItemImageDownloadUrl(item: item);
    // TODO: Implement a loading indicator somehow
    await _uploadImage(item);
    _saveItem(item: item, user: appUser);
    if (mounted) context.pop();
  }

  void _saveItem({required Item item, required AppUser user}) {
    Rating rating = Rating(
      itemId: item.id,
      userId: user.id,
      value: _ratingValue,
      comment: _comment,
    );
    if (widget.itemToEdit == null) {
      item.ratings.add(rating);
      CloudService.instance.addItem(category: _category!, item: item);
    } else {
      CloudService.instance.editItem(item: item);
    }
  }

  Future<void> _uploadImage(Item item) async {
    if (_cameraImageData != null) {
      StorageService.instance.uploadItemImage(item: item, imageData: _cameraImageData!);
      // item.firebaseImageUrl = await StorageService.instance.getItemImageDownloadUrl(item: item);
    }
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
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      _getImage(),
                      Positioned.fill(
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _loadImageFromCamera(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
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
