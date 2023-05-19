import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/social/services/group.dart';

class AddScreenArguments {
  final Group group;
  final Category category;
  final Item? containedItem;

  AddScreenArguments({required this.group, required this.category, this.containedItem});
}
