import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rating/features/categories/services/category.dart';
import 'package:rating/features/core/services/rating.dart';
import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final String name;
  String? avatarUrl;
  // ? Keep color ?
  // Color color = Theme.of(Global.context).cardColor;
  List<String> users = [];
  List<Category> categories = [
    Category(
      name: "Deckenrating",
      description: "Welcher Raum hat die krasseste Decke?",
      ratings: [
        Rating(name: "Küche", value: 4.5),
        Rating(name: "Wohnzimmer", value: 7.5),
        Rating(name: "Schlafzimmer", value: 10.0),
        Rating(name: "Badezimmer", value: 3.1),
        Rating(name: "Flur", value: 2.5),
        Rating(name: "Keller", value: 9.0),
      ],
    ),
  ];

  Group({required this.name, bool autoJoin = true}) : id = const Uuid().v4() {
    if (autoJoin) users.add(FirebaseAuth.instance.currentUser!.uid);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'users': users,
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }

  Group.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        avatarUrl = json['avatarUrl'],
        users = List<String>.from(json['users']),
        categories = (json['categories'] as List).map((category) => Category.fromJson(category)).toList();

  // ? Keep color ?
  // Future<void> updateAvatar(String url) async {
  //   avatarUrl = url;
  //   color = await generateGroupColor();
  // }

  // Future<Color> generateGroupColor() async {
  //   if (avatarUrl == null) return color;
  //   PaletteGenerator generator = await PaletteGenerator.fromImageProvider(NetworkImage(avatarUrl!));
  //   return generator.mutedColor?.color ?? color;
  // }

  Widget get avatar {
    return CircleAvatar(
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl != null ? null : const Text("?"),
    );
  }
}
