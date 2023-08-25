import 'package:flutter/material.dart';
import 'package:rating/features/ratings/models/item.dart';

class MapProvider extends ChangeNotifier {
  Item? _selectedItem;

  Item? get selectedItem => _selectedItem;

  set selectedItem(Item? value) {
    _selectedItem = value;
    notifyListeners();
  }

  void selectNextItemWithLocation(List<Item> itemsWithLocation) {
    if (itemsWithLocation.isEmpty) {
      return;
    }
    if (selectedItem == null) {
      selectedItem = itemsWithLocation.first;
      return;
    }
    int index = itemsWithLocation.indexWhere((item) => item.id == selectedItem?.id);
    if (index == -1) {
      selectedItem = itemsWithLocation.first;
      return;
    }
    if (index == itemsWithLocation.length - 1) {
      selectedItem = itemsWithLocation.first;
      return;
    }
    selectedItem = itemsWithLocation[index + 1];
  }
}
