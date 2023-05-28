import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/ratings/services/category.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/ratings/services/item.dart';
import 'package:rating/features/social/services/app_user.dart';
import 'package:rating/features/social/services/group.dart';
import 'package:rating/features/ratings/services/rating.dart';

class CloudService {
  static final _userCollection = FirebaseFirestore.instance.collection("users");
  static final _groupCollection = FirebaseFirestore.instance.collection("groups");

  static Future<void> saveUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // final AppUser appUser = AppUser.instance;
    await _userCollection.doc(user.uid).set({
      // ! saveUserData only gets called when the user is signed in for the first time (or when the user data is deleted)
      // ! => token is always the same and no newer tokens are added
      // TODO: Implement a way to update the token.
      "firebaseMessagingTokens": FieldValue.arrayUnion(List<String?>.from([await FirebaseMessaging.instance.getToken()])),
      "groups": [],
    }, SetOptions(merge: true));
    Log.hint("User data saved (UID: ${user.uid}).");
  }

  static Future<void> loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // final AppUser appUser = AppUser.instance;
    DocumentSnapshot snapshot = await _userCollection.doc(user.uid).get();
    if (!snapshot.exists) {
      // appUser.signOut();
      saveUserData();
      return;
    }
    Log.hint("User data loaded (UID: ${user.uid}).");
    // Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    // appUser.loadFromJson(data);
  }

  // static Future<List<AppUser> getAllUsers() async {
  //       List<AppUser> result = [];
  //   final QuerySnapshot<Map<String, dynamic>> rawData = await _userCollection.get();
  //   final rawUsers = rawData.docs.map((doc) => doc.data()).toList();
  //   for (Map<String, dynamic> rawUser in rawUsers) {
  //     result.add(rawUser);
  //   }
  //   return result;

  // }

  static Future<List<Group>> getUserGroupData() async {
    // TODO: Refactor getUserGroupData(). This is quite messy.
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    List<Group> result = [];
    List<String> appUserGroupIds = [];
    DocumentSnapshot rawAppUser = await _userCollection.doc(user.uid).get();
    AppUser appUser = AppUser.fromJson(rawAppUser.data() as Map<String, dynamic>);
    for (String groupId in appUser.groupIds) {
      appUserGroupIds.add(groupId);
    }
    final QuerySnapshot<Map<String, dynamic>> rawGroupData = await _groupCollection.get();
    final rawGroups = rawGroupData.docs.map((doc) => doc.data()).toList();
    for (Map<String, dynamic> rawGroup in rawGroups) {
      Group group = Group.fromJson(rawGroup);
      if (!appUserGroupIds.contains(group.id)) continue;
      result.add(group);
    }
    return result;
  }

  static Future<void> createGroup(String name) async {
    final Group group = Group(name: name);
    await _groupCollection.doc(group.id).set(group.toJson(), SetOptions(merge: true));
    await joinGroup(group.id);
    Provider.of<DataProvider>(Global.context, listen: false).addGroup(group);
  }

  static Future<void> removeGroup(Group group) async {
    await _groupCollection.doc(group.id).delete();
    Provider.of<DataProvider>(Global.context, listen: false).removeGroup(group);
  }

  static Future<void> joinGroup(String groupId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    await _userCollection.doc(user!.uid).set({
      "groups": FieldValue.arrayUnion(List<String>.from([groupId])),
    }, SetOptions(merge: true));
    await _groupCollection.doc(groupId).set({
      "users": FieldValue.arrayUnion(List<String>.from([user.uid])),
    }, SetOptions(merge: true));

    // FirebaseMessaging.instance.subscribeToTopic(id);
    // TODO: Implement a way to not load everything, but only the group.
    Provider.of<DataProvider>(Global.context, listen: false).loadData();
  }

  static Future<void> createCategory({required String name, required Group group}) async {
    final Category category = Category(groupId: group.id, name: name);
    await _groupCollection.doc(group.id).set({
      "categories": FieldValue.arrayUnion(List<Map<String, dynamic>>.from([category.toJson()])),
    }, SetOptions(merge: true));
    Provider.of<DataProvider>(Global.context, listen: false).addCategory(category: category, group: group);
  }

  static Future<void> removeCategory(Category category) async {
    await _groupCollection.doc(category.groupId).set({
      "categories": FieldValue.arrayRemove(List<Map<String, dynamic>>.from([category.toJson()])),
    }, SetOptions(merge: true));
    Provider.of<DataProvider>(Global.context, listen: false).removeCategory(category);
  }

  static Future<void> addItem({required Category category, required Item item}) async {
    Provider.of<DataProvider>(Global.context, listen: false).addItem(category: category, item: item);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
  }

  static Future<void> editItem({required Item item, String? name, String? imageUrl}) async {
    Log.error("EDIT_ITEM NOT IMPLEMENTED");
    return;
  }

  static Future<void> removeItem({required Category category, required Item item}) async {
    Provider.of<DataProvider>(Global.context, listen: false).removeItem(category: category, item: item);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
  }

  static Future<void> addRating({required Category category, required Rating rating}) async {
    Provider.of<DataProvider>(Global.context, listen: false).addRating(category: category, rating: rating);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      // TODO: Refactor to save money (only update the item that was changed) => but is it necessary?
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
  }

  static Future<void> editRating({required Rating rating, String? comment, double? value}) async {
    Log.error("EDIT_RATING NOT IMPLEMENTED");
    return;
  }

  static Future<void> removeRating({required Category category, required Rating rating}) async {
    Provider.of<DataProvider>(Global.context, listen: false).removeRating(category: category, rating: rating);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      // TODO: Refactor to save money (only update the item that was changed) => but is it necessary?
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
  }
}
