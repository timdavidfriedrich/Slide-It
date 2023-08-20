import 'package:uuid/uuid.dart';

class Rating {
  final String id;
  final String itemId;
  final String userId;
  String? comment;
  double value;

  Rating({
    required this.itemId,
    required this.userId,
    required this.value,
    this.comment,
  }) : id = "rating--${const Uuid().v4()}";

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'userId': userId,
      'comment': comment,
      'value': value,
    };
  }

  Rating.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        itemId = json['itemId'] ?? "",
        userId = json['userId'] ?? "",
        comment = json['comment'],
        value = double.parse((json['value'] ?? 0).toString());
}
