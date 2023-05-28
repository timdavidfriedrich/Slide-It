import 'package:rating/features/ratings/services/item.dart';

class RateItemScreenArguments {
  final Item item;
  final double? ratingValue;
  final String? comment;
  const RateItemScreenArguments({required this.item, this.ratingValue, this.comment});
}
