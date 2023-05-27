import 'package:rating/features/ratings/services/item.dart';

class RateScreenArguments {
  final Item item;
  final double? ratingValue;
  final String? comment;
  const RateScreenArguments({required this.item, this.ratingValue, this.comment});
}
