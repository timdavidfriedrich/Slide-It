import 'package:uuid/uuid.dart';

class Rating {
  final String id;
  final String name;
  final String? comment;
  final double value;

  Rating({
    required this.name,
    required this.value,
    this.comment,
  }) : id = "rating--${const Uuid().v4()}";

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'comment': comment,
      'value': value,
    };
  }

  Rating.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        comment = json['comment'],
        value = double.parse(json['value'].toString());
}
