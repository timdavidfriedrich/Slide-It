import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/services/app_user.dart';
import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final String name;
  String? avatarUrl;
  // ? Keep color ?
  // Color color = Theme.of(Global.context).cardColor;
  List<String> users = [];
  List<Category> categories = [];

  Group({required this.name, bool autoJoin = false}) : id = "group--${const Uuid().v4()}" {
    if (autoJoin && AppUser.current != null) users.add(AppUser.current!.id);
  }

  Group.empty()
      : id = "empty-group--${const Uuid().v4()}",
        name = "Empty";

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
      : id = json['id'] ?? "",
        name = json['name'] ?? "",
        avatarUrl = json['avatarUrl'],
        users = List<String>.from(json['users'] ?? []),
        categories = ((json['categories'] ?? []) as List).map((category) => Category.fromJson(category)).toList();

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
      child: avatarUrl != null ? null : Icon(PlatformIcons(Global.context).group),
    );
  }
}
