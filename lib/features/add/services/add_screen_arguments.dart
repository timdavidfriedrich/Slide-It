import 'package:rating/features/categories/services/category.dart';
import 'package:rating/features/core/services/group.dart';

class AddScreenArguments {
  final Group group;
  final Category category;

  AddScreenArguments({required this.group, required this.category});
}
